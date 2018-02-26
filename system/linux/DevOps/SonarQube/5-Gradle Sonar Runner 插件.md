Gradle Sonar Runner 插件_w3cschool https://www.w3cschool.cn/gradle/znjc1hun.html

Sonar Runner 插件

Sonar runner 插件是目前仍是孵化状态。请务必注意，在以后的 Gradle 版本中，DSL 和其他配置可能会有所改变。
Sonar Runner 插件提供了对 Sonar，一个基于 web 的代码质量监测平台的集成。它基于 Sonar Runner，一个分析源代码及构建输出，并将所有收集的信息储存在 Sonar 数据库的 Sonar 客户端组件。相比单独使用 Sonar Runner，Sonar Runner 插件提供了以下便利：
自动配置 Sonar Runner
可以通过一个正规的 Gradle 任务来执行 Sonar Runner，这使得在任何 Gradle 可用的地方，它都可以用（开发人员构建，CI 服务器等），而无需下载，安装，和维护 Sonar Runner 的安装。
通过 Gradle 构建脚本动态配置
根据需要，可以利用 Gradle 脚本的所有特性去配置 Sonar Runner。
提供了广泛范围的默认配置
Gradle 已经有很多 Sonar Runner 成功分析一个项目所需的信息。基于这些信息对 Sonar Runner 进行预配置，减少了许多手动配置的需要。
插件状态和兼容性

Sonar Runner 插件是 Sonar 插件的继任者。目前它还在孵化中的状态。该插件基于 Sonar Runner 2.0，这使它与 Sonar 2.11 或更高的版本相兼容。不同于 Sonar 插件，Sonar Runner 插件与 Sonar 3.4 或更高的版本一起使用时也表现正常。
入门

若要开始，请对要分析的项目配置使用 Sonar Runner 插件。
配置使用 Sonar Runner 插件
build.gradle
apply plugin: "sonar-runner"  
假设一个本地的 Sonar 服务使用开箱即用的设置启动和运行，则不需要进一步的强制性的配置。执行 gradle sonarRunner 并等待构建完成，然后打开 Sonar Runner 输出结果的底部所指示的网页。你现在应该能够看到分析结果了。
在执行 sonarRunner 任务前，所有产生输出以用于 Sonar 分析的需要都需要被执行。通常情况下，它们是编译任务、测试任务和代码覆盖任务。为了满足这些需要，如果应用了 java 插件，Sonar Runner 插件将从 sonarRunner 添加一个对 test 的任务依赖。根据需要，可以添加更多的任务依赖。
配置 Sonar Runner

Sonar Runner 插件向 project 添加了一个 SonarRunner 扩展，它允许通过被称为 Sonar 属性 的键/值对配置 Sonar Runner。一个典型的基线配置包括了 Sonar 服务器和数据库的连接设置。
配置 Sonar 连接设置
build.gradle
sonarRunner {
    sonarProperties {
        property "sonar.host.url", "http://my.server.com"
        property "sonar.jdbc.url", "jdbc:mysql://my.server.com/sonar"
        property "sonar.jdbc.driverClassName", "com.mysql.jdbc.Driver"
        property "sonar.jdbc.username", "Fred Flintstone"
        property "sonar.jdbc.password", "very clever"
    }
}  
对于标准的 Sonar 属性的完整列表，请参阅 Sonar 文档。如果你碰巧使用另外的 Sonar 插件，请参考它们的文档。
或者，可以从命令行设置 Sonar 属性。有关更多信息，请参见第35.6节，“从命令行配置 Sonar 设置” 。
Sonar Runner 插件利用 Gradle 的对象模型所包含的信息，提供了许多标准的 Sonar 属性的智能默认值。下表总结了这些默认值。注意，对于配置使用了 java-base 或 java 插件的project，有提供另外的默认值。对于一些属性（尤其是服务器和数据库的连接配置），确定留给 Sonar Runner 一个合适的默认值。
表 36.1. 标准 Sonar 属性的 Gradle 默认值
Property	Gradle 默认值
sonar.projectKey	"$project.group:$project.name" （所分析的层次结构的根项目，否则留给 Sonar Runner 处理）
sonar.projectName	project.name
sonar.projectDescription	project.description
sonar.projectVersion	project.version
sonar.projectBaseDir	project.projectDir
sonar.working.directory	"$project.buildDir/sonar"
sonar.dynamicAnalysis	"reuseReports"
表 36.2. 配置使用 java-base 插件时另外添加的默认值
Property	Gradle 默认值
sonar.java.source	project.sourceCompatibility
sonar.java.target	project.targetCompatibility
表 36.2. 配置使用 java 插件时另外添加的默认值
Property	Gradle 默认值
sonar.sources	sourceSets.main.allSource.srcDirs（过滤为只包含存在的目录）
sonar.tests	sourceSets.test.allSource.srcDirs（过滤为只包含存在的目录）
sonar.binaries	sourceSets.main.runtimeClasspath （过滤为只包含存在的目录）
sonar.libraries	sourceSets.main.runtimeClasspath （过滤为仅包括文件 ；如果有必要会加上 rt.jar）
sonar.surefire.reportsPath	test.testResultsDir （如果该目录存在）
sonar.junit.reportsPath	test.testResultsDir （如果该目录存在）
分析多项目构建

Sonar Runner 插件能够一次分析整个项目的层次结构。它能够在 Sonar 的 web 界面生成一个层次图，该层次图包含了综合的指标且能够深入到子项目中。分析一个项目的层次结果还可以比单独分析每个项目花费更省时间。
要分析一个项目的层次结构， 需要把 Sonar Runner 插件应用于层次结构的最顶层项目。通常（但不是一定）会是这个 Gradle 构建的根项目。与分析有关的信息作为一个整体，比如服务器和数据库的连接设置，必须在这一个 project 的 sonarRunner 块中进行配置。在命令行上设置的任何 Sonar 属性也会应用到这个 project 中。
全局配置设置
build.gradle
sonarRunner {
    sonarProperties {
        property "sonar.host.url", "http://my.server.com"
        property "sonar.jdbc.url", "jdbc:mysql://my.server.com/sonar"
        property "sonar.jdbc.driverClassName", "com.mysql.jdbc.Driver"
        property "sonar.jdbc.username", "Fred Flintstone"
        property "sonar.jdbc.password", "very clever"
    }
}  
在 subprojects 块中，可以配置共享子项目之间的配置。
共享的配置设置
build.gradle
subprojects {
    sonarRunner {
        sonarProperties {
            property "sonar.sourceEncoding", "UTF-8"
        }
    }
}  
特定项目的信息在对应的 project 的 sonarRunner 块中配置。
个别配置设置
build.gradle
project
    sonarRunner {
        sonarProperties {
            property "sonar.language", "grvy"
        }
    }
}  
对于一个特定的子项目，要跳过 Sonar 分析，可以设置 sonarRunner.skipProject。
跳过项目分析
build.gradle
project
    sonarRunner {
        skipProject = true
    }
}  
分析自定义的 Source Sets

默认情况下， Sonar Runner 插件传给 project 的 main source set 将作为生产源文件，传给 project 的 test source sets 将作为测试源文件。这个过程与 project 的源目录布局无关。根据需要，可以添加额外的 source sets。
分析自定义的Source Sets
build.gradle
sonarRunner {
    sonarProperties {
        properties["sonar.sources"] += sourceSets.custom.allSource.srcDirs
        properties["sonar.tests"] += sourceSets.integTest.allSource.srcDirs
    }
}  
分析非 Java 语言

要分析非 Java 语言编写的代码，请安装相应的 Sonar 插件，并相应地设置 sonar.project.language ：
分析非 Java 语言
build.gradle
sonarRunner {
    sonarProperties {
        property "sonar.language", "grvy" // set language to Groovy
    }
}  
截至 Sonar 3.4，每个项目只可以分析一种语言。不过，在多项目构建中你可以为每一个项目分析一种不同的语言。
更多关于配置 Sonar 的属性

让我们再详细看看 sonarRunner.sonarProperties {}块。正如我们在示例中已经看到的， property()方法允许设置新属性或重写现有的属性。此外，所有已配置到这一点的属性，包括通过 Gradle 预配置的所有属性，还可通过 properties 访问器进行使用。
在 properties map 的条目可以使用常见的 Groovy 语法来读取和写入。为了方便它们的操作，这些值值仍然使用它们惯用的类型 （File，List等）。SonarProperties 块在经过评估后，这些值值被转换为字符串，如下所示： 集合的值（递归） 转换为以逗号分隔的字符串，其他所有的值通过调用其tostring ()方法进行转换。
因为 sonarProperties 块的评估是惰性的，Gradle 的对象模型的属性可以在块中被安全地引用，而无需担心它们还没有被赋值。
从命令行设置 Sonar 属性

Sonar 属性也可以从命令行中设置，通过设置一个系统属性，名称就像正在考虑中的 Sonar 属性。当处理敏感信息 （例如证件），环境信息，或点对点配置时，这会非常有用。
gradle sonarRunner -Dsonar.host.url=http://sonar.mycompany.com -Dsonar.jdbc.password=myPassword -Dsonar.verbose=true     
虽然有时当然很有用，但我们建议在 （版本控制的）构建脚本中，能够方便地让每个人都保持大部分的配置。
通过一个系统属性设置的 Sonar 属性值将覆盖构建脚本中设置的任何值（同样的属性名称）。当分析项目的层次结构时，通过系统属性设置的值应用于所分析层次结构的根项目。
在一个单独的进程中执行 Sonar Runner

根据项目大小，Sonar Runner 可能需要大量的内存。由于这个和其他（主要是隔离）的原因，最好在一个独立的进程中执行 Sonar Runner。一旦 Sonar Runner 2.1 发布，将提供这个功能，并由 Sonar Runner 插件采用。到那时，Sonar Runner 会在 Gradle 主进程中执行。
任务

Sonar Runner 插件向 project 中添加了以下任务。
表 36.4. Sonnar Runner 插件 - 任务
任务名称	依赖于	类型	描述
sonarRunner {	-	sonarRunner {	分析项目层次结构，并将结果存储在 Sonar 数据库。