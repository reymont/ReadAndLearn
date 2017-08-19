
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [阅读](#阅读)
* [Pipeline](#pipeline)
* [What is Pipeline?](#what-is-pipeline)
	* [什么是jenkins2的pipeline？](#什么是jenkins2的pipeline)
		* [jenkins1的基本用法：](#jenkins1的基本用法)
	* [管道代码(Pipeline as Code)](#管道代码pipeline-as-code)
* [Why Pipeline?](#why-pipeline)
* [Pipeline Terms](#pipeline-terms)
	* [Step](#step)
	* [Node](#node)
	* [Stage](#stage)

<!-- /code_chunk_output -->
# 阅读

* [Pipeline ](https://jenkins.io/doc/book/pipeline/)
* [BuildRelease - 随笔分类 - iTech - 博客园 ](http://www.cnblogs.com/itech/category/245402.html)
* [jenkins2 pipeline介绍 - iTech - 博客园 ](http://www.cnblogs.com/itech/p/5621257.html)
* [ciandcd ](https://github.com/ciandcd)
* [ciandcd/awesome-ciandcd: continuous integration and continuous delivery ](https://github.com/ciandcd/awesome-ciandcd)
* [ciandcd/jenkins-awesome: jenkins example ](https://github.com/ciandcd/jenkins-awesome)


# Pipeline 

* Chapter Sub-Sections
  * Getting Started with Pipeline
  * Using a Jenkinsfile
  * Branches and Pull Requests
  * Using Docker with Pipeline
  * Extending with Shared Libraries
  * Pipeline Development Tools
  * Pipeline Syntax

* Table of Contents
  * What is Pipeline?
  * Why Pipeline?
  * Pipeline Terms

本章将涵盖Jenkins Pipeline的各个方面，从运行管道到编写管道代码，甚至扩展管道本身。

本章旨在为所有Jenkins用户提供指引，但初学者可能需要参考“[Using Jenkins](https://jenkins.io/doc/book/using/)”的来理解本文所涵盖的主题。

如果您还不熟悉基本的Jenkins术语和特性，请从[Getting Started with Jenkins](https://jenkins.io/doc/book/getting-started/)。

# What is Pipeline?
Jenkins Pipeline是一套插件，支持实现和集成连续交付管道到Jenkins。管道提供了一组可扩展的工具，通过Pipeline DSL将简单到复杂的交付管道建模为“代码”。[1]

## 什么是jenkins2的pipeline？
 
jenkins的实现是标准的master/slave模式，用户与master交互，master将job分布到slave上运行。
jenkins的基本概念：
1. master, 也就是jenkins的server，是jenkins的核心，主要负责job的定时运行，将job分发到agent运行，和对job运行状态的监控。
2. agent/slave/node，agent是相对于master的概念，主要作用是监听master的指令，然后运行job。
3. executor，executor是虚拟的概念，每一个agent都可以设置executor的数量，表示可以同时运行的job的数量。
 
### jenkins1的基本用法：
一般使用free style的job类型，在job的里面调用一些脚本和插件来实现整个持续集成的过程，

一般是将整个job发布到某台机器上运行。`缺点是job的配置分布在脚本和插件中，配置不够集中`，导致监控的时候log不容易查找。`实现整个持续集成发布流程需要多个jobs来实现`。

## 管道代码(Pipeline as Code)

通常情况下，这种“管道代码”可以写成一个Jenkinsfile，纳入项目的源码库，例如：
```groovy
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any 

    stages {
        stage('Build') { 
            steps { 
                sh 'make' 
            }
        }
        stage('Test'){
            steps {
                sh 'make check'
                junit 'reports/**/*.xml' 
            }
        }
        stage('Deploy') {
            steps {
                sh 'make publish'
            }
        }
    }
}
```
Toggle Scripted Pipeline (Advanced)

```groovy
Jenkinsfile (Scripted Pipeline)
node {
    stage('Build') {
        sh 'make'
    }

    stage('Test') {
        sh 'make check'
        junit 'reports/**/*.xml'
    }

    stage('Deploy') {
        sh 'make publish'
    }
}
```

* agent indicates that Jenkins should allocate an executor and workspace for this part of the Pipeline.
* stage describes a stage of this Pipeline.
* steps describes the steps to be run in this stage
* sh executes the given shell command
* junit is a Pipeline step provided by the JUnit plugin for aggregating test reports.

# Why Pipeline?
Jenkins is, fundamentally, an automation engine which supports a number of automation patterns. Pipeline adds a powerful set of automation tools onto Jenkins, supporting use cases that span from simple continuous integration to comprehensive continuous delivery pipelines. By modeling a series of related tasks, users can take advantage of the many features of Pipeline:

* Code: Pipelines are implemented in code and typically checked into source control, giving teams the ability to edit, review, and iterate upon their delivery pipeline.
* Durable: Pipelines can survive both planned and unplanned restarts of the Jenkins master.
* Pausable: Pipelines can optionally stop and wait for human input or approval before continuing the Pipeline run.
Versatile: Pipelines support complex real-world continuous delivery requirements, including the ability to fork/join, loop, and perform work in parallel.
* Extensible: The Pipeline plugin supports custom extensions to its DSL [1] and multiple options for integration with other plugins.

pipeline的设计理念是实现基于groovy脚本，灵活，可扩展的持续发布（CD）工作流。
pipeline的功能和优点：
1. Durable持久性：在jenkins的master按计划和非计划的重启后，pipeline的job仍然能够工作，不受影响。其实理解起来也很简单，jenkins的master和agent通过ssh连接，如果你知道nohup或disown的话，就可以理解为啥master的重启不会影响agent上的job继续运行。之前已经有类似的插件[long-running-build-plugin](https://www.cloudbees.com/products/cloudbees-jenkins-platform/enterprise-edition/features/long-running-build-plugin)。
2. Pausable可暂停性：pipeline基于groovy可以实现job的暂停和等待用户的输入或批准然后继续执行。
3. Code更灵活的并行执行，更强的依赖控制，通过groovy脚本可以实现step，stage间的并行执行，和更复杂的相互依赖关系。
4. Extensible可扩展性：通过groovy的编程更容易的扩展插件。

While Jenkins has always allowed rudimentary forms of chaining Freestyle Jobs together to perform sequential tasks, [2] Pipeline makes this concept a first-class citizen in Jenkins.

Building on the core Jenkins value of extensibility, Pipeline is also extensible both by users with Pipeline Shared Libraries and by plugin developers. [3]]

The flowchart below is an example of one continuous delivery scenario easily modeled in Jenkins Pipeline:

realworld pipeline flow
Figure 1. Pipeline Flow

# Pipeline Terms

## Step

一个单一的任务；告诉Jenkins该做什么。例如，要执行shell命令，请使用sh step：`sh 'make'`。当插件扩展管道DSL时，这通常意味着插件实现了一个新的步骤。

step，其实跟jenkins1中的概念一样， 是jenkins里job中的最小单位，可以认为是一个脚本的调用和一个插件的调用。

## Node
Most work a Pipeline performs is done in the context of one or more declared node steps. Confining the work inside of a node step does two things:
管道执行的大部分工作都是在一个或多个已声明的节点步骤的上下文中完成的。限制节点步骤中的工作有两件事：

* 通过在Jenkins队列中添加项来调度块中包含的step。只要在节点上的执行器是空闲的，step就会运行。
* 创建一个工作区（特定于该管道的目录），可以在源代码管理中签出的文件上完成工作。

> Depending on your Jenkins configuration, some workspaces may not get automatically cleaned up after a period of inactivity. See tickets and discussion linked from JENKINS-2111 for more information.

* node， 是pipleline里groovy的一个概念，node可以给定参数用来选择agent，node里的steps将会运行在node选择的agent上。这里与jenkins1的区别是， job里可以有多个node，将job的steps按照需求运行在不同的机器上。例如一个job里有好几个测试集合需要同时运行在不同的机器上。

## Stage

Stage是定义管道上不同的子集的执行步骤，例如：“构建”、“测试”和“部署”，这是许多插件用来可视化或呈现Jenkins Pipeline状态/进度的步骤。[4]

stage，是pipeline里groovy里引入的一个虚拟的概念，是一些step的集合，通过stage我们可以将job的所有steps划分为不同的stage，使得整个job像管道一样更容易维护。pipleline还有针对stage改进过的view，使得监控更清楚。

1. [Domain-Specific Language](https://en.wikipedia.org/wiki/Domain-specific_language)
2. Additional plugins have been used to implement complex behaviors utilizing Freestyle Jobs such as the Copy Artifact, Parameterized Trigger, and Promoted Builds plugins
3. plugin:github-organization-folder[GitHub Organization Folder plugin
4. [Blue Ocean](https://jenkins.io/projects/blueocean), [Pipeline Stage View plugin](https://wiki.jenkins-ci.org/display/JENKINS/Pipeline+Stage+View+Plugin)
