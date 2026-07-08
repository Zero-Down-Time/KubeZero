/**
 * Build lifecycle notifications via an apprise-api sidecar.
 *
 * Pure Jenkins glue: the pipeline POSTs a single JSON event to apprise-api,
 * which fans out to the configured chat targets (Slack, Matrix, Mattermost,
 * Teams, ...). Destinations + secrets live in apprise-api config *keys*, not in
 * this repo. Notifying a chat channel is a CI-lifecycle concern with no local
 * `just` equivalent, so it correctly lives in Groovy rather than a *.just module.
 *
 * required plugins:
 * - HTTP Request
 * - Pipeline Utility Steps (writeJSON)
 * - Credentials Plugin (only when notify.credentialsId is set)
 *
 * Opt in from a consumer Jenkinsfile:
 *
 *   justContainer(
 *     ...,
 *     notify: [
 *       key:    'team-platform',                            // apprise-api config key (recommended)
 *       events: ['start', 'success', 'failure', 'aborted'], // this is the default set
 *     ],
 *   )
 *
 * The apprise-api endpoint defaults to env.APPRISE_API_URL (set once on the
 * controller, since the sidecar is shared infra) and is overridable per-job via
 * notify.url.
 */

def start(Map config = [:]) {
    _emit(config, 'start')
}

// Safe to call unconditionally from post { always { } }: derives the event from
// currentBuild.currentResult and self-filters by events and the SKIP flag.
def end(Map config = [:]) {
    def event = [
        SUCCESS:   'success',
        FAILURE:   'failure',
        UNSTABLE:  'unstable',
        ABORTED:   'aborted',
        NOT_BUILT: 'aborted',
    ][currentBuild.currentResult] ?: 'failure'
    _emit(config, event)
}

// Per-event presentation + apprise type — the single source of truth consumed by
// _title (phrase/emoji) and _payload (type).
def _meta(String event) {
    return [
        start:    [phrase: 'started',               emoji: '🚀', type: 'info'],
        success:  [phrase: 'finished successfully', emoji: '✅', type: 'success'],
        failure:  [phrase: 'failed',                emoji: '❌', type: 'failure'],
        unstable: [phrase: 'finished unstable',     emoji: '⚠️', type: 'warning'],
        aborted:  [phrase: 'was aborted',           emoji: '⏹️', type: 'warning'],
    ][event] ?: [phrase: event, emoji: null, type: 'failure']
}

// Apply the event/SKIP filters, then send. Never throws: a notification problem
// must not fail the build.
def _emit(Map config, String event) {
    try {
        def n = config.notify
        if (!(n instanceof Map)) return

        def events = n.events ?: ['start', 'success', 'failure', 'aborted']
        if (!events.contains(event)) return

        if (currentBuild.description == 'SKIP' && !(n.notifySkipped ?: false)) return

        def apiUrl = (n.url ?: env.APPRISE_API_URL)?.toString()?.replaceAll('/$', '')
        if (!apiUrl) {
            echo "notify: no apprise-api url (set env.APPRISE_API_URL or notify.url); skipping ${event}"
            return
        }

        _dispatch(n, _endpoint(n, apiUrl), _payload(n, event), n.debug ?: false)
    } catch (err) {
        echo "notify: ${event} notification failed (ignored): ${err}"
    }
}

def _payload(Map n, String event) {
    def payload = [
        title:  _title(event),
        body:   _body(n, event),
        type:   _meta(event).type,
        format: 'markdown',
    ]
    if (n.tag)  payload.tag  = n.tag
    if (n.urls) payload.urls = n.urls instanceof List ? n.urls.join(',') : n.urls
    return payload
}

// key → stateful config stored server-side under that key; else inline urls →
// stateless /notify; else apprise-api's conventional 'default' key.
def _endpoint(Map n, String apiUrl) {
    if (n.key)  return "${apiUrl}/notify/${n.key}"
    if (n.urls) return "${apiUrl}/notify"
    return "${apiUrl}/notify/default"
}

// Send once, retrying a single time on FlowInterruptedException. A build aborted
// via the UI delivers that interrupt to the first interruptible step that runs
// inside post {} — for us the credential binding / httpRequest — so the only POST
// attempt is killed before the event leaves the agent and the abort goes silent.
// The interrupt is one-shot: once it has propagated out of the step it is consumed,
// so a single retry delivers the event. A second failure falls through to _emit's
// catch (logged, never rethrown — the build is already ABORTED).
def _dispatch(Map n, String endpoint, Map payload, Boolean debug) {
    try {
        _sendOnce(n, endpoint, payload, debug)
    } catch (org.jenkinsci.plugins.workflow.steps.FlowInterruptedException ignored) {
        _sendOnce(n, endpoint, payload, debug)
    }
}

def _sendOnce(Map n, String endpoint, Map payload, Boolean debug) {
    if (n.credentialsId) {
        withCredentials([string(credentialsId: n.credentialsId, variable: 'APPRISE_TOKEN')]) {
            _post(endpoint, payload, [[name: 'Authorization', value: "Bearer ${env.APPRISE_TOKEN}", maskValue: true]], debug)
        }
    } else {
        _post(endpoint, payload, [], debug)
    }
}

def _post(String endpoint, Map payload, List headers, Boolean debug) {
    def resp = httpRequest(
        url: endpoint,
        httpMode: 'POST',
        contentType: 'APPLICATION_JSON',
        customHeaders: headers,
        requestBody: writeJSON(returnText: true, json: payload),
        validResponseCodes: '100:599',
        quiet: !debug,
    )
    if ((resp.status as int) >= 300) {
        echo "notify: apprise-api returned HTTP ${resp.status}: ${resp.content}"
    }
}

// e.g. "✅ Jenkins build of api-users/main finished successfully (Fixed)". End
// events append the build-status transition; the trigger cause lives in the body.
def _title(String event) {
    def meta = _meta(event)
    def detail = (event == 'start') ? null : _transition()
    def title = "Jenkins build of ${_project()} ${meta.phrase}"
    if (detail) title += " (${detail})"
    return meta.emoji ? "${meta.emoji} ${title}" : title
}

// "<project>/<branch>" identifying the build. On a multibranch job JOB_BASE_NAME
// is only the branch and JOB_NAME's branch segment is URL-encoded (feature%2Ffoo),
// so take the project (parent) segment from JOB_NAME and the decoded BRANCH_NAME.
// Falls back to the plain JOB_NAME for non-multibranch jobs.
def _project() {
    def full = env.JOB_NAME ?: env.JOB_BASE_NAME ?: 'build'
    if (env.BRANCH_NAME) {
        def segs = full.split('/')
        def project = segs.length >= 2 ? segs[-2] : segs[-1]
        return "${project}/${env.BRANCH_NAME}"
    }
    return full
}

// Human-readable trigger cause (e.g. "Started by user Stefan"), or null. Guarded
// so it can never sink the notification.
def _triggerCause() {
    try {
        def causes = currentBuild.buildCauses
        return causes ? causes[0].shortDescription : null
    } catch (ignored) {
        return null
    }
}

// Build-status transition vs. the previous run: null for steady green (no extra
// signal), else a short label — "Fixed", "Broken", "Still failing", ...
def _transition() {
    def prev = currentBuild.previousBuild?.result
    def cur  = currentBuild.currentResult ?: 'SUCCESS'
    if (!prev)        return 'First build'
    if (prev == cur)  return cur == 'SUCCESS' ? null : "Still ${cur.toLowerCase()}"
    if (cur == 'SUCCESS')  return 'Fixed'
    if (prev == 'SUCCESS') return 'Broken'
    return "Now ${cur.toLowerCase()}"
}

// Default body (a consumer-supplied notify.messages[event] closure/string wins).
// Closures resolve lazily here so env/currentBuild are populated.
def _body(Map n, String event) {
    def override = (n.messages instanceof Map) ? n.messages[event] : null
    if (override instanceof Closure) return override.call().toString()
    if (override != null) return override.toString()

    def parts = []
    if (env.CHANGE_ID) {
        parts << _link(env.CHANGE_URL, "PR #${env.CHANGE_ID}")
    } else {
        def branch = (env.BRANCH_NAME ?: env.GIT_BRANCH)?.replaceFirst(/^origin\//, '')
        if (branch) parts << _link(_branchUrl(branch), branch)
    }
    if (env.GIT_COMMIT) {
        parts << _link(_commitUrl(), env.GIT_COMMIT.take(8))
    }

    // Start events append the trigger cause ("Started by " rephrased to
    // "triggered by"); end events append the duration.
    def buildSeg = _link(env.BUILD_URL, "build ${env.BUILD_NUMBER}")
    if (event == 'start') {
        def cause = _triggerCause()?.replaceFirst(/^Started by /, '')
        if (cause) buildSeg += " triggered by ${cause}"
    } else {
        buildSeg += " took ${currentBuild.durationString?.replace(' and counting', '') ?: 'n/a'}"
    }
    parts << buildSeg

    return parts.join(' · ')
}

// Slack-style link, or the bare text when no url is available.
def _link(String url, String text) {
    return url ? "<${url}|${text}>" : text
}

// "${forgejoUrl}/${owner}/${repo}", derived in-process from env.GIT_URL via
// forgejo.parseGitUrl (no remote call). Null when absent/unparseable; guarded so a
// link-building hiccup can never sink the notification.
def _repoBase() {
    try {
        if (!env.GIT_URL) return null
        def g = forgejo.parseGitUrl(env.GIT_URL)
        return g ? "${g.forgejoUrl}/${g.owner}/${g.repo}" : null
    } catch (ignored) {
        return null
    }
}

def _commitUrl() {
    def base = _repoBase()
    return (base && env.GIT_COMMIT) ? "${base}/commit/${env.GIT_COMMIT}" : null
}

def _branchUrl(String branch) {
    def base = _repoBase()
    return (base && branch) ? "${base}/src/branch/${branch}" : null
}

return this
