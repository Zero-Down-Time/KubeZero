/**
required plugins:
- HTTP Request
- Pipeline Utility Steps
- Credentials Plugin

Forgejo REST client. Forgejo is a hard fork of Gitea and keeps its `/api/v1`
REST API and `token <token>` auth header, so the same endpoints
(`/pulls/N/files`, `/compare/base...head`, `/git/commits`, `/pulls`) work
unchanged.
**/

/**
 * Parse GIT_URL to extract Forgejo base URL, owner, and repo
 */
def parseGitUrl(String gitUrl) {
    // Handle both HTTPS and SSH formats
    // https://forgejo.example.com/owner/repo.git
    // git@forgejo.example.com:owner/repo.git

    def matcher
    if (gitUrl.startsWith('http')) {
        matcher = gitUrl =~ /^(https?:\/\/[^\/]+)\/([^\/]+)\/([^\/]+?)(\.git)?$/
    } else {
        matcher = gitUrl =~ /^git@([^:]+):([^\/]+)\/([^\/]+?)(\.git)?$/
    }

    if (matcher.matches()) {
        def baseUrl = gitUrl.startsWith('http') ? matcher[0][1] : "https://${matcher[0][1]}"
        return [
            forgejoUrl: baseUrl,
            owner: matcher[0][2],
            repo: matcher[0][3]
        ]
    }

    return null
}

/**
 * Get changeset (list of changed files) from Forgejo using Jenkins SCM credentials
 */
def getChangeset(Map config = [:]) {
    // Parse GIT_URL for defaults
    def parsed = env.GIT_URL ? parseGitUrl(env.GIT_URL) : [:]

    def forgejoUrl = config.forgejoUrl ?: parsed.forgejoUrl ?: env.FORGEJO_URL ?: env.GITEA_URL
    // Default credential ID is a consumer-provisioned Jenkins credential; kept as
    // 'gitea-jenkins-password' for back-compat (override via config.credentialsId).
    def credentialsId = config.credentialsId ?: 'gitea-jenkins-password'
    def owner = config.owner ?: parsed.owner
    def repo = config.repo ?: parsed.repo
    def prNumber = config.prNumber ?: env.CHANGE_ID
    def commitSha = config.commitSha ?: env.GIT_COMMIT
    def debug = config.debug ?: false

    if (!forgejoUrl || !owner || !repo) {
        error("Missing required parameters: forgejoUrl, owner, repo. GIT_URL: ${env.GIT_URL}")
    }

    def changedFiles = []

    withCredentials([usernamePassword(credentialsId: credentialsId, usernameVariable: 'FORGEJO_USERNAME', passwordVariable: 'FORGEJO_TOKEN')]) {
        if (prNumber) {
            changedFiles = getPRChangeset(forgejoUrl, env.FORGEJO_TOKEN, owner, repo, prNumber, debug)
        } else if (commitSha) {
            changedFiles = getCommitChangeset(forgejoUrl, env.FORGEJO_TOKEN, owner, repo, commitSha, debug)
        } else {
            def currentSha = env.GIT_COMMIT ?: sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
            changedFiles = getCommitChangeset(forgejoUrl, env.FORGEJO_TOKEN, owner, repo, currentSha, debug)
        }
    }

    if (debug) {
        echo("Changeset: " + changedFiles.join(' '))
    }

    return changedFiles
}

/**
 * Get changed files for a Pull Request
 */
def getPRChangeset(String forgejoUrl, String token, String owner, String repo, String prNumber, Boolean debug) {
    def apiUrl = "${forgejoUrl}/api/v1/repos/${owner}/${repo}/pulls/${prNumber}/files"
    def authHeader = "token " + token

    def response = httpRequest(
        url: apiUrl,
        httpMode: 'GET',
        customHeaders: [[name: 'Authorization', value: authHeader, maskValue: true]],
        contentType: 'APPLICATION_JSON',
        validResponseCodes: '200',
        quiet: !debug
    )

    def files = readJSON text: response.content
    return files.collect { it.filename }
}

/**
 * Get changed files for a specific commit
 */
def getCommitChangeset(String forgejoUrl, String token, String owner, String repo, String sha, Boolean debug) {
    def apiUrl = "${forgejoUrl}/api/v1/repos/${owner}/${repo}/git/commits/${sha}"
    def authHeader = "token " + token

    def response = httpRequest(
        url: apiUrl,
        httpMode: 'GET',
        customHeaders: [[name: 'Authorization', value: authHeader, maskValue: true]],
        contentType: 'APPLICATION_JSON',
        validResponseCodes: '200',
        quiet: !debug
    )

    def commit = readJSON text: response.content
    def parentSha = commit.parents ? commit.parents[0].sha : null

    if (!parentSha) {
        return getCommitFiles(forgejoUrl, token, owner, repo, sha, debug)
    }

    return getCommitDiff(forgejoUrl, token, owner, repo, parentSha, sha, debug)
}

/**
 * Get diff between two commits
 */
def getCommitDiff(String forgejoUrl, String token, String owner, String repo, String base, String head, Boolean debug) {
    def apiUrl = "${forgejoUrl}/api/v1/repos/${owner}/${repo}/compare/${base}...${head}"
    def authHeader = "token " + token

    def response = httpRequest(
        url: apiUrl,
        httpMode: 'GET',
        customHeaders: [[name: 'Authorization', value: authHeader, maskValue: true]],
        contentType: 'APPLICATION_JSON',
        validResponseCodes: '200',
        quiet: !debug
    )

    def diff = readJSON text: response.content
    def allFiles = []

    // Iterate over all commits and gather files
    if (diff.commits) {
        diff.commits.each { commit ->
            if (commit.files) {
                commit.files.each { file ->
                    if (!allFiles.contains(file.filename)) {
                        allFiles.add(file.filename)
                    }
                }
            }
        }
    }

    return allFiles
}

/**
 * Get all files in a commit (for initial commit)
 */
def getCommitFiles(String forgejoUrl, String token, String owner, String repo, String sha, Boolean debug) {
    def apiUrl = "${forgejoUrl}/api/v1/repos/${owner}/${repo}/git/trees/${sha}?recursive=true"
    def authHeader = "token " + token

    def response = httpRequest(
        url: apiUrl,
        httpMode: 'GET',
        customHeaders: [[name: 'Authorization', value: authHeader, maskValue: true]],
        contentType: 'APPLICATION_JSON',
        validResponseCodes: '200',
        quiet: !debug
    )

    def tree = readJSON text: response.content
    return tree.tree ? tree.tree.findAll { it.type == 'blob' }.collect { it.path } : []
}

/**
 * Open or reuse an open PR on Forgejo. Idempotent: if an open PR already exists
 * for head→base, returns its html_url without creating a new one.
 *
 * Required: repoUrl (auto-parsed for forgejoUrl/owner/repo), credentialsId,
 *           base, head, title.
 * Optional: body (default ''), debug (default false).
 * Returns: html_url String.
 */
def openPullRequest(Map config = [:]) {
    def parsed = config.repoUrl ? parseGitUrl(config.repoUrl) : null
    if (!parsed) {
        error("openPullRequest: could not parse 'repoUrl' (got '${config.repoUrl}')")
    }

    def credentialsId = config.credentialsId ?: 'gitea-jenkins-password'
    def base  = config.base
    def head  = config.head
    def title = config.title
    def body  = config.body ?: ''
    def debug = config.debug ?: false

    assert base,  "openPullRequest: 'base' is required"
    assert head,  "openPullRequest: 'head' is required"
    assert title, "openPullRequest: 'title' is required"

    def apiBase = "${parsed.forgejoUrl}/api/v1/repos/${parsed.owner}/${parsed.repo}/pulls"
    String prUrl = ''

    withCredentials([usernamePassword(
        credentialsId: credentialsId,
        usernameVariable: 'FORGEJO_USERNAME',
        passwordVariable: 'FORGEJO_TOKEN'
    )]) {
        def auth = "token ${env.FORGEJO_TOKEN}"

        def listResp = httpRequest(
            url: "${apiBase}?state=open&base=${base}",
            httpMode: 'GET',
            customHeaders: [[name: 'Authorization', value: auth, maskValue: true]],
            contentType: 'APPLICATION_JSON',
            validResponseCodes: '200',
            quiet: !debug
        )
        def existing = readJSON(text: listResp.content).find { it.head?.ref == head }

        if (existing) {
            prUrl = existing.html_url
        } else {
            def createResp = httpRequest(
                url: apiBase,
                httpMode: 'POST',
                customHeaders: [[name: 'Authorization', value: auth, maskValue: true]],
                contentType: 'APPLICATION_JSON',
                requestBody: writeJSON(returnText: true, json: [
                    title: title, body: body, base: base, head: head
                ]),
                validResponseCodes: '201',
                quiet: !debug
            )
            prUrl = readJSON(text: createResp.content).html_url
        }
    }
    return prUrl
}

/**
 * Check if specific paths changed,
 * expects: [files], [patterns]
 */
def pathsChanged(Map parameters = [:]) {
    if (parameters.debug) {
        echo("Patterns: " + parameters.patterns.join(', '))
        echo("ChangeSet: " + writeJSON(returnText: true, json: parameters.files))
    }

    return parameters.patterns.any { pattern ->
       parameters.files.any { file ->
           // Forgejo reports a submodule (gitlink) or directory change as the bare
           // path (e.g. ".ci") with no trailing content, so also test "<path>/"
           // — that lets a contents pattern like "\.ci/.*" match a submodule bump.
           [file, "${file}/"].any { p -> p =~ pattern }
       }
    }
}

return this
