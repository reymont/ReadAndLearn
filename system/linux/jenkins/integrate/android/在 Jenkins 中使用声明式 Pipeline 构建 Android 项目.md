在 Jenkins 中使用声明式 Pipeline 构建 Android 项目 - 掘金 https://juejin.im/post/5a33b9726fb9a044fb07d23f

Blue Ocean 是 Jenkins 推出的一套新的 UI，对比经典 UI 更具有现代化气息。2017 年 4 月 James Dumay 在博客上正式推出了 Blue Ocean 1.0。
兼容 Blue Ocean 的 Jenkins 版本只需要安装插件即可使用，对于已经在使用 Pipeline 构建的 Jenkins Job 基本可以无缝切换到新 UI。
以构建 Android 项目为例，学习如何使用 Jenkins Blue Ocean 与声明式 Pipeline，示例项目可以在 GitHub 上查看：
github.com/TomCzHen/je…
部署 Jenkins
在 Linux 上使用 docker-compose 通过项目中的编排文件快速部署 Jenkins。
修改 .env 中的 ANDROID_HOME 参数为 Android SKD 路径，然后执行 docker-compose up -d 启动容器，通过 http://ip:8080 访问 Jenkins。
可以根据需要修改 jenkins_home 的挂载路径，由于示例项目的 Jenkinsfile 是直接使用 master 节点作为构建节点，因此 Windows 系统的 Android SDK 应该是无法使用的(Mac 不确定，没硬件)。Windows/Mac 下构建需要以添加 Jenkins Agent 的方式运行，并在 Jenkinsfile 中需要修改构建使用的 Agent 和相应构建命令，相应的环境变量也需要配置。
关于如何在 CLI 下管理 Android SDK 可以阅读官方文档： developer.android.com/studio/comm…
Fork 示例项目或者 Clone 后签入到可访问的 Git 仓库中，按向导操作添加新 Pipeline 即可。示例项目分为 master beta prod 三个分支，分别对应开发环境、测试环境、生产环境，仅作参考。
Docker Compose
...

    environment:
      - ANDROID_HOME=/opt/android-linux-sdk
      - ANDROID_SDK_HOME=/var/jenkins_home/tmp/android
      - GRADLE_USER_HOME=/var/jenkins_home/tools/gradle

...
ANDROID_HOME 是 Android SDK 的路径，ANDROID_SDK_HOME 是 Android 项目构建中 SDK 产生的临时文件路径，GRADLE_USER_HOME 是 Gradle 的路径。
ANDROID_SDK_HOME 与 GRADLE_USER_HOME 默认都是在用户目录下，通过声明环境变量配置到 /var/jenkins_home 路径下，也可以在 Jenkins 中配置环境变量的方式实现。
...

    volumes:
      - /etc/localtime:/etc/localtime:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - jenkins_home:/var/jenkins_home
      - ${ANDROID_HOME}:/opt/android-linux-sdk

...
初始化 Jenkins 密码可以通过 docker-compose logs jenkins-blueocean 查看日志得到。部署 Jenkins 完成后按向导完成初始化，安装必要的插件。
在 Jenkins 插件管理中安装 Blue Ocean Plugin 与 Android Signing Plugin 插件。
注：挂载 /var/run/docker.sock 的原因是使用类型为 Docker 或 Docker File 的 Agent，Jenkins 需要可以访问 Docker Daemon。
准备工作
由于 Jenkinsfile 与项目代码是存放在同一项目下，因此需要将敏感信息与项目分离，交由 Jenkins 管理保存。然后在构建过程中读取 Jenkins 配置信息，避免敏感信息泄漏。
对于 Android 项目，最重要的是 APK 签名文件，通过使用插件 Android Signing Plugin 来保护签名文件及密钥。
使用 Credentials Plugin 插件保护项目中第三方 API 的 Secret Key，避免在项目代码中泄漏.
Credentials Plugin
在 Credentials 中添加 ID 为 BETA_SECRET_KEY 与 PROD_SECRET_KEY 的 Secret Text，内容为需要保护的 API Secret Key。
Android Sign Plugin
Android Sign Plugin 依赖 Credentials Plugin，因为 Credentials Plugin 只支持 PKCS#12 格式的证书，所以先需要将生成好的 JKS 证书转换为 PKCS#12 格式：
keytool -importkeystore -srckeystore tomczhen.jks -srcstoretype JKS -deststoretype PKCS12 -destkeystore tomczhen.p12
添加类型为 credential，选择上传证书文件，将 PKCS#12 证书上传到并配置好 ID，本项目中使用了 ANDROID_SIGN_KEY_STORE 作为 ID。
Jenkinsfile

参考文档：
Blue Ocean
Pipeline Syntax
Pipeline Steps Reference

Pipeline 功能在之前的 Jenkins 版本中已经存在了，Jenkins Pipeline 分有两种：Declarative Pipeline 与 Scripted Pipeline 。
两者的区别是 Declarative Pipeline 必须以 pipeline 块包含：
pipeline {
    ...
}

而 Scripted Pipeline 则以 node 块包含：
node {
    ...
}
Declarative Pipeline 使用声明式的写法，也支持引入 Scripted Pipeline 代码：
pipeline {
    ...

    stages {
        ...

        stage('Script Example) {
            steps {
                script {
                    if (isUnix()) {
                        sh './gradlew clean assembleBetaDebug'
                    } else {
                        bat 'gradlew clean assembleBetaDebug'
                }
            }
        }

        ...
    }

    ...
}

虽然功能和灵活度上并没有 Scripted Pipeline 强，但是简单易懂，可以快速上手使用。本文的的脚本代码都是 Declarative Pipeline 类型的。
参数
使用 parameters 块来声明参数化，不过由于 Blue Ocean 与 Declarative Pipeline 都是新生事物，所以当前支持的参数类型有限，需要等待社区扩展或者以 Scripted Pipeline 实现复杂需求。
pipeline {
    ...

    parameters {
        string(
            name: 'PARAM_STRING',
            defaultValue: 'String',
            description: 'String Parameter'
        )

        choice(
            name: 'PARAM_CHOICE',
            choices: '1st\n2nd\n3rd',
            description: 'Choice Parameter'
        )

        booleanParam(
            name: 'PARAM_CHECKBOX',
            defaultValue: true,
            description: 'Checkbox Parameter'
        )

        text(
            name: 'PARAM_TEXT'
            defaultValue: 'a-long-text',
            description: 'Text Parameter'
        )
    }

    stages {
        ...

        stage('Parameters Example') {
            steps {
                echo "Output Parameters"
                echo "PARAM_STRING=${params.PARAM_STRING}"
                echo "PARAM_CHOICE=${params.PARAM_CHOICE}"
                echo "PARAM_CHECKBOX=${params.PARAM_CHECKBOX}"
                echo "PARAM_TEXT=${params.PARAM_TEXT}"
            }
        }

        ...
    }

    ...
}
环境变量
可以通过 environment 声明环境变量，在 pipeline 顶层声明的变量全局有效，而在 stage 中声明的变量仅在 stage 中有效。
使用 withEnv 可以让变量仅在执行 step 时有效，可以根据需要选择声明的方法。
pipeline {
    ...

    environment {
        CC = 'clang'
    }

    stages {
        ...

        stage('withEnv Example') {
            steps {
                echo 'Run Step With Env'
                withEnv(['ENV_FIRST=true', 'ENV_SECOND=sqlite']) {
                    echo "ENV_FIRST=${env.ENV_FIRST}"
                    echo "ENV_SECOND=${env.ENV_SECOND}"
                }
            }
        }

        stage('Environment Example') {
            environment {
                SECRET_KEY = credentials('a-secret-text-id')
            }

            steps {
                sh 'printenv'
            }
        }
    }

    ...
}
Credentials
有两种方式获取 Credential 的值，一种是使用 credentials()，在环境变量说明中已经有使用过，还可以使用 withCredentials 的方式获取：
pipeline {
    ...

    stages {
        ...
        stage("Build Beta APK") {
            steps {
                echo 'Building Beta APK...'
                withCredentials([string(credentialsId: 'BETA_SECRET_KEY', variable: 'SECRET_KEY')]) {
                script {
                    if (isUnix()) {
                        sh './gradlew clean assembleBetaDebug'
                    } else {
                        bat 'gradlew clean assembleBetaDebug'
                }
            }
        }

        ...
    }

    ...
}
与 withEnv 一样，SECRET_KEY 只在 withCredentials 块内部有效。
Android Sign
Android Sign Plugin 的使用比较简单，配置好参数即可：
pipeline {
    ...

    stages {
        ...

        stage("Sign APK") {
            steps {
                echo 'Sign APK'
                signAndroidApks(
                    keyStoreId: "ANDROID_SIGN_KEY_STORE",
                    keyAlias: "tomczhen",
                    apksToSign: "**/*-prod-release-unsigned.apk",
                    archiveSignedApks: false,
                    archiveUnsignedApks: false
                )
            }
        }

        ...
    }

    ...
}
Android Gradle

参考文档：
Configure Build Variants

Build Config
在 Jenkinsfile 中声明的环境变量，可以在 gradle 脚本中获取变量值：
android {
    ...

    defaultConfig {
        ...

        buildConfigField "String", "SECRET_KEY", String.format("\"%s\"", System.getenv("SECRET_KEY") ?: "Develop Secret Key")
    }

    ...
}
然后在 Android 项目代码中使用 BuildConfig 类来使用：
BuildConfig.SECRET_KEY
Product Flavors
使用 Product Flavor 来对应不同的构建分支：
android {
    ...

    productFlavors {
        dev {
            ...
            applicationIdSuffix ".dev"
            versionNameSuffix "-dev"
            resValue("string", "version_name_suffix", getVersionNameSuffix())
        }
        beta {
            ...
            applicationIdSuffix ".beta"
            versionNameSuffix "-beta"
            resValue("string", "version_name_suffix", getVersionNameSuffix())
        }
        prod {
            ...
            resValue("string", "version_name_suffix", "")
        }
    }

    ...
}
ToDo

触发构建
测试步骤
构建物收集

作者：TomCzHen
链接：https://juejin.im/post/5a33b9726fb9a044fb07d23f
来源：掘金
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。