

Jenkins pipeline：pipeline 使用之语法详解 - YatHo - 博客园 https://www.cnblogs.com/YatHo/p/7856556.html


agent

　　agent部分指定整个Pipeline或特定阶段将在Jenkins环境中执行的位置，具体取决于该agent 部分的放置位置。该部分必须在pipeline块内的顶层定义 ，但stage级使用是可选的。

　　
　　为了支持Pipeline可能拥有的各种用例，该agent部分支持几种不同类型的参数。这些参数可以应用于pipeline块的顶层，也可以应用在每个stage指令内。
参数
　　any
　　　　在任何可用的agent 上执行Pipeline或stage。例如：agent any
　　none
　　　　当在pipeline块的顶层使用none时，将不会为整个Pipeline运行分配全局agent ，每个stage部分将需要包含其自己的agent部分。
　　label
　　　　使用提供的label标签，在Jenkins环境中可用的代理上执行Pipeline或stage。例如：agent { label 'my-defined-label' }
　　node
　　　　agent { node { label 'labelName' } }，等同于 agent { label 'labelName' }，但node允许其他选项（如customWorkspace）。
　　docker
　　　　定义此参数时，执行Pipeline或stage时会动态供应一个docker节点去接受Docker-based的Pipelines。 docker还可以接受一个args，直接传递给docker run调用。例如：agent { docker 'maven:3-alpine' }或

docker
agent {
    docker {
        image 'maven:3-alpine'
        label 'my-defined-label'
        args  '-v /tmp:/tmp'
    }
}
　　dockerfile

　　　　使用从Dockerfile源存储库中包含的容器来构建执行Pipeline或stage 。为了使用此选项，Jenkinsfile必须从Multibranch Pipeline或“Pipeline from SCM"加载。
　　　　默认是在Dockerfile源库的根目录：agent { dockerfile true }。如果Dockerfile需在另一个目录中建立，请使用以下dir选项：agent { dockerfile { dir 'someSubDir' } }。您可以通过docker build ...使用additionalBuildArgs选项，如agent { 　　　　dockerfile { additionalBuildArgs '--build-arg foo=bar' } }。

 

参数
any
　　在任何可用的agent 上执行Pipeline或stage。例如：agent any
none
　　当在pipeline块的顶层使用none时，将不会为整个Pipeline运行分配全局agent ，每个stage部分将需要包含其自己的agent部分。
label
　　使用提供的label标签，在Jenkins环境中可用的代理上执行Pipeline或stage。例如：agent { label 'my-defined-label' }
node
　　agent { node { label 'labelName' } }，等同于 agent { label 'labelName' }，但node允许其他选项（如customWorkspace）。
docker
　　定义此参数时，执行Pipeline或stage时会动态供应一个docker节点去接受Docker-based的Pipelines。 docker还可以接受一个args，直接传递给docker run调用。例如：agent { docker 'maven:3-alpine' }或

docker
agent {
    docker {
        image 'maven:3-alpine'
        label 'my-defined-label'
        args  '-v /tmp:/tmp'
    }
}
dockerfile
使用从Dockerfile源存储库中包含的容器来构建执行Pipeline或stage 。为了使用此选项，Jenkinsfile必须从Multibranch Pipeline或“Pipeline from SCM"加载。
默认是在Dockerfile源库的根目录：agent { dockerfile true }。如果Dockerfile需在另一个目录中建立，请使用以下dir选项：agent { dockerfile { dir 'someSubDir' } }。您可以通过docker build ...使用additionalBuildArgs选项，如agent { dockerfile { additionalBuildArgs '--build-arg foo=bar' } }。

常用选项

这些是可以应用于两个或多个agent的选项。除非明确定义，否则不需要。
　　label
　　　　一个字符串。标记在哪里运行pipeline或stage
　　　　此选项适用于node，docker和dockerfile，并且 node是必需的。
　　customWorkspace
　　　　一个字符串。自定义运行的工作空间内。它可以是相对路径，在这种情况下，自定义工作区将位于节点上的工作空间根目录下，也可以是绝对路径。例如：


agent {
    node {
        label 'my-defined-label'
        customWorkspace '/some/other/path'
    }
}
　　reuseNode
　　　　一个布尔值，默认为false。如果为true，则在同一工作空间中。
　　　　此选项适用于docker和dockerfile，并且仅在 individual stage中使用agent才有效。


pipeline {
    //Execute all the steps defined in this Pipeline within a newly created container of the given name and tag (maven:3-alpine).
    agent { docker 'maven:3-alpine' }
    stages {
        stage('Example Build') {
            steps {
                sh 'mvn -B clean verify'
            }
        }
    }
}
　
pipeline {
    agent none
    stages {
        stage('Example Build') {
            agent { docker 'maven:3-alpine' }
            steps {
                echo 'Hello, Maven'
                sh 'mvn --version'
            }
        }
        stage('Example Test') {
            agent { docker 'openjdk:8-jre' }
            steps {
                echo 'Hello, JDK'
                sh 'java -version'
            }
        }
    }
}