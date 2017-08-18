

* [Jenkins Documentation ](https://jenkins.io/doc/)

# Jenkins 文档
Jenkins是一个自包含的、开放源码的自动化服务器，可用于自动化各种任务，如构建、测试和部署软件。Jenkins可以通过系统安装包，Docker，甚至是在任何安装java运行环境的机器上独立运行。

# 指南
这指南将使用“独立运行”的方式来运行Jenkins发布包，需要java 8。推荐使用RAM超过512MB的系统。

1. [下载 Jenkins](http://mirrors.jenkins.io/war-stable/latest/jenkins.war).
2. 打开控制台并执行`java -jar jenkins.war --httpPort=8080`
3. 在浏览器中输入`http://localhost:8080`，按照指引完成安装.
4. 很多Pipeline样例需要在同一台电脑[安装Docker](https://docs.docker.com/engine/installation).

When the installation is complete, start putting Jenkins to work and create a Pipeline.

Jenkins Pipeline is a suite of plugins which supports implementing and integrating continuous delivery pipelines into Jenkins. Pipeline provides an extensible set of tools for modeling simple-to-complex delivery pipelines "as code".

A Jenkinsfile is a text file that contains the definition of a Jenkins Pipeline and is checked into source control. [1] This is the foundation of "Pipeline-as-Code"; treating the continuous delivery pipeline a part of the application to be version and reviewed like any other code. Creating a Jenkinsfile provides a number of immediate benefits:

Automatically create Pipelines for all Branches and Pull Requests
Code review/iteration on the Pipeline
Audit trail for the Pipeline
Single source of truth [2] for the Pipeline, which can be viewed and edited by multiple members of the project.
While the syntax for defining a Pipeline, either in the web UI or with a Jenkinsfile, is the same, it’s generally considered best practice to define the Pipeline in a Jenkinsfile and check that in to source control.

Continue to "Create your first Pipeline"

1. https://en.wikipedia.org/wiki/Source_control_management
2. https://en.wikipedia.org/wiki/Single_Source_of_Truth