
Re-Introducing Jenkins: Automated Testing with Pipelines — SitePoint 
https://www.sitepoint.com/re-introducing-jenkins-automated-testing-with-pipelines/

```groovy
stage('cleanup') {
    // Recursively delete all files and folders in the workspace
    // using the built-in pipeline command
    deleteDir()
}

node {

    slackSend color: '#4CAF50', channel: '#devops', message: "Started ${env.JOB_NAME} (<${env.BUILD_URL}|build ${env.BUILD_NUMBER}>)"

    try {

        stage("composer_install") {
            // Run `composer update` as a shell script
            sh 'composer update'
        }
        stage("phpunit") {
            // Run PHPUnit
            sh 'vendor/bin/phpunit'
        }

        slackSend color: '#4CAF50', channel: '#devops', message: "Completed ${env.JOB_NAME} (<${env.BUILD_URL}|build ${env.BUILD_NUMBER}>) successfully"

    } catch (all) {
        slackSend color: '#f44336', channel: '#devops', message: "Failed ${env.JOB_NAME} (<${env.BUILD_URL}|build ${env.BUILD_NUMBER}>) - <${env.BUILD_URL}console|click here to see the console output>"
    }
}
```