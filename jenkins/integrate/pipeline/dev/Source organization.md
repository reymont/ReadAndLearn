

pipeline-plugin/CONTRIBUTING.md at master · jenkinsci/pipeline-plugin 
https://github.com/jenkinsci/pipeline-plugin/blob/master/CONTRIBUTING.md

# Source organization

The implementation is divided into a number of plugin repositories which can be built and released independently in most cases.

* workflow-step-api-plugin defines a generic build step interface (not specific to pipelines) that many plugins could in the future * depend on.
* workflow-basic-steps-plugin add some generic step implementations.
* workflow-api-plugin defines the essential aspects of pipelines and their executions. In particular, the engine running a Pipeline * is extensible and so could in the future support visual orchestration languages.
* workflow-support-plugin adds general implementations of some internals needed by pipelines, such as storing state.
* workflow-job-plugin provides the actual job type and top-level UI for defining and running pipelines.
* workflow-durable-task-step-plugin allows you to allocate nodes and workspaces, and uses the durable-task plugin to define a shell * script step that can survive restarts.
* workflow-scm-step-plugin adds SCM-related steps.
* pipeline-build-step-plugin, pipeline-input-step-plugin, and pipeline-stage-step-plugin add complicated steps.
* pipeline-stage-view-plugin adds a job-level visualization of builds and stages in a grid.
* workflow-cps-plugin is the Pipeline engine implementation based on the Groovy language, and supporting long-running pipelines * using a continuation passing style transformation of the script.
* workflow-cps-global-lib-plugin adds a Git-backed repository for Groovy libraries available to scripts.
* workflow-aggregator-plugin is a placeholder plugin allowing the whole Pipeline suite to be installed with one click. It also hosts the official Docker demo.