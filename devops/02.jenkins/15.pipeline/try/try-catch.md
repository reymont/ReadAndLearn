
```groovy
node {
    stage('Example1') {
        try {
            sh 'exit 1'
        }
        catch (exc) {
            echo '1 Something failed, I should sound the klaxons!'
        }
        
    }
    stage('Example2') {
        try {
            sh 'exit 1'
        }
        catch (exc) {
            echo '2 Something failed, I should sound the klaxons!'
        }
        
    }
}
```