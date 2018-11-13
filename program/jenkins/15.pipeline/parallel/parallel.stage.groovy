// https://www.cnblogs.com/YatHo/p/7856556.html

pipeline {
    agent any
    stages {
        stage('Non-Parallel Stage') {
            steps {
                echo 'This stage will be executed first.'
            }
        }
        stage('Parallel Stage') {
            parallel {
                stage('Branch A') {
                    agent any
                    steps {
                        echo "On Branch A"
                    }
                }
                stage('Branch B') {
                    agent any
                    steps {
                        echo "On Branch B"
                    }
                }
            }
        }
    }
}