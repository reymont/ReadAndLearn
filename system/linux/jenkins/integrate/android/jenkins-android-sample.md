

TomCzHen/jenkins-android-sample: 这是一个使用 jenkinsfile 构建 Android APK 的示例项目。 https://github.com/TomCzHen/jenkins-android-sample

# 项目说明

这是一个使用 `jenkinsfile` 构建 Android APK 的示例项目。

使用 docker-compose 可以快速的部署这个示例，由于 Android Build Tools 使用的 aapt 同时需要 32bit 和 64bit 运行环境，因此没有选择基于 Alpine 的 Jenkins 镜像。

项目分为 `master` `beta` `prod` 三个分支，分别对应开发环境、测试环境、生产环境，仅作为示例参考。

注：本示例仅在 Linux 下测试运行正常。

## docker-compose

修改项目中的 `.env` 文件的 `ANDROID_HOME` 值为你的 Android SDK 路径，然后执行 `docker-compose up -d` 启动容器后，可以通过 `http://ip:8080` 访问 Jenkins。

需要安装 [Blue Ocean Plugin](https://wiki.jenkins-ci.org/display/JENKINS/Blue+Ocean+Plugin) 与 [Android Signing Plugin](https://wiki.jenkins.io/display/JENKINS/Android+Signing+Plugin) 插件。

在 Blue Ocean UI 中新建 Pipeline 添加本仓库即可。也可以先 fork 本项目，然后通过 GitHub Token 访问自己的帐号添加项目。

```
...
    environment:
      - ANDROID_HOME=/opt/android-linux-sdk
      - ANDROID_SDK_HOME=/var/jenkins_home/tmp/android
      - GRADLE_USER_HOME=/var/jenkins_home/tools/gradle
...
```

`ANDROID_HOME` 是 Android SDK 路径，这里是外部 SDK 文件挂载到容器内的路径。

`ANDROID_SDK_HOME` 是 Android 构建中 SDK 产生的临时文件路径，`GRADLE_USER_HOME` 是 Gradle 的路径。默认都是在用户目录下，这里配置到 `jenkins_home` 目录下。

## Jenkinsfile

> 参考文档：

> [Blue Ocean ](https://jenkins.io/doc/book/blueocean/)

> [Pipeline Syntax](https://jenkins.io/doc/book/pipeline/syntax/)

> [Pipeline Steps Reference](https://jenkins.io/doc/pipeline/steps/)

Pipeline 分为声明式和脚本式两种模式，这里使用的是声明式脚本，两种模式语法和 API 有些差别。

所有的构建步骤都在 Jenkinsfile 中，不再通过 Web UI 添加，将 CI 也纳入版本控制。

可以通过 triggers 来声明定时构建：

```
pipeline {
    ...

    triggers {
        cron('H 4/* 0 0 1-5')
    }

    ...
}
```

使用 when 来声明 stage 执行的条件：

```
pipeline {
    ...

    stages {
        ...

        stage("When Example") {
            when {
                branch 'prod'
            }

            ...
        }

    ...
    }

    ...
}
```

### 参数

构建运行前的参数，手动执行时会提示输入参数，在 Stages 中可以通过 `params.PARAM_NAME` 的方式使用这些参数。

这里参数输入在构建中没有实际的作用，仅仅作为示例，可以根据实际需要修改构建脚本：

```
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
            name: 'PARAM_TEXT',
            defaultValue: 'a-long-text',
            description: 'Text Parameter'
        )

        password(
            name: "PARAM_PASSWORD",
            defaultValue: 'Password',
            description: 'Password Parameter'
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
                echo "PARAM_PASSWORD=${params.PARAM_PASSWORD}
            }
        }

        ...
    }

    ...
}
```

### 环境变量

可以在 pipeline 和 stage 中声明环境变量：

```
pipeline {
    ...

    environment {
        CC = 'clang'
    }

    stages {
        ...

        stage('Environment Example') {
            environment {
                SECRET_KEY = credentials('a-secret-text')
            }

            steps {
                sh 'printenv'
            }
        }

        ...
    }

    ...
}

```

在 pipeline 顶层中声明的环境变量，整个 Jenkinsfile 都可以使用;在 stage 中声明的环境变量只在 stage 中有效。

还可以使用 withEnv 的方式来声明环境变量，但仅对 `withEnv` 块内的 step 有效：

```
pipeline {
    ...

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
    }

    ...
}
```

### Credentials

使用插件 [Credentials Plugin](https://wiki.jenkins.io/display/JENKINS/Credentials+Plugin) 来管理敏感配置信息。

**注意：由于本项目最终还是传入构建的 Android 代码中，最终仍然可以通过 Android 代码输出明文，因此实际上不具有保护意义的，仅作为演示使用。**

首先需要在 Credentials 中添加 ID 为 `BETA_SECRET_KEY` 与 `PROD_SECRET_KEY` 的 Secret Text。

在 Step 中通过 CredentialsID 可以读取 Jenkins 配置的 Credential 密文并赋值到变量 `SECRET_KEY`：

```
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
```

从 Credentials 中获取值之后赋予环境变量 `SECRET_KEY`，然后在 Gradle 脚本中获取：

```
defaultConfig {
    ...

    buildConfigField "String", "SECRET_KEY", String.format("\"%s\"", System.getenv("SECRET_KEY") ?: "Develop Secret Key")
}
```

然后在 Android 项目代码中通过 `BuildConfig` 类来使用：

```java
secretKeyTextView.setText(BuildConfig.SECRET_KEY);
```

### Android Sign 签名证书

使用了 [Android Signing Plugin](https://wiki.jenkins.io/display/JENKINS/Android+Signing+Plugin) 来保护签名文件及密钥。

因为 Credentials Plugin 只支持 `PKCS#12` 格式的证书，因此先需要将生成好的 `JKS` 证书转换为 `PKCS#12` 格式：

```
keytool -importkeystore -srckeystore tomczhen.jks -srcstoretype JKS -deststoretype PKCS12 -destkeystore tomczhen.p12
```

将转换好的证书上传到 Credentials 中并配置好 ID，本项目中使用了 `ANDROID_SIGN_KEY_STORE` 作为 ID:

```
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
```

## Gradle

> 参考文档：

> [Configure Build Variants](https://developer.android.com/studio/build/build-variants.html)

### Product Flavors

使用了 Product Flavors 来区分不同环境配置的包。

```gradle
productFlavors {
    dev {
        applicationIdSuffix ".dev"
        versionNameSuffix "-dev"
        resValue("string", "version_name_suffix", getVersionNameSuffix())
    }
    beta {
        applicationIdSuffix ".beta"
        versionNameSuffix "-beta"
        resValue("string", "version_name_suffix", getVersionNameSuffix())
    }
    prod {
        resValue("string", "version_name_suffix", "")
    }
}
```

同时还使用了 `resValue` 方法根据构建配置添加 string 资源，最终在 Android 代码中使用。

```java
versionNameSuffixTextView.setText(getString(R.string.version_name_suffix));
```

# TODO

* 测试环节
* 自动收集构建产物并通过 API 上传到测试平台
* 更优雅的处理构建失败问题