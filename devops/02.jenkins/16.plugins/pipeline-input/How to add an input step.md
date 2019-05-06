Pipeline - How to add an input step, with timeout, that continues if timeout is reached, using a default value – CloudBees Support 
https://support.cloudbees.com/hc/en-us/articles/230922148?q=How%20to%20add%20an%20input%20step,%20with%20timeout,%20that%20continues%20if%20timeout%20is%20reached,%20using%20a%20default%20value

```groovy
def userInput = true
def didTimeout = false
try {
    timeout(time: 15, unit: 'SECONDS') { // change to a convenient timeout for you
        userInput = input(
        id: 'Proceed1', message: 'Was this successful?', parameters: [
        [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Please confirm you agree with this']
        ])
    }
} catch(err) { // timeout reached or input false
    def user = err.getCauses()[0].getUser()
    if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
        didTimeout = true
    } else {
        userInput = false
        echo "Aborted by: [${user}]"
    }
}

node {
    if (didTimeout) {
        // do something on timeout
        echo "no input was received before timeout"
    } else if (userInput == true) {
        // do something
        echo "this was successful"
    } else {
        // do something else
        echo "this was not successful"
        currentBuild.result = 'FAILURE'
    } 
}
```