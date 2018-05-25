

Jenkinsfile使用_w3cschool
 https://www.w3cschool.cn/jenkins/jenkins-qc8a28op.html

 本节基于“ Jenkins入门”中介绍的信息，并介绍更有用的步骤，常见模式，并演示一些非平凡的Jenkinsfile示例。
创建一个Jenkinsfile被检入源代码控制，提供了一些直接的好处：
Pipeline上的代码审查/迭代
Pipeline的审计跟踪
Pipeline的唯一真实来源，可以由项目的多个成员查看和编辑。
Pipeline支持两种语法：Declarative（在Pipeline 2.5中引入）和Scripted Pipeline。两者都支持建立连续输送Pipeline。两者都可以用于在Web UI或者a中定义一个流水线Jenkinsfile，尽管通常被认为是Jenkinsfile将文件创建并检查到源代码控制库中的最佳做法。
创建Jenkins文件

如“ 入门” 部分所述，a Jenkinsfile是一个包含Jenkins Pipeline定义的文本文件，并被检入源代码控制。考虑以下Pipeline，实施基本的三阶段连续输送Pipeline。
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
node {
    stage('Build') {
        echo 'Building....'
    }
    stage('Test') {
        echo 'Building....'
    }
    stage('Deploy') {
        echo 'Deploying....'
    }
}
并非所有的Pipeline都将具有相同的三个阶段，但是对于大多数项目来说，这是一个很好的起点。以下部分将演示在Jenkins的测试安装中创建和执行简单的Jenkins。
假设已经有一个项目的源代码管理库，并且已经在Jenkins中按照这些说明定义了一个Jenkins 。
使用文本编辑器，理想的是支持Groovy语法突出显示的文本编辑器， Jenkinsfile在项目的根目录中创建一个新的。
上述声明性Pipeline示例包含实现连续传送Pipeline的最小必要结构。需要的代理指令指示Jenkins为Pipeline分配一个执行器和工作区。没有agent指令，不仅声明Pipeline无效，所以不能做任何工作！默认情况下，该agent伪指令确保源存储库已被检出并可用于后续阶段的步骤
该阶段的指令，和步骤的指令也需要一个有效的声明Pipeline，因为他们指示Jenkins如何执行并在哪个阶段应该执行。
要使用Scripted Pipeline进行更高级的使用，上面的示例node是为Pipeline分配执行程序和工作空间的关键第一步。在本质上，没有node Pipeline不能做任何工作！从内部node，业务的第一个顺序是检查此项目的源代码。由于Jenkinsfile直接从源代码控制中抽取，所以Pipeline提供了一种快速简便的方式来访问源代码的正确版本
Jenkinsfile (Scripted Pipeline)
node {
    checkout scm 
    /* .. snip .. */
}
：该checkout步骤将检出从源控制代码; scm是一个特殊变量，指示checkout步骤克隆触发此Pipeline运行的特定修订。
建立


对于许多项目，Pipeline“工作”的开始就是“建设”阶段。通常，Pipeline的这个阶段将是源代码组装，编译或打包的地方。的Jenkinsfile是不为现有的构建工具，如GNU/Make,Maven, Gradle,等的替代品，而是可以被看作是一个胶层结合项目的开发生命周期的多个阶段（建设，测试，部署等）一起。
Jenkins有一些插件，用于调用几乎任何一般使用的构建工具，但是这个例子将只是make从shell步骤（sh）调用。该sh步骤假定系统是基于Unix / Linux的，因为bat可以使用基于Windows的系统。
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any

    stages {
        stage('Build') {
            steps {
                sh 'make' 
                archiveArtifacts artifacts: '**/target/*.jar', fingerprint: true 
            }
        }
    }
}
：该sh步骤调用该make命令，只有在命令返回零退出代码时才会继续。任何非零退出代码将失败Pipeline。
：archiveArtifacts捕获与include pattern（**/target/*.jar）匹配的文件，并将它们保存到Jenkins主文件以供以后检索。
存档工件不能替代使用诸如Artifactory或Nexus之类的外部工件存储库，只能用于基本报告和文件归档。
测试


运行自动化测试是任何成功的连续传送过程的重要组成部分。因此，Jenkins有许多插件提供的测试记录，报告和可视化设备 。在基本层面上，当有测试失败时，让Jenkins在Web UI中记录报告和可视化的故障是有用的。下面的示例使用junit由JUnit插件提供的步骤。
在下面的示例中，如果测试失败，则Pipeline被标记为“不稳定”，如Web UI中的黄色球。根据记录的测试报告，Jenkins还可以提供历史趋势分析和可视化。
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any

    stages {
        stage('Test') {
            steps {
                /* `make check` returns non-zero on test failures,
                * using `true` to allow the Pipeline to continue nonetheless
                */
                sh 'make check || true' 
                junit '**/target/*.xml' 
            }
        }
    }
}
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
node {
    /* .. snip .. */
    stage('Test') {
        /* `make check` returns non-zero on test failures,
         * using `true` to allow the Pipeline to continue nonetheless
         */
        sh 'make check || true' 
        junit '**/target/*.xml' 
    }
    /* .. snip .. */
}
：使用内联shell conditional（sh 'make || true'）确保该 sh步骤始终看到零退出代码，从而使该junit步骤有机会捕获和处理测试报告。下面的“ 处理故障”部分将详细介绍其他方法。
：junit捕获并关联与包含pattern（**/target/*.xml）匹配的JUnit XML文件
部署


部署可能意味着各种步骤，具体取决于项目或组织的要求，并且可能是从构建的工件发送到Artifactory服务器，将代码推送到生产系统的任何步骤。
在Pipeline示例的这个阶段，“构建”和“测试”阶段都已成功执行。实际上，“部署”阶段只能在上一阶段成功完成，否则Pipeline将早退。
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any

    stages {
        stage('Deploy') {
            when {
              expression {
                currentBuild.result == null || currentBuild.result == 'SUCCESS' 
              }
            }
            steps {
                sh 'make publish'
            }
        }
    }
}
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
node {
    /* .. snip .. */
    stage('Deploy') {
        if (currentBuild.result == null || currentBuild.result == 'SUCCESS') { 
            sh 'make publish'
        }
    }
    /* .. snip .. */
}
：访问该currentBuild.result变量允许Pipeline确定是否有任何测试失败。在这种情况下，值将是 UNSTABLE。
假设一切都在Jenkins Pipeline示例中成功执行，每个成功的Pipeline运行都会将存档的关联构建工件，报告的测试结果和完整的控制台输出全部放在Jenkins中。
脚本Pipeline可以包括条件测试（如上所示），循环，try / catch / finally块甚至函数。下一节将详细介绍这种高级脚本Pipeline语法。
管道高级语法

字符串插值

Jenkins Pipeline使用与Groovy相同的规则 进行字符串插值。Groovy的字符串插值支持可能会让很多新来的语言感到困惑。虽然Groovy支持使用单引号或双引号声明一个字符串，例如：
def singlyQuoted = 'Hello'
def doublyQuoted = "World"
只有后一个字符串将支持基于dollar-sign（$）的字符串插值，例如：
def username = 'Jenkins'
echo 'Hello Mr. ${username}'
echo "I said, Hello Mr. ${username}"
会导致：
Hello Mr. ${username}
I said, Hello Mr. Jenkins
了解如何使用字符串插值对于使用一些管道更高级的功能至关重要。
工作环境

Jenkins  Pipeline通过全局变量公开环境变量，该变量env可从任何地方获得Jenkinsfile。假设Jenkins主机正在运行，在本地主机：8080 / pipeline-syntax / globals＃env中记录了可从Jenkins Pipeline中访问的环境变量的完整列表 localhost:8080，其中包括：
BUILD_ID
当前版本ID，与Jenkins版本1.597+中创​​建的构建相同，为BUILD_NUMBER
JOB_NAME
此构建项目的名称，如“foo”或“foo / bar”。
JENKINS_URL
完整的Jenkins网址，例如example.com:port/jenkins/（注意：只有在“系统配置”中设置了Jenkins网址时才可用）
参考或使用这些环境变量可以像访问Groovy Map中的任何键一样完成 ，例如：
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any
    stages {
        stage('Example') {
            steps {
                echo "Running ${env.BUILD_ID} on ${env.JENKINS_URL}"
            }
        }
    }
}
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
node {
    echo "Running ${env.BUILD_ID} on ${env.JENKINS_URL}"
}
设置环境变量


根据是否使用Declarative或Scripted Pipeline，在Jenkins Pipeline中设置环境变量是不同的。
声明式Pipeline支持环境指令，而Scripted Pipeline的用户必须使用该withEnv步骤。
Jenkinsfile (Declarative Pipeline)
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
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
node {
    /* .. snip .. */
    withEnv(["PATH+MAVEN=${tool 'M3'}/bin"]) {
        sh 'mvn -B verify'
    }
}
：environment顶级pipeline块中使用的指令将适用于Pipeline中的所有步骤。
：在一个environment意图中定义的一个指令stage将仅将给定的环境变量应用于该过程中的步骤stage。
参数


声明式Pipeline支持开箱即用的参数，允许Pipeline在运行时通过parameters指令接受用户指定的参数。使用脚本Pipeline配置参数是通过properties步骤完成的，可以在代码段生成器中找到。
如果您使用“使用构建参数”选项来配置Pipeline以接受参数，那么这些参数可作为params 变量的成员访问。
假设一个名为“Greeting”的String参数已经在配置中 Jenkinsfile，它可以通过${params.Greeting}以下方式访问该参数：
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any
    parameters {
        string(name: 'Greeting', defaultValue: 'Hello', description: 'How should I greet the world?')
    }
    stages {
        stage('Example') {
            steps {
                echo "${params.Greeting} World!"
            }
        }
    }
}
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
properties([parameters([string(defaultValue: 'Hello', description: 'How should I greet the world?', name: 'Greeting')])])

node {
    echo "${params.Greeting} World!"
}
故障处理


声明性Pipeline默认支持robust失败处理经由其post section，其允许声明许多不同的“post conditions”，例如：always，unstable，success，failure，和 changed。“ Pipeline语法”部分提供了有关如何使用各种帖子条件的更多详细信息。
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                sh 'make check'
            }
        }
    }
    post {
        always {
            junit '**/target/*.xml'
        }
        failure {
            mail to: team@example.com, subject: 'The Pipeline failed :('
        }
    }
}
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
node {
    /* .. snip .. */
    stage('Test') {
        try {
            sh 'make check'
        }
        finally {
            junit '**/target/*.xml'
        }
    }
    /* .. snip .. */
}
但是脚本Pipeline依赖于Groovy的内置try/ catch/ finally该Pipeline的执行过程中处理故障的语义。

在上面的测试示例中，该sh步骤被修改为从不返回非零退出代码（sh 'make check || true'）。这种方法虽然有效，但是意味着以下阶段需要检查currentBuild.result以确定是否有测试失败。

处理这种情况的另一种方法是保留Pipeline故障的早期退出行为，同时仍然junit有机会捕获测试报告，是使用一系列try/ finally块：
使用多个代理


在所有以前的例子中，只使用了一个代理。这意味着Jenkins将分配一个可用的执行器，无论它是如何标记或配置的。这不仅可以行为被覆盖，但Pipeline允许从内利用Jenkins环境中的多个代理商相同 Jenkinsfile，可为更高级的使用情况，如执行有帮助建立跨多个平台/测试。
在下面的示例中，“构建”阶段将在一个代理上执行，并且构建的结果将在“测试”阶段中分别标记为“linux”和“windows”的两个后续代理程序中重用。
Jenkinsfile (Declarative Pipeline)
pipeline {
    agent none
    stages {
        stage('Build') {
            agent any
            steps {
                checkout scm
                sh 'make'
                stash includes: '**/target/*.jar', name: 'app' 
            }
        }
        stage('Test on Linux') {
            agent { 
                label 'linux'
            }
            steps {
                unstash 'app' 
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
                bat 'make check' 
            }
            post {
                always {
                    junit '**/target/*.xml'
                }
            }
        }
    }
}
Toggle Scripted Pipeline (Advanced)
Jenkinsfile (Scripted Pipeline)
stage('Build') {
    node {
        checkout scm
        sh 'make'
        stash includes: '**/target/*.jar', name: 'app' 
    }
}

stage('Test') {
    node('linux') { 
        checkout scm
        try {
            unstash 'app' 
            sh 'make check'
        }
        finally {
            junit '**/target/*.xml'
        }
    }
    node('windows') {
        checkout scm
        try {
            unstash 'app'
            bat 'make check' 
        }
        finally {
            junit '**/target/*.xml'
        }
    }
}
：该stash步骤允许捕获与包含模式（**/target/*.jar）匹配的文件，以在同一管道中重用。一旦Pipeline完成执行，垃圾文件将从Jenkins主站中删除。
：agent/中的参数node允许任何有效的Jenkins标签表达式。有关详细信息，请参阅Pipeline语法部分。
：unstash 将从Jenkins主机中检索名为“藏书”的管道当前工作空间。
:   该bat脚本允许在基于Windows的平台上执行批处理脚本.
可选步骤参数


Pipeline遵循Groovy语言约定，允许在方法参数中省略括号。
许多Pipeline步骤还使用命名参数语法作为使用Groovy创建Map的简写，它使用语法[key1: value1, key2: value2]。发表如下功能等同的语句：
git url: 'git://example.com/amazing-project.git', branch: 'master'
git([url: 'git://example.com/amazing-project.git', branch: 'master'])
为方便起见，当仅调用一个参数（或只有一个必需参数）时，可能会省略参数名称，例如：
sh 'echo hello' /* short form  */
sh([script: 'echo hello'])  /* long form */
高级脚本管道


脚本Pipeline是 基于Groovy 的领域专用语言，大多数Groovy语法可以在脚本Pipeline中使用而无需修改。
同时执行


上面的例子在线性系列中的两个不同平台上运行测试。在实践中，如果make check 执行需要30分钟完成，“测试”阶段现在需要60分钟才能完成！
幸运的是，Pipeline具有内置功能，用于并行执行Scripted Pipeline的部分，在适当命名的parallel步骤中实现。
重构上述示例以使用parallel步骤：
Jenkinsfile (Scripted Pipeline)
stage('Build') {
    /* .. snip .. */
}

stage('Test') {
    parallel linux: {
        node('linux') {
            checkout scm
            try {
                unstash 'app'
                sh 'make check'
            }
            finally {
                junit '**/target/*.xml'
            }
        }
    },
    windows: {
        node('windows') {
            /* .. snip .. */
        }
    }
}
而不是在“linux”和“windows”标签的节点上执行测试，它们现在将在Jenkins环境中存在必需容量的情况下并行执行。