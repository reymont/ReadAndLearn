


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Jenkins持续集成 - 管道详解](#jenkins持续集成-管道详解)
* [管道名词](#管道名词)
* [定义管道](#定义管道)
	* [Web UI方式](#web-ui方式)
	* [Jenkinsfile方式](#jenkinsfile方式)
	* [Poll SCM 触发器](#poll-scm-触发器)
	* [Push触发器](#push触发器)
* [使用Jenkinsfile](#使用jenkinsfile)
	* [部署三阶段](#部署三阶段)
	* [环境变量](#环境变量)
	* [使用多个agent](#使用多个agent)
	* [Multibranch Pipeline](#multibranch-pipeline)
* [Pipeline语法](#pipeline语法)
	* [Sections](#sections)
		* [post](#post)
		* [stages](#stages)
		* [steps](#steps)
	* [Directives](#directives)
		* [agent](#agent)
		* [environment](#environment)
		* [options](#options)
		* [parameters](#parameters)
		* [triggers](#triggers)
		* [stage](#stage)
		* [tools](#tools)
		* [内置条件](#内置条件)
	* [Steps](#steps-1)
	* [两种Pipeline比较](#两种pipeline比较)
* [Blue Ocean](#blue-ocean)
	* [安装](#安装)
	* [启动](#启动)
	* [Pipeline编辑器](#pipeline编辑器)
* [FAQ](#faq)

<!-- /code_chunk_output -->

---

* [Jenkins持续集成 - 管道详解 | 会飞的污熊 ](https://www.xncoding.com/2017/03/22/fullstack/jenkins02.html)
* [yidao620c (XiongNeng) ](https://github.com/yidao620c)

# Jenkins持续集成 - 管道详解
 发表于 `2017-03-22` |  分类于 fullstack |  阅读次数 3838

前面一篇介绍了Jenkins的入门安装和简单演示，这篇讲解最核心的Pipeline部分。

Jenkins Pipeline 就是一系列的插件集合，可通过组合它们来实现持续集成和交付的功能。 通过Pipeline DSL为我们提供了一个可扩展的工具集，将简单到复杂的逻辑通过代码实现。

通常，我们可以通过编写Jenkinsfile将管道代码化，并且纳入到版本管理系统中。比如：

```groovy
// Declarative //
pipeline {
    agent any ①
    stages {
        stage('Build') { ②
            steps { ③
                sh 'make' ④
            }
        }
        stage('Test'){
            steps {
                sh 'make check'
                junit 'reports/**/*.xml' ⑤
            }
        }
        stage('Deploy') {
            steps {
                sh 'make publish'
            }
        }
    }
}
// Script //
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
① agent 指示Jenkins分配一个执行器和工作空间来执行下面的Pipeline
② stage 表示这个Pipeline的一个执行阶段
③ steps 表示在这个stage中每一个步骤
④ sh 执行指定的命令
⑤ junit 是插件junit[JUnit plugin]提供的一个管道步骤，用来收集测试报告

# 管道名词

几个重要的名词，讲一下它们是什么意思：
* Step 一个简单的执行步骤，比如执行一个sh脚本
* Stage 将你的命令组织成一个更高一层的逻辑单元
* Node 指定这些任务在哪执行

Stage和Step可以放到一个Node下面执行，不指定就默认在master节点上面执行。 另外Node和Step也能组合成一个Stage。

# 定义管道

有两种定义管道的方式，一种是通过Web UI来定义，一种是直接写Jenkinsfile。推荐后面一种，因为可以纳入版本管理系统。

## Web UI方式

这里先介绍第一种方式，通过Web UI，首先点击“新建”：

填写一个名字，然后选择Pipeline

点击“OK”后，在Script中写一个简单的命令：

保存后，点击左侧的“立即构建”：

然后在“Build History”下面点击“#1”进入此次构建详情，再点击左侧的“Console Output”查看输出：

我们看到了打印出来的“hello world”说明成功运行。

上面的例子演示了通过Web UI创建的一个最基本的管道执行成功的案例。使用2个步骤：

```groovy
// Script //
node { ①
    echo 'Hello World' ②
}
// Declarative not yet implemented //
```
① node 在Jenkins环境中分配一个执行器和工作空间
② echo 在控制台输出一个简单的字符串


## Jenkinsfile方式

上面通过Web UI方式只适用于非常简单的任务，而大型复杂的任务最好采用Jenkinsfile方式并纳入SCM管理。 这次我选择从SCM中的Jenkinsfile来定义管道。

我这里配置了一个git仓库位置，然后我在该项目根目录放一个Jenkinsfile，其实就是我上一篇里演示的。

## Poll SCM 触发器

选择Build Trigger为Poll SCM，定时检查是否有push操作，这里我设置每隔2分钟检查一次。

## Push触发器

这个触发器我更加推荐，因为是实时的，但是需要先配置gitlab的Webhook。

选择`Build when a change is pushed to GitLab. GitLab CI Service URL: http://192.168.217.161:8080/project/scm-example`

复制后面那个URL，然后登录gitlab项目打开项目配置Web Hook，如果没有配置SSL可以将证书检查取消：



增加后可点击下面的测试，上面显示：钩子执行成功：HTTP 200则表示没问题。

然后再来jenkins里面配置push触发器，还能选择你要过滤那些分支，比如我只响应master分支上面的push操作。可以这样：



push钩子的大致流程是这样的：

push代码，Gitlab触发hook，访问Jenkins提供的api
Jenkins Branch Filter系统判断自己需要处理的分支是否有改动，如果有开始构建
运行构建脚本
然后我再来测试下，修改代码，提交后push到远程仓库中，看到效果正常触发了：

> Tips: 每个Jenkinsfile文件都应该以#!groovy为开头第一行

# 使用Jenkinsfile

接下来详细介绍一下怎样编写Jenkinsfile来完成各种复杂的任务。

Pipeline支持两种形式，一种是Declarative管道，一个是Scripted管道。

一个Jenkinsfile就是一个文本文件，里面定义了Jenkins Pipeline。 将这个文本文件放到项目的根目录下面，纳入版本系统。

## 部署三阶段

一般我们的持续交付都有三个部分：Build、Test、Deploy，典型写法：

```groovy
// Declarative //
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh 'make'
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
                /* `make check` returns non-zero on test failures,
                 *  using `true` to allow the Pipeline to continue nonetheless
                 */
                sh 'make check || true' ①
                junit '**/target/*.xml' ②
            }
        }
        stage('Deploy') {
            when {
                expression {
                    /*如果测试失败，状态为UNSTABLE*/
                    currentBuild.result == null || currentBuild.result == 'SUCCESS' ①
                }
            }
            steps {
                echo 'Deploying..'
                sh 'make publish'
            }
        }
    }
}
```

## 环境变量

Jenkins定了很多内置的环境变量，可在文档localhost:8080/pipeline-syntax/globals#env找到， 通过env直接使用它们：

> echo "Running ${env.BUILD_ID} on ${env.JENKINS_URL}"
设置环境变量：

```groovy
// Declarative //
pipeline {
    agent any
    environment {
        CC = 'clang'
    }
    stages {
        stage('Example') {
            environment {
                DEBUG_FLAGS = '-g'
            }
            steps {
                sh 'printenv'
            }
        }
    }
}
```

## 使用多个agent

```groovy
// Declarative //
pipeline {
    agent none
    stages {
        stage('Build') {
            agent any
            steps {
                checkout scm
                sh 'make'
                stash includes: '**/target/*.jar', name: 'app' ①
            }
        }
        stage('Test on Linux') {
            agent { ②
                label 'linux'
            }
            steps {
                unstash 'app' ③
                sh 'make check'
            }
            post {
                always {
                    junit '**/target/*.xml'
                }
            }
        }
        stage('Test on Windows') {
            agent {
                label 'windows'
            }
            steps {
                unstash 'app'
                bat 'make check' ④
            }
            post {
                always {
                    junit '**/target/*.xml'
                }
            }
        }
    }
}
```

上面的例子，在任一台机器上面做Build操作，并通过stash命令保存文件，然后分别在两台agent机器上面做测试。 注意这里所有步骤都是串行执行的。

## Multibranch Pipeline

多分支管道可以让你在同一个项目中，对每个分支定义一个执行管道。Jenkins或自动发现、管理并执行包含Jenkinsfile文件的分支。

这个在前面一篇已经演示过怎样创建这样的Pipeline了，就不再多讲。

# Pipeline语法

先讲Declarative Pipeline，所有声明式管道都必须包含在pipeline块中：

```groovy
pipeline {
    /* insert Declarative Pipeline here */
}
```
块里面的语句和表达式都是Groovy语法，遵循以下规则：

* 最顶层规定就是pipeline { }
* 语句结束不需要分好，一行一条语句
* 块中只能包含Sections, Directives, Steps或者赋值语句
* 属性引用语句被当成是无参方法调用，比如input实际上就是方法input()调用

接下来我详细讲解下`Sections, Directives, Steps`这三个东西

## Sections

Sections在声明式管道中包含一个或多个Directives, Steps

### post

post section 定义了管道执行结束后要进行的操作。支持在里面定义很多Conditions块： always, changed, failure, success 和 unstable。 这些条件块会根据不同的返回结果来执行不同的逻辑。

* always：不管返回什么状态都会执行
* changed：如果当前管道返回值和上一次已经完成的管道返回值不同时候执行
* failure：当前管道返回状态值为”failed”时候执行，在Web UI界面上面是红色的标志
* success：当前管道返回状态值为”success”时候执行，在Web UI界面上面是绿色的标志
* unstable：当前管道返回状态值为”unstable”时候执行，通常因为测试失败，代码不合法引起的。在Web UI界面上面是黄色的标志

```groovy
// Declarative //
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                echo 'Hello World'
            }
        }
    }
    post { ①
        always { ②
            echo 'I will always say Hello again!'
        }
    }
}
```

### stages

由一个或多个stage指令组成，stages块也是核心逻辑的部分。 我们建议对于每个独立的交付部分（比如Build,Test,Deploy）都应该至少定义一个stage指令。比如：

```groovy
// Declarative //
pipeline {
    agent any
    stages { ①
        stage('Example') {
        steps {
            echo 'Hello World'
        }
        }
    }
}
```

### steps

在stage中定义一系列的step来执行命令。

```groovy
// Declarative //
pipeline {
    agent any
    stages {
        stage('Example') {
            steps { ①
                echo 'Hello World'
            }
        }
    }
}
```
## Directives

jenkins中的各种指令

### agent

agent指令指定整个管道或某个特定的stage的执行环境。它的参数可用使用：

any - 任意一个可用的agent
none - 如果放在pipeline顶层，那么每一个stage都需要定义自己的agent指令
label - 在jenkins环境中指定标签的agent上面执行，比如agent { label 'my-defined-label' }
node - agent { node { label 'labelName' } } 和 label一样，但是可用定义更多可选项
docker - 指定在docker容器中运行
dockerfile - 使用源码根目录下面的Dockerfile构建容器来运行

### environment

environment定义键值对的环境变量

```groovy
// Declarative //
pipeline {
    agent any
    environment { ①
        CC = 'clang'
    }
    stages {
        stage('Example') {
            environment { ②
                AN_ACCESS_KEY = credentials('my-prefined-secret-text') ③
            }
            steps {
                sh 'printenv'
            }
        }
    }
}
```

### options

还能定义一些管道特定的选项，介绍几个常用的：

skipDefaultCheckout - 在agent指令中忽略源码checkout这一步骤。
timeout - 超时设置options { timeout(time: 1, unit: 'HOURS') }
retry - 直到成功的重试次数options { retry(3) }
timestamps - 控制台输出前面加时间戳options { timestamps() }

### parameters

参数指令，触发这个管道需要用户指定的参数，然后在step中通过params对象访问这些参数。

```groovy
// Declarative //
pipeline {
    agent any
    parameters {
        string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
    }
    stages {
        stage('Example') {
            steps {
                echo "Hello ${params.PERSON}"
            }
        }
    }
}
```
### triggers

触发器指令定义了这个管道何时该执行，一般我们会将管道和GitHub、GitLab、BitBucket关联， 然后使用它们的webhooks来触发，就不需要这个指令了。如果不适用webhooks，就可以定义两种cron和pollSCM

cron - linux的cron格式triggers { cron('H 4/* 0 0 1-5') }
pollSCM - jenkins的poll scm语法，比如triggers { pollSCM('H 4/* 0 0 1-5') }
```groovy
// Declarative //
pipeline {
    agent any
    triggers {
        cron('H 4/* 0 0 1-5')
    }
    stages {
        stage('Example') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
```
### stage

stage指令定义在stages块中，里面必须至少包含一个steps指令，一个可选的agent指令，以及其他stage相关指令。

```groovy
// Declarative //
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                echo 'Hello World'
            }
        }
    }
}
```
### tools

定义自动安装并自动放入PATH里面的工具集合
```groovy
// Declarative //
pipeline {
    agent any
    tools {
        maven 'apache-maven-3.0.1' ①
    }
    stages {
        stage('Example') {
            steps {
                sh 'mvn --version'
            }
        }
    }
}
```
注：① 工具名称必须预先在Jenkins中配置好了 → Global Tool Configuration.

### 内置条件

branch - 分支匹配才执行 when { branch 'master' }
environment - 环境变量匹配才执行 when { environment name: 'DEPLOY_TO', value: 'production' }
expression - groovy表达式为真才执行 expression { return params.DEBUG_BUILD } }

```groovy
// Declarative //
pipeline {
    agent any
    stages {
        stage('Example Build') {
            steps {
                echo 'Hello World'
            }
        }
        stage('Example Deploy') {
            when {
                branch 'production'
            }
            echo 'Deploying'
        }
    }
}
```

## Steps

这里就是实实在在的执行步骤了，每个步骤step都具体干些什么东西， 前面的Sections、Directives算控制逻辑和环境准备，这里的就是真实执行步骤。

这部分内容最多不可能全部讲完，官方Step指南 包含所有的东西。

Declared Pipeline和Scripted Pipeline都能使用这些step，除了下面这个特殊的script。

一个特殊的step就是script，它可以让你在声明管道中执行脚本，使用groovy语法，这个非常有用：

```groovy
// Declarative //
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                echo 'Hello World'
                script {
                    def browsers = ['chrome', 'firefox']
                    for (int i = 0; i < browsers.size(); ++i) {
                        echo "Testing the ${browsers[i]} browser"
                    }
                }
                script {
                    // 一个优雅的退出pipeline的方法，这里可执行任意逻辑
                    if( $VALUE1 == $VALUE2 ) {
                       currentBuild.result = 'SUCCESS'
                       return
                    }
                }
            }
        }
    }
}
```
最后列出来一个典型的Scripted Pipeline：

```groovy
node('master') {
    checkout scm
    stage('Build') {
        docker.image('maven:3.3.3').inside {
            sh 'mvn --version'
        }
    }
    stage('Deploy') {
        if (env.BRANCH_NAME == 'master') {
            echo 'I only execute on the master branch'
        } else {
            echo 'I execute elsewhere'
        }
    }
}
```
可以看到，Scripted Pipeline没那么多东西，就是定义一个node， 里面多个stage，里面就是使用Groovy语法执行各个step了，非常简单和清晰，也非常灵活。

## 两种Pipeline比较

`Declarative Pipeline`相对简单，而且不需要学习groovy语法，对于日常的一般任务完全够用， 而`Scripted Pipeline`可通过Groovy语言的强大特性做任何你想做的事情。

# Blue Ocean

Jenkins最新整了个Blue Ocean出来，我觉得有必要用单独来介绍一下这个东西。

Blue Ocean重新设计了用户使用Jenkins的方式，给我们带来极大的方便，同时也兼容自由风格的任务定义。

## 安装

可以在当前Jenkins环境下面安装Blue Ocean插件，具体步骤：

登录Jenkins服务器
侧边栏点击”Manage Jenkins” -> “Manage Plugins”
选择”Available”然后使用搜索框查找”Blue Ocean”
在安装列点击checkbox
选择”不重启安装”或”下载并重启后安装”


## 启动

安装好后会出现一个”Open Blue Ocean”的按钮，点击即可进入蓝色海洋：



界面如下：



蓝色海洋果真是蓝色的，^_^

## Pipeline编辑器

使用管道编辑器是最简单的方式，可以来创建多个并行执行的任务。 编辑完保存后会自动保存为Jenkinsfile并放到源码管理系统中。

这里我演示一个在github中没有定义过Jenkinsfile的仓库，创建pipeline会默认写入Jenkinsfile文件。

首先需要在GitHub上面生成你的Personal access tokens，然后创建一个关联GitHub的管道，可视化编辑任务。



编辑完pipeline后保存会执行一次commit和push操作



个人感觉这种可视化简单点的倒可以，复杂的还是手动写吧。

弄好后你想执行某个pipeline，就先点下那个五角星，上面就会出现执行按钮了。



# FAQ

如果遇见for (item : items)报错NotSerializableException或者Unserializable iterator等等错误， 就将foreach循环改成传统C语言的循环：

```groovy
for (int i = 0; i < cluster_nodes.size(); i++) {
    node = cluster_nodes[i]
}
```