

Using a Jenkinsfile https://jenkins.io/doc/book/pipeline/jenkinsfile/

Jenkinsfile (Scripted Pipeline)
stage('Build') {
    /* .. snip .. */
}

stage('Test') {
    parallel linux: {
        node('linux') {
            checkout scm
            try {
                unstash 'app'
                sh 'make check'
            }
            finally {
                junit '**/target/*.xml'
            }
        }
    },
    windows: {
        node('windows') {
            /* .. snip .. */
        }
    }
}

https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#code-error-code-error-signal
```groovy
node {
    try {
        sh 'might fail'
    } catch (err) {
        echo "Caught: ${err}"
        currentBuild.result = 'FAILURE'
    }
    step([$class: 'Mailer', recipients: 'admin@somewhere'])
}
For all other cases, use plain try-catch(-finally) blocks:

node {
    sh './set-up.sh'
    try {
        sh 'might fail'
        echo 'Succeeded!'
    } catch (err) {
        echo "Failed: ${err}"
    } finally {
        sh './tear-down.sh'
    }
    echo 'Printed whether above succeeded or failed.'
}
// …and the pipeline as a whole succeeds
```