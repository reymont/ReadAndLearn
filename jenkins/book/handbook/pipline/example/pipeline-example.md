
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Pipeline Examples](#pipeline-examples)
* [Ansi Color Build Wrapper](#ansi-color-build-wrapper)
* [Archive Build Output Artifacts](#archive-build-output-artifacts)
* [Artifactory Generic Upload Download](#artifactory-generic-upload-download)
* [Artifactory Gradle Build](#artifactory-gradle-build)
* [Artifactory Maven Build](#artifactory-maven-build)
* [External Workspace Manager](#external-workspace-manager)
* [Load From File](#load-from-file)
* [Maven And Jdk Specific Version](#maven-and-jdk-specific-version)

<!-- /code_chunk_output -->

---

* [Pipeline Examples ](https://jenkins.io/doc/pipeline/examples/)
* [jenkinsci/pipeline-examples: A collection of examples, tips and tricks and snippets of scripting for the Jenkins Pipeline plugin ](https://github.com/jenkinsci/pipeline-examples)
* [fabric8io/jenkins-pipeline-library: a collection of reusable jenkins pipelines and pipeline functions ](https://github.com/fabric8io/jenkins-pipeline-library)
* [docker/jenkins-pipeline-scripts ](https://github.com/docker/jenkins-pipeline-scripts)


# Pipeline Examples 
The following examples are sourced from the the pipeline-examples repository on GitHub and contributed to by various members of the Jenkins project. If you are interested in contributing your own example, please consult the README in the repository.

* Table of Contents
  * Ansi Color Build Wrapper
  * Archive Build Output Artifacts
  * Artifactory Generic Upload Download
  * Artifactory Gradle Build
  * Artifactory Maven Build
  * Configfile Provider Plugin
  * External Workspace Manager
  * Get Build Cause
  * Gitcommit
  * Gitcommit_changeset
  * Ircnotify Commandline
  * Jobs In Parallel
  * Load From File
  * Maven And Jdk Specific Version
  * Parallel From Grep
  * Parallel From List
  * Parallel Multiple Nodes
  * Push Git Repo
  * Slacknotify
  * Timestamper Wrapper
  * Trigger Job On All Nodes
  * Unstash Different Dir

# Ansi Color Build Wrapper 

 Synopsis

This shows usage of a simple build wrapper, specifically the AnsiColor plugin, which adds ANSI coloring to the console output.
这显示了一个简单的构建包装的样例，特别是 AnsiColor 插件，这增加了ANSI着色控制台输出。

```groovy
// This shows a simple build wrapper example, using the AnsiColor plugin.
node {
    // This displays colors using the 'xterm' ansi color map.
    ansiColor('xterm') {
        // Just some echoes to show the ANSI color.
        stage "\u001B[31mI'm Red\u001B[0m Now not"
    }
}
```

# Archive Build Output Artifacts 
Synopsis
This is a simple demonstration of how to archive the build output artifacts in workspace for later use.
这是一个简单的演示如何档案建立后使用工作区中的输出工件。

```groovy
// This shows a simple example of how to archive the build output artifacts.
node {
    stage "Create build output"
    
    // Make the output directory.
    sh "mkdir -p output"

    // Write an useful file, which is needed to be archived.
    writeFile file: "output/usefulfile.txt", text: "This file is useful, need to archive it."

    // Write an useless file, which is not needed to be archived.
    writeFile file: "output/uselessfile.md", text: "This file is useless, no need to archive it."

    stage "Archive build output"
    
    // Archive the build output artifacts.
    archiveArtifacts artifacts: 'output/*.txt', excludes: 'output/*.md'
}
```

# Artifactory Generic Upload Download 
Synopsis
This is a simple demonstration of how to download dependencies, upload artifacts and publish build info to Artifactory. 
Read the full documentation here.

```groovy
node {
    git url: 'https://github.com/jfrogdev/project-examples.git'

    // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
    def server = Artifactory.server "SERVER_ID"

    // Read the upload spec and upload files to Artifactory.
    def downloadSpec =
            '''{
            "files": [
                {
                    "pattern": "libs-snapshot-local/*.zip",
                    "target": "dependencies/",
                    "props": "p1=v1;p2=v2"
                }
            ]
        }'''

    def buildInfo1 = server.download spec: downloadSpec

    // Read the upload spec which was downloaded from github.
    def uploadSpec =
            '''{
            "files": [
                {
                    "pattern": "resources/Kermit.*",
                    "target": "libs-snapshot-local",
                    "props": "p1=v1;p2=v2"
                },
                {
                    "pattern": "resources/Frogger.*",
                    "target": "libs-snapshot-local"
                }
            ]
        }'''

    // Upload to Artifactory.
    def buildInfo2 = server.upload spec: uploadSpec

    // Merge the upload and download build-info objects.
    buildInfo1.append buildInfo2

    // Publish the build to Artifactory
    server.publishBuildInfo buildInfo1
}
```

# Artifactory Gradle Build 
Synopsis
This is a simple demonstration of how to run a Gradle build, that resolves dependencies, upload artifacts and publish build info to Artifactory. 
Read the full documentation here.
```groovy
node {
    // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
    def server = Artifactory.server "SERVER_ID"
    // Create an Artifactory Gradle instance.
    def rtGradle = Artifactory.newGradleBuild()
    def buildInfo

    stage('Clone sources') {
        git url: 'https://github.com/jfrogdev/project-examples.git'
    }

    stage('Artifactory configuration') {
        // Tool name from Jenkins configuration
        rtGradle.tool = "Gradle-2.4"
        // Set Artifactory repositories for dependencies resolution and artifacts deployment.
        rtGradle.deployer repo:'ext-release-local', server: server
        rtGradle.resolver repo:'remote-repos', server: server
    }

    stage('Gradle build') {
        buildInfo = rtGradle.run rootDir: "gradle-examples/4/gradle-example-ci-server/", buildFile: 'build.gradle', tasks: 'clean artifactoryPublish'
    }

    stage('Publish build info') {
        server.publishBuildInfo buildInfo
    }
}
```

# Artifactory Maven Build 
Synopsis
This is a simple demonstration of how to run a Maven build, that resolves dependencies, upload artifacts and publish build info to Artifactory. 
Read the full documentation here.

node {
    // Get Artifactory server instance, defined in the Artifactory Plugin administration page.
    def server = Artifactory.server "SERVER_ID"
    // Create an Artifactory Maven instance.
    def rtMaven = Artifactory.newMavenBuild()
    def buildInfo

    stage('Clone sources') {
        git url: 'https://github.com/jfrogdev/project-examples.git'
    }

    stage('Artifactory configuration') {
        // Tool name from Jenkins configuration
        rtMaven.tool = "Maven-3.3.9"
        // Set Artifactory repositories for dependencies resolution and artifacts deployment.
        rtMaven.deployer releaseRepo:'libs-release-local', snapshotRepo:'libs-snapshot-local', server: server
        rtMaven.resolver releaseRepo:'libs-release', snapshotRepo:'libs-snapshot', server: server
    }

    stage('Maven build') {
        buildInfo = rtMaven.run pom: 'maven-example/pom.xml', goals: 'clean install'
    }

    stage('Publish build info') {
        server.publishBuildInfo buildInfo
    }
}
Configfile Provider Plugin 
configFile Provider plugin enables provisioning of various types of configuration files. Plugin works in such a way as to make the configuration available for the entire duration of the build across all the build agents that are used to execute the build.

Common scenarios that demand the usage of configuration files:

Provide properties that can be consumed by the build tool
Global settings that override local settings
Details of credentials needed to access repos
Inputs to generate binary images that need to be tailored to specific architectures
The example shows simple usage of configFile Provider plugin and howto access it's contents.

```groovy
#!groovy

node {
    stage('configFile Plugin') {

        // 'ID' refers to alpha-numeric value generated automatically by Jenkins.
        // This code snippet assumes that the config file is stored in Jenkins.

        // help to assign the ID of config file to a variable, this is optional 
        // as ID can be used directly within 'configFileProvider' step too.
        def mycfg_file = '<substitute-alpha-numeric-value-cfgfille-here-within-quotes>'

        // whether referencing the config file as ID (directly) or via user-defined 
        // variable, 'configFileProvider' step enables access to the config file
        // via 'name' given for the field, 'variable:'
        configFileProvider([configFile(fileId: mycfg_file, variable: 'PACKER_OPTIONS')]) {
            echo " =========== ^^^^^^^^^^^^ Reading config from pipeline script "
            sh "cat ${env.PACKER_OPTIONS}"
            echo " =========== ~~~~~~~~~~~~ ============ "
 
            // Access to config file opens up other possibilities like
            // passing on the configuration to an external script for other tasks, like,
            // for example, to set generic options that can be used for generating 
            // binary images using packer.
            echo " =========== ^^^^^^^^^^^^ Reading config via Python... "
            sh "python build_image.py ${env.PACKER_OPTIONS}"
            echo " =========== ~~~~~~~~~~~~ ============ "
        }
    }
}
```

# External Workspace Manager 
Synopsis
Shows how to allocate the same workspace on multiple nodes using the External Workspace Manager Plugin.

Prerequisites
Before using this script, you must configure several prerequisites. A starting guide may be found in the
prerequisites section, from the plugin's documentation.

Documentation
Additional examples can be found on the plugin's documentation page, along with all the available features.

// allocate a Disk from the Disk Pool defined in the Jenkins global config
def extWorkspace = exwsAllocate 'diskpool1'

// on a node labeled 'linux', perform code checkout and build the project
node('linux') {
    // compute complete workspace path, from current node to the allocated disk
    exws(extWorkspace) {
        // checkout code from repo
        checkout scm
        // build project, but skip running tests
        sh 'mvn clean install -DskipTests'
    }
}

// on a different node, labeled 'test', perform testing using the same workspace as previously
// at the end, if the build have passed, delete the workspace
node('test') {
    // compute complete workspace path, from current node to the allocated disk
    exws(extWorkspace) {
        try {
            // run tests in the same workspace that the project was built
            sh 'mvn test'
        } catch (e) {
            // if any exception occurs, mark the build as failed
            currentBuild.result = 'FAILURE'
            throw e
        } finally {
            // perform workspace cleanup only if the build have passed
            // if the build has failed, the workspace will be kept
            cleanWs cleanWhenFailure: false
        }
    }
}
Get Build Cause 
Synopsis
Shows how to get the Cause(s) of a Pipeline build from within the Pipeline script.

Credit
Based on Stackoverflow answer at http://stackoverflow.com/questions/33587927/how-to-get-cause-in-workflow

// There is no direct access to the build Causes from the Pipeline, but you can
// get this by using the `currentBuild.rawBuild` variable, as shown below.

// Get all Causes for the current build
def causes = currentBuild.rawBuild.getCauses()

// Get a specific Cause type (in this case the user who kicked off the build),
// if present.
def specificCause = currentBuild.rawBuild.getCause(hudson.model.Cause$UserIdCause)

// If you see errors regarding 'Scripts not permitted to use method...' approve 
// these scripts at JENKINS_URL/scriptApproval/ - the UI shows the blocked methods 

// See the Javadoc for Cause for more information on what's in Causes, etc at:
// http://javadoc.jenkins-ci.org/hudson/model/class-use/Cause.html
Gitcommit 
Synopsis
Demonstrate how to expose the git_commit to a Pipeline job.

Background
The git plugin exposes some environment variables to a freestyle job that are not currently exposed to a Pipeline job. Here's how to recover that ability using a git command and Pipeline's sh step.

// These should all be performed at the point where you've
// checked out your sources on the agent. A 'git' executable
// must be available.
// Most typical, if you're not cloning into a sub directory
gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
// short SHA, possibly better for chat notifications, etc.
shortCommit = gitCommit.take(6)
Gitcommit_changeset 
Synopsis
Demonstrate how to retrieve the changeset associated with a git commit to a Pipeline job.

// This should be performed at the point where you've
// checked out your sources on the agent. A 'git' executable
// must be available.
// Most typical, if you're not cloning into a sub directory
// and invoke this in the context of a directory with .git/
// Along with SHA-1 id of the commit, it will be useful to retrieve changeset associated with that commit
// This command results in output indicating several one of these and the affected files:
// Added (A), Copied (C), Deleted (D), Modified (M), Renamed (R)
commitChangeset = sh(returnStdout: true, script: 'git diff-tree --no-commit-id --name-status -r HEAD').trim()
Ircnotify Commandline 
Synopsis
Send a notification to an IRC channel

Background
The IRC protocol is simple enough that you can use a pipeline shell step and nc to send a message to an irc room. You will need to customize the script to use the actual room, server, and authentication details.

stage "notify"

//
// Modify the channel, message etc as needed.
// Some IRC servers require authentication. 
// This specific example does not with the current settings on freenode.
//
node {
    
    sh ''' 
        MSG='This is the message here'
        SERVER=irc.freenode.net
        CHANNEL=#mictest
        USER=mic2234test
    
        (
        echo NICK $USER
        echo USER $USER 8 * : $USER
        sleep 1
        #echo PASS $USER:$MYPASSWORD                                                                                                                                                       
        echo "JOIN $CHANNEL"
        echo "PRIVMSG $CHANNEL" :$MSG
        echo QUIT
        ) | nc $SERVER 6667
        
    '''
    
}
Jobs In Parallel 
This code snippet will run the same job multiple times in parallel a usecase of that is, for example, a system test or load test that requires several workers with heavy i/o or compute. it allows you to run each worker on a different machine to distribute the i/o or compute

// in this array we'll place the jobs that we wish to run
def branches = [:]

//running the job 4 times concurrently
//the dummy parameter is for preventing mutation of the parameter before the execution of the closure.
//we have to assign it outside the closure or it will run the job multiple times with the same parameter "4"
//and jenkins will unite them into a single run of the job

for (int i = 0; i < 4; i++) {
  def index = i //if we tried to use i below, it would equal 4 in each job execution.
  branches["branch${i}"] = {
//Parameters:
//param1 : an example string parameter for the triggered job.
//dummy: a parameter used to prevent triggering the job with the same parameters value.
//       this parameter has to accept a different value each time the job is triggered.
    build job: 'freestyle', parameters: [
      string(name: 'param1', value:'test_param'),
      string(name:'dummy', value: "${index}")]
  }
}
parallel branches

# Load From File 
Synopsis
A very simple example demonstrating how the load method allows you to read in Groovy files from disk or from the web and then call the code in them.

```groovy
node {
    // Load the file 'externalMethod.groovy' from the current directory, into a variable called "externalMethod".
    def externalMethod = load("externalMethod.groovy")

    // Call the method we defined in externalMethod.
    externalMethod.lookAtThis("Steve")

    // Now load 'externalCall.groovy'.
    def externalCall = load("externalCall.groovy")

    // We can just run it with "externalCall(...)" since it has a call method.
    externalCall("Steve")
}
#!groovy
/*
   Instead of duplicating a lot of build related code in each repo include the common one from this file using the command below:

   Don't forget to put configure GITHUB_TOKEN inside Jenkins as it is a very bad idea to include it inside your code.
*/

apply from: 'https://raw.githubusercontent.com/org-name/repo-name/master/subfolder/Jenkinsfile?token=${env.GITHUB_TOKEN}'
// Methods in this file will end up as object methods on the object that load returns.
def lookAtThis(String whoAreYou) {
    echo "Look at this, ${whoAreYou}! You loaded this from another file!"
}

return this;
// If there's a call method, you can just load the file, say, as "foo", and then invoke that call method with foo(...) 
def call(String whoAreYou) {
    echo "Now we're being called more magically, ${whoAreYou}, thanks to the call(...) method."
}

return this;
```

# Maven And Jdk Specific Version 
Synopsis
An example showing how to build a standard maven project with specific versions for Maven and the JDK.

It shows how to use the withEnv step to define the right PATH to use the tools.

Caveats
in tool 'thetool', the thetool string must match a defined tool in your Jenkins installation.
// Advice: don't define M2_HOME in general. Maven will autodetect its root fine.
withEnv(["JAVA_HOME=${ tool 'jdk-1.8.0_64bits' }", "PATH+MAVEN=${tool 'maven-3.2.1'}/bin:${env.JAVA_HOME}/bin"]) {

    // Apache Maven related side notes:
    // --batch-mode : recommended in CI to inform maven to not run in interactive mode (less logs)
    // -V : strongly recommended in CI, will display the JDK and Maven versions in use.
    //      Very useful to be quickly sure the selected versions were the ones you think.
    // -U : force maven to update snapshots each time (default : once an hour, makes no sense in CI).
    // -Dsurefire.useFile=false : useful in CI. Displays test errors in the logs directly (instead of
    //                            having to crawl the workspace files to see the cause).
    sh "mvn --batch-mode -V -U -e clean deploy -Dsurefire.useFile=false"

}
Parallel From Grep 
Synopsis
An example showing how to search for a list of existing jobs and triggering all of them in parallel.

Caveats
Calling other jobs is not the most idiomatic way to use the Worflow DSL, however, the chance of re-using existing jobs is always welcome under certain circumstances.
Due to limitations in Workflow - i.e., JENKINS-26481 - it's not really possible to use Groovy closures or syntax that depends on closures, so you can't do the Groovy standard of using .collectEntries on a list and generating the steps as values for the resulting entries. You also can't use the standard Java syntax for For loops - i.e., "for (String s: strings)" - and instead have to use old school counter-based for loops.
There is no need for the generation of the step itself to be in a separate method. I've opted to do so here to show how to return a step closure from a method.
import jenkins.model.*

// While you can't use Groovy's .collect or similar methods currently, you can
// still transform a list into a set of actual build steps to be executed in
// parallel.

def stepsForParallel = [:]

// Since this method uses grep/collect it needs to be annotated with @NonCPS
// It returns a simple string map so the workflow can be serialized
@NonCPS
def jobs(jobRegexp) {
  Jenkins.instance.getAllItems()
         .grep { it.name ==~ ~"${jobRegexp}"  }
         .collect { [ name : it.name.toString(),
                      fullName : it.fullName.toString() ] }
}

j = jobs('test-(dev|stage)-(unit|integration)')
for (int i=0; i < j.size(); i++) {
    stepsForParallel["${j[i].name}"] = transformIntoStep(j[i].fullName)
}

// Actually run the steps in parallel - parallel takes a map as an argument,
// hence the above.
parallel stepsForParallel

// Take the string and echo it.
def transformIntoStep(jobFullName) {
    // We need to wrap what we return in a Groovy closure, or else it's invoked
    // when this method is called, not when we pass it to parallel.
    // To do this, you need to wrap the code below in { }, and either return
    // that explicitly, or use { -> } syntax.
    return {
       // Job parameters can be added to this step
       build jobFullName
    }
}
Parallel From List 
Synopsis
An example showing how to take a list of objects and transform it into a map of steps to be run with the parallel command.

Caveats
There is no need for the generation of the step itself to be in a separate method. I've opted to do so here to show how to return a step closure from a method.
// While you can't use Groovy's .collect or similar methods currently, you can
// still transform a list into a set of actual build steps to be executed in
// parallel.

// Our initial list of strings we want to echo in parallel
def stringsToEcho = ["a", "b", "c", "d"]

// The map we'll store the parallel steps in before executing them.
def stepsForParallel = stringsToEcho.collectEntries {
    ["echoing ${it}" : transformIntoStep(it)]
}

// Actually run the steps in parallel - parallel takes a map as an argument,
// hence the above.
parallel stepsForParallel

// Take the string and echo it.
def transformIntoStep(inputString) {
    // We need to wrap what we return in a Groovy closure, or else it's invoked
    // when this method is called, not when we pass it to parallel.
    // To do this, you need to wrap the code below in { }, and either return
    // that explicitly, or use { -> } syntax.
    return {
        node {
            echo inputString
        }
    }
}
Parallel Multiple Nodes 
Synopsis
This is a simple example showing how to succinctly parallel the same build across multiple Jenkins nodes. This is useful for e.g. building the same project on multiple OS platforms.

def labels = ['precise', 'trusty'] // labels for Jenkins node types we will build on
def builders = [:]
for (x in labels) {
    def label = x // Need to bind the label variable before the closure - can't do 'for (label in labels)'

    // Create a map to pass in to the 'parallel' step so we can fire all the builds at once
    builders[label] = {
      node(label) {
        // build steps that should happen on all nodes go here
      }
    }
}

parallel builders
Push Git Repo 
Synopsis
This demonstrates how to push a tag (or branch, etc) to a remote Git repository from within a Pipeline job. The authentication step may vary between projects. This example illustrates injected credentials and also username / password authentication.

Note
If you inject a credential associated with your Git repo, use the Snippet Generator to select the plain Git option and it will return a snippet with this gem:

java stage('Checkout') { git branch: 'lts-1.532', credentialsId: '82aa2d26-ef4b-4a6a-a05f-2e1090b9ce17', url: 'git@github.com:jenkinsci/maven-plugin.git' } This is not ideal - there is an open JIRA, https://issues.jenkins-ci.org/browse/JENKINS-28335, for getting the GitPublisher Jenkins functionality working with Pipeline.

Credit
Based on Stackoverflow answer at http://stackoverflow.com/questions/33570075/tag-a-repo-from-a-jenkins-workflow-script Injected credentials gist at https://gist.github.com/blaisep/eb8aa720b06eff4f095e4b64326961b5#file-jenkins-pipeline-git-cred-md

Slacknotify 
Synopsis
Use a slack webhook to send an arbitrary message.

Background
Using a combination of groovy and curl from shell, send a message to slack for notifications. Some of the more friendly groovy http libs like HTTPBuilder are not easily available. However, we can use groovy's built in json handling to build up the request and ship it to a command line curl easily enough.

This will require that you configure a webhook integration in slack (not the Jenkins specific configuration.)

import groovy.json.JsonOutput
// Add whichever params you think you'd most want to have
// replace the slackURL below with the hook url provided by
// slack when you configure the webhook
def notifySlack(text, channel) {
    def slackURL = 'https://hooks.slack.com/services/xxxxxxx/yyyyyyyy/zzzzzzzzzz'
    def payload = JsonOutput.toJson([text      : text,
                                     channel   : channel,
                                     username  : "jenkins",
                                     icon_emoji: ":jenkins:"])
    sh "curl -X POST --data-urlencode \'payload=${payload}\' ${slackURL}"
}
Timestamper Wrapper 
Synopsis
This shows usage of a simple build wrapper, specifically the Timestamper plugin, which adds timestamps to the console output.

// This shows a simple build wrapper example, using the Timestamper plugin.
node {
    // Adds timestamps to the output logged by steps inside the wrapper.
    timestamps {
        // Just some echoes to show the timestamps.
        stage "First echo"
        echo "Hey, look, I'm echoing with a timestamp!"

        // A sleep to make sure we actually get a real difference!
        stage "Sleeping"
        sleep 30

        // And a final echo to show the time when we wrap up.
        stage "Second echo"
        echo "Wonder what time it is now?"
    }
}
Trigger Job On All Nodes 
Synopsis
The example shows how to trigger jobs on all Jenkins nodes from Pipeline.

Summary: * The script uses NodeLabel Parameter plugin to pass the job name to the payload job. * Node list retrieval is being performed using Jenkins API, so it will require script approvals in the Sandbox mode

// The script triggers PayloadJob on every node.
// It uses Node and Label Parameter plugin to pass the job name to the payload job.
// The code will require approval of several Jenkins classes in the Script Security mode
def branches = [:]
def names = nodeNames()
for (int i=0; i<names.size(); ++i) {
  def nodeName = names[i];
  // Into each branch we put the pipeline code we want to execute
  branches["node_" + nodeName] = {
    node(nodeName) {
      echo "Triggering on " + nodeName
      build job: 'PayloadJob', parameters: [
              new org.jvnet.jenkins.plugins.nodelabelparameter.NodeParameterValue
                  ("TARGET_NODE", "description", nodeName)
          ]
    }
  }
}

// Now we trigger all branches
parallel branches

// This method collects a list of Node names from the current Jenkins instance
@NonCPS
def nodeNames() {
  return jenkins.model.Jenkins.instance.nodes.collect { node -> node.name }
}
Unstash Different Dir 
Synopsis
This is a simple demonstration of how to unstash to a different directory than the root directory, so that you can make sure not to overwrite directories or files, etc.

// First we'll generate a text file in a subdirectory on one node and stash it.
stage "first step on first node"

// Run on a node with the "first-node" label.
node('first-node') {
    // Make the output directory.
    sh "mkdir -p output"

    // Write a text file there.
    writeFile file: "output/somefile", text: "Hey look, some text."

    // Stash that directory and file.
    // Note that the includes could be "output/", "output/*" as below, or even
    // "output/**/*" - it all works out basically the same.
    stash name: "first-stash", includes: "output/*"
}

// Next, we'll make a new directory on a second node, and unstash the original
// into that new directory, rather than into the root of the build.
stage "second step on second node"

// Run on a node with the "second-node" label.
node('second-node') {
    // Run the unstash from within that directory!
    dir("first-stash") {
        unstash "first-stash"
    }

    // Look, no output directory under the root!
    // pwd() outputs the current directory Pipeline is running in.
    sh "ls -la ${pwd()}"

    // And look, output directory is there under first-stash!
    sh "ls -la ${pwd()}/first-stash"
}