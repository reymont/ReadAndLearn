

Pipeline - How to add an input step, that continues if aborted, using value – CloudBees Support 
https://support.cloudbees.com/hc/en-us/articles/230922428-Pipeline-How-to-add-an-input-step-that-continues-if-aborted-using-value

```groovy
def userInput
try {
    userInput = input(
        id: 'Proceed1', message: 'Was this successful?', parameters: [
        [$class: 'BooleanParameterDefinition', defaultValue: true, description: '', name: 'Please confirm you agree with this']
        ])
} catch(err) { // input false
    def user = err.getCauses()[0].getUser()
    userInput = false
    echo "Aborted by: [${user}]"
}

node {
    if (userInput == true) {
        // do something
        echo "this was successful"
    } else {
        // do something else
        echo "this was not successful"
        currentBuild.result = 'FAILURE'
    } 
}
```

https://jenkins.io/doc/pipeline/steps/pipeline-input-step/
https://jenkins.io/doc/pipeline/steps/workflow-basic-steps/#code-timeout-code-enforce-time-limit
https://www.cloudbees.com/blog/top-10-best-practices-jenkins-pipeline-plugin (7. Don’t: Use input within a node block)