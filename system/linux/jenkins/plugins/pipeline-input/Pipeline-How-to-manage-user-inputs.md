

Pipeline: How to manage user inputs – CloudBees Support 
https://support.cloudbees.com/hc/en-us/articles/204986450-Pipeline-How-to-manage-user-inputs

```groovy
stage 'promotion'
def userInput = input(
 id: 'userInput', message: 'Let\'s promote?', parameters: [
 [$class: 'TextParameterDefinition', defaultValue: 'uat', description: 'Environment', name: 'env'],
 [$class: 'TextParameterDefinition', defaultValue: 'uat1', description: 'Target', name: 'target']
])
echo ("Env: "+userInput['env'])
echo ("Target: "+userInput['target'])
```

```yml
stage 'promotion'
def userInput = input(
 id: 'userInput', message: 'Let\'s promote?', parameters: [
 [$class: 'TextParameterDefinition', defaultValue: 'uat', description: 'Environment', name: 'env']
])
echo ("Env: "+userInput)
```