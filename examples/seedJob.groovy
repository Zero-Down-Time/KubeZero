// examples/seedJob.groovy
//
// Seed job for the monorepo "one Multibranch job per service" pattern. Commit
// this 2-line wrapper at the consumer repo ROOT. Wire it either as:
//   - a dedicated "Pipeline script from SCM" job (Script Path: seedJob.groovy),
//     or bootstrap that job as code via examples/jenkins.casc.yaml; or
//   - the repo's root Jenkinsfile (rename to `Jenkinsfile`) under a Multibranch /
//     Org-Folder job, so it's auto-discovered. seedMultiJob() self-guards to seed
//     only from the primary branch, so it won't fire on every PR/feature branch.
//
// All logic lives in the shared library (vars/seedMultiJob.groovy), so it tracks
// the .ci submodule / library reload instead of being copied per consumer. The
// seed auto-targets the consuming repo (its own SCM) — no repo coordinates here.
//
//   container-monorepo/
//   ├── kubezero-geoip/   { Dockerfile, scripts…, Jenkinsfile }
//   ├── some-other-svc/   { Dockerfile, scripts…, Jenkinsfile }
//   ├── seedJob.groovy    (this file)
//   └── .ci/              (this library, as a submodule)
//
// Override defaults if needed:
//   seedMultiJob(jobFolder: 'images')                          // generated-jobs folder (default <org>-jobs/<repo>)
//   seedMultiJob(discoveryGlob: 'services/*/Jenkinsfile')      // nested layout — default '*/Jenkinsfile' is one level only
//                                                                 (use '**/Jenkinsfile' for arbitrary depth)
//   seedMultiJob(credentialsId: 'gitea-jenkins-pat')           // SCM-clone credential (a PAT), if distinct from the REST token

@Library('ci-tools-lib') _

seedMultiJob()
