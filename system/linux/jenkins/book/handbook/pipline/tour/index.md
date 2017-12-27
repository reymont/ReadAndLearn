

* [Jenkins Documentation ](https://jenkins.io/doc/)

# Jenkins 文档
Jenkins是一个自包含的、开放源码的自动化服务器，可用于自动化各种任务，如构建、测试和部署软件。Jenkins可以通过系统安装包，Docker，甚至是在任何安装java运行环境的机器上独立运行。

# 指南
这指南将使用“独立运行”的方式来运行Jenkins发布包，需要java 8。推荐使用RAM超过512MB的系统。

1. [下载 Jenkins](http://mirrors.jenkins.io/war-stable/latest/jenkins.war).
2. 打开控制台并执行`java -jar jenkins.war --httpPort=8080`
3. 在浏览器中输入`http://localhost:8080`，按照指引完成安装.
4. 很多Pipeline样例需要在同一台电脑[安装Docker](https://docs.docker.com/engine/installation).

安装完成后，开始让Jenkins工作并创建管道。

Jenkins Pipeline is a suite of plugins which supports implementing and integrating continuous delivery pipelines into Jenkins. Pipeline provides an extensible set of tools for modeling simple-to-complex delivery pipelines "as code".
Jenkins Pipeline是一套插件，支持实现和集成连续交付管道到Jenkins。管道提供了一套可扩展的工具，用于将简单到复杂的交付管道建模为“代码”。

A Jenkinsfile is a text file that contains the definition of a Jenkins Pipeline and is checked into source control. [1] This is the foundation of "Pipeline-as-Code"; treating the continuous delivery pipeline a part of the application to be version and reviewed like any other code. Creating a Jenkinsfile provides a number of immediate benefits:
一个Jenkinsfile是定义了一个Jenkins Pipeline，并签入到源代码控制的文本文件[1]。这是“管道作为代码”的基础；将连续交付管道作为应用程序的一部分进行处理，并像其他代码一样进行审查。创建Jenkinsfile提供一些直接的好处：

* Automatically create Pipelines for all Branches and Pull Requests
* Code review/iteration on the Pipeline
* Audit trail for the Pipeline
* Single source of truth [2] for the Pipeline, which can be viewed and edited by multiple members of the project.

定义一个管道的语法，可以是Web UI或者是jenkinsfile。通常情况下，纳入版本控制的 Jenkinsfile是最佳实践。

继续一下一节“[创建第一个Pipline](https://jenkins.io/doc/pipeline/tour/hello-world)”

1. https://en.wikipedia.org/wiki/Source_control_management
2. https://en.wikipedia.org/wiki/Single_Source_of_Truth