// https://www.cnblogs.com/YatHo/p/7856556.html
// https://jenkins.io/doc/pipeline/examples/#parallel-multiple-nodes
// https://jenkins.io/doc/book/pipeline/syntax/#parallel-stages-example
// https://github.com/jenkinsci/pipeline-examples/blob/master/docs/BEST_PRACTICES.md

pipeline {
    agent any
    stages {
        stage('Non-Parallel Stage') {
            steps {
                echo 'This stage will be executed first.'
            }
        }
        stage('Parallel Stage') {
            steps{
                script{
                    builders = [:]
                    for (x in ['1', '2']) {
                        builders[x] = {
                            stage("Branch $x") {
                                agent any
                                steps {
                                    echo "On Branch $x"
                                }
                            }                          
                        }
                    }
                    parallel builders
                }
            }
        }
    }
}