

* [jenkins2 pipeline插件的10个最佳实践 - iTech - 博客园 ](http://www.cnblogs.com/itech/p/5678643.html)

jenkins pipeline的10个最佳实践。

文章来自：http://www.ciandcd.com
文中的代码来自可以从github下载： https://github.com/ciandcd

翻译自：https://www.cloudbees.com/blog/top-10-best-practices-jenkins-pipeline-plugin

 

1. 使用最新的jenkins pipeline插件[Jenkins Pipeline suite of plugins](https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Plugin)， 而不使用旧的类似功能插件，例如不使用旧的build pipeline plugin 或者旧的buildflow plugin。

新的pipeline插件是完全不同于旧的插件，新的pipeline job不同于旧的freestyle job，新的pipeline job可以不受jenkins master重启的影响，可以暂停重启。 新的pipeline job还可以实现更复杂的持续发布流程。

更多pipeline的学习，可以参考 https://jenkins.io/solutions/pipeline/。

 

2.  通过groovy脚本实现pipeline

使用groovy实现的pipeline流程，可以将对应的groovy脚本存储在文件Jenkinsfile， 且实现与源代码一起的版本控制。

Jenkinsfile与源代码一起版本控制，使得整个pipeline流程和源代码一起可重现。 通过Jenkinsfile实现的pipeline job，可以更容易地支持多个分支multi-branch, 更容易地支持组织和团队（GitHub organiztion and BitBucket Team）里的多个项目。

最好在groovy脚本Jenkinsfile的第一行增加#!groovy​， 使得各种ide工具或web page能够支持groovy的语法高亮。



 

3. 尽可能地在stage里实现所有的任务

所有pipeline里非配置的任务最好在stage块里实现。通过stage使得pipeline里所有的任务被组织为多个stage，每个stage都是一组相关的任务。

例如：

stage 'build'

//build

stage 'test'

//test

pipeline view 插件使得 pipeline的stage的view和monitor更加的清楚。



 

4. 所有资源消耗的操作都应该放到node上执行

默认地，Jenkinsfile里的脚本在jenkins master上执行，如果资源消耗的操作都在master上执行的话将影响jenkins master的运行。 所以任何资源消耗的操作都应该放到node中被分布到agent上执行，例如从git server clone代码，java代码的编译等都应该在node中执行。

stage 'build'
node{
    checkout scm
    sh 'mvn clean install'
}

 

5. 尽可能地使用parallel来使得任务并行地执行

将任务并行后，使得整个job的流程更够更快地完成，开发人员能够更早地得到结果。

parallel 'shifting':{
    //everything
}, 'left':{
    //I can
}

对于unit的并行执行，可以查看插件Parallel Test Executor plugin，更多详细介绍查看Parallel Test Execution on the CloudBees Blog。

 

6. 并行的任务运行在不同的node上

对于并行的任务使用不同的node，使得并行的任务不相互影响，能够实现真正的并行执行。

parallel 'integration-tests':{
    node('mvn-3.3'){ ... }
}, 'functional-tests':{
    node('selenium'){ ... }
}

 

7. 不要在node里使用input

input 能够暂停pipeline的执行等待用户的approve（自动化或手动），通常地approve需要一些时间等待用户相应。 如果在node里使用input将使得node本身和workspace被lock， 不能够被别的job使用。

所以一般在node外面使用input。

stage 'deployment'
input 'Do you approve deployment?'
node{
    //deploy the things
}

 

8. inputs应该封装在timeout中。

pipeline可以很容易地使用timeout来对step设定timeout时间。对于input我们也最好使用timeout。

timeout(time:5, unit:'DAYS') {
    input message:'Approve deployment?', submitter: 'it-ops'
}

 

9. 应该使用withEnv来修改环境变量

不建议使用env来修改全局的环境变量，这样后面的groovy脚本也将被影响。

一般使用withEnv来修改环境变量，变量的修改只在withEnv的块内起作用。

withEnv(["PATH+MAVEN=${tool 'm3'}/bin"]) {
    sh "mvn clean verify"
}

 

10.尽量使用stash来实现stage/node间共享文件，不要使用archive

在stash被引入pipeline DSL前，一般使用archive来实现node或stage间文件的共享。 在stash引入后，最好使用stash/unstash来实现node/stage间文件的共享。例如在不同的node/stage间共享源代码。

archive用来实现更长时间的文件存储。

stash excludes: 'target/', name: 'source'
unstash 'source'