

Jenkins Pipeline结束时的清理和通知-Linux运维日志
 https://www.centos.bz/2017/08/jenkins-clean-notice/

由于post Pipeline的部分保证在Pipeline执行结束时运行，因此我们可以添加一些通知或其他步骤来执行定稿，通知或其他Pipeline末端任务。

Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any
    stages {
        stage('No-op') {
            steps {
                sh 'ls'
            }
        }
    }
    post {
        always {
            echo 'One way or another, I have finished'
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeeded!'
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
        }
        changed {
            echo 'Things were different before...'
        }
    }
}
Toggle Scripted Pipeline (Advanced)

Jenkinsfile (Scripted Pipeline)
node {
    try {
        stage('No-op') {
            sh 'ls'
        }
    }
}
catch (exc) {
    echo 'I failed'
}
finally {
    if (currentBuild.result == 'UNSTABLE') {
        echo 'I am unstable :/'
    } else {
        echo 'One way or another, I have finished'
    }
}
有很多方法可以发送通知，下面是一些演示如何将有关Pipeline的通知发送到电子邮件，Hipchat房间或Slack频道的片段。

Email

post {
    failure {
        mail to: 'team@example.com',
             subject: "Failed Pipeline: ${currentBuild.fullDisplayName}",
             body: "Something is wrong with ${env.BUILD_URL}"
    }
}
Hipchat

post {
    failure {
        hipchatSend message: "Attention @here ${env.JOB_NAME} #${env.BUILD_NUMBER} has failed.",
                    color: 'RED'
    }
}
Slack

post {
    success {
        slackSend channel: '#ops-room',
                  color: 'good',
                  message: "The pipeline ${currentBuild.fullDisplayName} completed successfully."
    }
}
现在，当事情出现故障，不稳定或甚至成功时，我们可以通过令人兴奋的部分完成我们的持续交付流程：shipping！

原文出处：w3cschool -> https://www.w3cschool.cn/jenkins/jenkins-ayl128nb.html