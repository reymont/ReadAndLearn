

jenkinsci/gitlab-plugin: A Jenkins plugin for interfacing with GitLab 
https://github.com/jenkinsci/gitlab-plugin

GitLab 8.1 has implemented a commit status api, you need an extra post-build step to support commit status.

In GitLab go to your repository's project Settings

# Click on Web Hooks
Earlier in Jenkins, you made a note of the GitLab CI Service URL, which is of the form `http://JENKINS_URL/project/JENKINS_PROJECT_NAME`. Specify this as the web hook URL. Note that JENKINS_PROJECT_NAME is the name of the Jenkins project you want to trigger, including Jenkins folders.
Select Merge Request Events and Push Events
Click Add Webhook
Click Test Hook to test your new web hook. You should see two results:
GitLab should display "Hook successfully executed"
Jenkins project JENKINS_PROJECT_NAME should start
Add a post-build step Publish build status to GitLab commit (GitLab 8.1+ required) to the job.

For pipeline jobs surround your build step with the gitlabCommitStatus step like this:

```groovy
node() {
    stage 'Checkout'
    checkout <your-scm-config>

    gitlabCommitStatus {
       <script that builds, tests, etc. your project>
    }
}
```
For pipeline jobs there is also the updateGitlabCommitStatus step to use a custom state for updating the commit status:

```groovy
node() {
    stage 'Checkout'
    checkout <your-scm-config>

    updateGitlabCommitStatus name: 'build', state: 'pending'
}
```
To mark several build stages as pending in GitLab you can use the gitlabBuilds step:

```groovy
node() {
    stage 'Checkout'
    checkout <your-scm-config>

    gitlabBuilds(builds: ["build", "test"]) {
        stage "build"
        gitlabCommitStatus("build") {
            // your build steps
        }

        stage "test"
        gitlabCommitStatus("test") {
            // your test steps
        }
    }
}
```
Configure access to GitLab as described above in "Configure access to GitLab" (the account needs at least developer permissions to post commit statuses)