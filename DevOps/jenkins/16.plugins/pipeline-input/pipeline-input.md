Pipeline: Input Step 
https://jenkins.io/doc/pipeline/steps/pipeline-input-step/
Jenkins Plugins 
https://plugins.jenkins.io/pipeline-input-step
Pipeline: How to manage user inputs – CloudBees Support 
https://support.cloudbees.com/hc/en-us/articles/204986450-Pipeline-How-to-manage-user-inputs
cloudbees - How do we access Jenkins workflow input parameter values? - Stack Overflow 
https://stackoverflow.com/questions/29906998/how-do-we-access-jenkins-workflow-input-parameter-values


# pipeline-plugin/TUTORIAL.md at master · jenkinsci/pipeline-plugin 
https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md

Pausing: Flyweight vs. Heavyweight Executors

Pause the script to take a better look at what is happening:

node('remote') {
  input 'Ready to go?'
  // rest as before
}
The input step pauses Pipeline execution. Its default message parameter gives a prompt, which is shown to a human. You can, optionally, request information back.

When you run a new build, you see:

Running: Input
Ready to go?
Proceed or Abort
If you click Proceed, the build will proceed as before. First, go to the Jenkins main page and look at the Build Executor Status widget.

You will see an unnumbered entry under master named jobname #10; executors #1 and #2 on the master are idle.
You will also see an entry under your agent, in a numbered row (probably #1) called Building part of jobname #10.
Why are there two executors consumed by one Pipeline build?

Every Pipeline build itself runs on the master, using a flyweight executor — an uncounted slot that is assumed to not take any significant computational power.
This executor represents the actual Groovy script, which is almost always idle, waiting for a step to complete.
Flyweight executors are always available.
When you run a node step:

A regular heavyweight executor is allocated on a node (usually an agent) matching the label expression, as soon as one is available. This executor represents the real work being done on the node.

If you start a second build of the Pipeline while the first is still paused with the one available executor, you will see both Pipeline builds running on master. But only the first will have grabbed the one available executor on the agent; the other part of jobname #11 will be shown in Build Queue (1). (shortly after, the console log for the second build will note that it is still waiting for an available executor).

To finish up, click the ▾ beside either executor entry for any running Pipeline and select Paused for Input, then click Proceed (you can also click the link in the console output).


# Jenkins Pipeline: "input" step blocks executor - Stack Overflow 
https://stackoverflow.com/questions/37831386/jenkins-pipeline-input-step-blocks-executor

node() {
  stage 'Build to Stage' {
    sh '# ...'
  }

  stage 'Promotion' {
    timeout(time: 1, unit: 'HOURS') {
      input 'Deploy to Production?'
    }
  }

  stage 'Deploy to Production' {
    sh '# ...'
  }
}