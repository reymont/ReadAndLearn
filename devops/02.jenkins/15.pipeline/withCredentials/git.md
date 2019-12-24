
https://stackoverflow.com/questions/55970749/git-push-using-jenkins-credentials-from-declarative-pipeline

```groovy
withCredentials([usernamePassword(credentialsId: env.GIT_CREDENTIAL_ID, usernameVariable: 'USER', passwordVariable: 'PASS')]) {
                    script {
                        env.encodedPass=URLEncoder.encode(PASS, "UTF-8")
                    }
                    sh 'git clone https://${USER}:${encodedPass}@${GIT_URL} ${DIR} -b ${BRANCH}'
                    sh 'git add .'
                    sh 'git commit -m "foobar" '
                    sh 'git push'
                } 
```