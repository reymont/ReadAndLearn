

https://github.com/mkj28/ScriptedJenkinsSandbox


```groovy
properties([buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '7', numToKeepStr: '50')), parameters([[$class: 'GitParameterDefinition', branch: '', branchFilter: '.*', defaultValue: '', description: 'Git Branch Or Tag', name: 'GITBRANCHORTAG', quickFilterEnabled: false, selectedValue: 'NONE', sortMode: 'NONE', tagFilter: '*', type: 'PT_BRANCH_TAG']]), pipelineTriggers([pollSCM('H/2 * * * *')])])

node {
    def repoTmpTags = 'tempTags.txt'

    stage('Checkout') {
        git url: 'https://github.com/mkj28/ScriptedJenkinsSandbox.git'
        def repoUrl = 'https://github.com/mkj28/ScriptedJenkinsSandbox.git'
        
        checkout scm
        sh("git ls-remote --quiet --tags --heads ${repoUrl} | awk '{print \$2}' | grep -vi '{}' | cut -d/ -f1,2 --complement > ${repoTmpTags}")
    }

    stage('User input') {
        input message: 'Select tag', parameters: [[$class: 'GitParameterDefinition', branch: '', branchFilter: '.*', defaultValue: '', description: 'Git Tag Description', name: 'gitTag', quickFilterEnabled: true, selectedValue: 'NONE', sortMode: 'NONE', tagFilter: '*', type: 'PT_BRANCH_TAG']]
    }
    stage('From file') {
        def listofRepo1TagsBranches = readFile(repoTmpTags).trim()
        def repo1TagBranch = input([message: 'Select a Git branch / tag', parameters: [[$class: 'ChoiceParameterDefinition', choices: listofRepo1TagsBranches, description: '', name: 'fileTag']]])
        echo ("Target: "+repo1TagBranch)
    }
    stage('Another user input') {
        def userInput = input(
            id: 'userInput', message: 'Let\'s promote?', parameters: [
                [$class: 'TextParameterDefinition', defaultValue: 'uat', description: 'Environment', name: 'env'],
                [$class: 'TextParameterDefinition', defaultValue: 'uat1', description: 'Target', name: 'target']
                ])
        echo ("Env: "+userInput['env'])
        echo ("Target: "+userInput['target'])
    }
    stage('Yet another user input') {
        Map feedback = input(submitterParameter: 'submitter', message: "tell me something", parameters: [
            [$class: 'GitParameterDefinition', branch: '', branchFilter: '.*', defaultValue: '', description: 'Git Tag Description', name: 'text', quickFilterEnabled: true, selectedValue: 'NONE', sortMode: 'NONE', tagFilter: '*', type: 'PT_BRANCH_TAG']
            ])
        echo "Text: ${feedback.text}"
        echo "Submitter: ${feedback.submitter}"
    }
    stage('Build') {
        echo 'building'
    }

    stage('Test') {
        echo 'testing'
    }

    stage('Deploy') {
        echo 'deploying'
    }
}
```