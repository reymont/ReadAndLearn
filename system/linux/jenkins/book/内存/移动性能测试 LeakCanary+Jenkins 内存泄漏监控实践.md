

LeakCanary+Jenkins 内存泄漏监控实践 · TesterHome
 https://testerhome.com/topics/6022

 背景

公司Android产品的OOM崩溃率持续增长，为了检测出内存泄漏问题，决定使用LeakCanary。为了持续发现内存泄漏问题，尝试将LeakCanary与Jenkins相结合。本文着重于LeakCanary与Jenkins的结合，不会对LeakCanary和Jenkins本身做过多介绍，敬请谅解。

思路

将LeakCanary接入Android产品

在Jenkins平台完成LeakCanary代码接入和Debug包的构建
通过Shell脚本实现代码修改
发现泄漏信息后自动上传到数据库
使用Monkey进行随机操作触发泄漏
使用Jenkins Pipeline实现持续集成流程
LeakCanary接入方法

关于LeakCanary的详细信息可以看这里：LeakCanary 中文使用说明。

主要修改点有两处：一处是在项目的build.gradle中加入LeakCanary的引用：

dependencies {
    debugCompile 'com.squareup.leakcanary:leakcanary-android:1.4'
    releaseCompile 'com.squareup.leakcanary:leakcanary-android-no-op:1.4'
    testCompile 'com.squareup.leakcanary:leakcanary-android-no-op:1.4'
}
另一处是在项目的主Application类（即AndroidManifest.xml内<application>标签中android:name的值）中安装LeakCanary：

import com.squareup.leakcanary.*

public class YourApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        // 安装LeakCanary
        LeakCanary.install(this);
    }
}
按照最基础的LeakCanary.install(this);方式接入LeakCanary后，发现泄漏都会产生一个通知，点击可以查看具体的leak trace。考虑到持续集成，这里希望每次发现泄漏后，将相关信息自动上传到数据库。并且由于查看leak trace的界面是一个新的Activity，在跑Monkey的过程中也会存在干扰，导致相当一段时间不在产品本身的界面中操作。因此，这里需要做一些修改。

修改点1：发现泄漏后自动上传到数据库

1、新建LeakUploadService类

在Application类所在的package内新建一个LeakUploadService类，继承DisplayLeakService类：

import com.squareup.leakcanary.*

public class LeakUploadService extends DisplayLeakService {

    @Override
    protected void afterDefaultHandling(HeapDump heapDump, AnalysisResult result, String leakInfo) {
        if (!result.leakFound || result.excludedLeak){
            return;
        }
        // 下面是处理泄漏数据和上传数据库的代码
    }
}
其中，发生泄漏的类名为result.className.toString();，其余信息诸如软件包名、软件版本号、leak trace等，均在leakInfo中，形如：

In com.example.leakcanary:1.0:1.
* com.example.leakcanary.MainActivity has leaked:
* GC ROOT thread java.lang.Thread.<Java Local> (named 'AsyncTask #3')
* references com.example.leakcanary.MainActivity$2.this$0 (anonymous subclass of android.os.AsyncTask)
* leaks com.example.leakcanary.MainActivity instance

* Retaining: 131 KB.
* Reference Key: 53591da9-6668-423c-90d1-ff83a797d94a
* Device: HTC htc HTC M9w himauhl_htccn_chs_2
* Android Version: 6.0 API: 23 LeakCanary: 1.4-SNAPSHOT 44787a1
* Durations: watch=5140ms, gc=172ms, heap dump=1381ms, analysis=18835ms

* Details:
...
一般将软件包名、版本号、leak trace（第一行下面，* Retaining: 131 KB.之上的部分）、泄漏大小等信息上传到数据库即可，有了这些信息，研发就可以定位问题了。

处理方法也很简单，就是对String对象进行一些操作。这里我是将发送泄漏的类名、软件包名、软件版本号、整个泄漏信息（除了Details部分）上传到数据库，因此代码如下：

String className = result.className.toString();
String pkgName = leakInfo.trim().split(":")[0].split(" ")[1]
String pkgVer = leakInfo.trim().split(":")[1]
String leakDetail = leakInfo.split("\n\n")[0] + "\n\n" + leakInfo.split("\n\n")[1];
至于上传数据库的代码，这里就不提供了（这个是之前同事写的，我直接拿来用了）。

2、注册service

接下来需要在AndroidManifest.xml中注册service，即在和之间添加<service android:name="xxx.LeakUploadService" android:exported="false"/>，其中xxx为LeakUploadService所在的package。

3、修改安装方式

最后修改主Application类中的安装方式，改为：

public class ExampleApplication extends Application {

    private RefWatcher refWatcher;
    protected RefWatcher installLeakCanary(){return LeakCanary.install(this, LeakUploadService.class, AndroidExcludedRefs.createAppDefaults().build());}
    @Override
    public void onCreate() {
        super.onCreate();
        // 安装LeakCanary
        refWatcher = installLeakCanary();        
    }
}
做了如上操作后，每次发送泄漏，都会自动将发送泄漏的类名、软件包名、软件版本号、泄漏信息等上传到数据库了。

修改点2：屏蔽DisplayLeakActivity类

DisplayLeakActivity类是LeakCanary展示leak trace的类，这个类的存在，会导致跑Monkey的过程中，多次进入这个Activity，在其中操作，从而减少在软件本身界面中的操作时间。屏蔽这个类后，不会再在应用列表中生成一个名为“Leaks”的软件，发送泄漏后，点击通知栏里的泄漏提醒，也不会进入leak trace的展示页面。但考虑到泄漏的信息已经上传到数据库，所以这么做也无可厚非。

通过查阅LeakCanary源码可以发现，是否开启DisplayLeakActivity，是由leakcanary-android/src/main/java/com/squareup/leakcanary/LeakCanary.java中的enableDisplayLeakActivity()函数决定的，该函数为：

public static void enableDisplayLeakActivity(Context context) {
    setEnabled(context, DisplayLeakActivity.class, true);
}
只需要把true改成false即可屏蔽DisplayLeakActivity类。

但我采用的接入方法是直接在build.gradle中添加远程依赖，并且我也不想修改成本地依赖。因此我首先想到的方法是新建一个类，让其继承LeakCanary类，然后重写enableDisplayLeakActivity()函数。但是LeakCanary类是一个final类，无法被继承。

由于LeakCanary类正好是在前面接入LeakCanary时添加代码LeakCanary.install(this);用到的类，因此我想到的方法是自己创建一个新的类LeakCanaryWithoutDisplay，位置在com/squareup/leakcanary下（需要自己新建这个package），里面的代码直接复制LeakCanary类，然后做如下修改：

把public final class LeakCanary {改为public final class LeakCanaryWithoutDisplay {
把private LeakCanary() {改为private LeakCanaryWithoutDisplay() {
修改enableDisplayLeakActivity()函数，将true改为false
将主Application类中安装LeakCanary的代码LeakCanary.install();改为LeakCanaryWithoutDisplay.install();
这样就OK了。

将接入LeakCanary的所有修改整理成Shell脚本

由于Jenkins打包每次都会拉取最新代码，因此需要将接入LeakCanary的修改整理成Shell脚本，这样每次拉取最新代码后，执行这个Shell脚本，然后再打出的包才是后面流程所需要的包。

编写Shell脚本主要使用到的命令是sed和cp，sed用来修改代码，cp用来复制文件。其中，LeakUploadService.java和LeakCanaryWithoutDisplay.java是固定的，因此可以提前写好备用，然后直接cp到相应目录。

Shell脚本主要分为以下几个部分：

修改build.gradle，添加LeakCanary依赖
修改AndroidManifest.xml，注册service
修改主Application类，安装LeakCanary
复制LeakUploadService.java（以及上传数据库可能需要用到的其他java文件）到主Application类所在的包下
复制LeakCanaryWithoutDisplay.java到com/squareup/leakcanary下
由于不同项目的脚本存在一定差异，这里就不给出具体的Shell脚本了。

新建Jenkins项目，用于构建包含LeakCanary的Debug包

在Jenkins中新建项目，配置源码管理。

将编写的Shell脚本和相关文件拷贝到Jenkins项目文件夹中。

添加构建步骤，选择“Execute shell”，执行Shell脚本，命令为：

cd $WORKSPACE
sh ../your_shell_file_name.sh
添加构建步骤，选择“Invoke Gradle script”，生成Debug包，配置如下图：



新建Jenkins Pipeline项目，用于实现完整流程

结合我司实际环境，Jenkins项目的打包是在master节点上进行的，而跑Monkey的操作是在另一台服务器上进行的（这台服务器是Jenkins的一个从节点，搭建了STF服务，连有多台测试机），记这个从节点的标签为“Linux-for-stf”。

Pipeline的步骤如下图所示：



包括5个步骤：

首先在master节点构建接入了LeakCanary的apk包
然后将apk包拷贝到STF节点
接着在STF节点安装apk包
其次在STF节点上选择一台手机跑Monkey触发泄漏
最后发送邮件提醒（项目是否构建成功）
对应Pipeline script可以简化为：

node('master') {
    stage 'build Job1'
    build 'Job1'

    stage 'scp apk to stf node'
    def apkDir="/home/test/.jenkins/jobs/Job1/workspace/app/build/outputs/apk"
    def destDir="stf@linux-for-stf:/home/stf/jenkins/apks"
    sh "scp $apkDir/test.apk $destDir"
}
node('Linux-for-stf') {
    stage 'install apk'
    def device="ABCD1234"
    def apkFile="/home/stf/jenkins/apks/test.apk"
    sh "adb -s $device install -r $apkFile"

    stage 'run monkey'
    sh "adb -s $device shell monkey -p com.example.ExampleApp -s 100 --ignore-crashes --ignore-timeouts --throttle 700 -v 10000"
}
node('master') {
    stage 'send email'
    mail to: 'test@gmail.com',
    subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) finished",
    body: "Please go to ${env.BUILD_URL} and verify the build"
}
这里会遇到一个问题：这个Pipeline项目完成后会发送一封邮件，但如果中途某一步出了问题，就直接结束运行，从而导致成功可以收到邮件、失败却收不到邮件的情况。解决方法是，使用try catch。改进的Pipeline script为：

try {
    node('master') {
        stage 'build Job1'
        build 'Job1'

        stage 'scp apk to stf node'
        def apkDir="/home/test/.jenkins/jobs/Job1/workspace/app/build/outputs/apk"
        def destDir="stf@linux-for-stf:/home/stf/jenkins/apks"
        sh "scp $apkDir/test.apk $destDir"
    }
    node('Linux-for-stf') {
        stage 'install apk'
        def device="ABCD1234"
        def apkFile="/home/stf/jenkins/apks/test.apk"
        sh "adb -s $device install -r $apkFile"

        stage 'run monkey'
        sh "adb -s $device shell monkey -p com.example.ExampleApp -s 100 --ignore-crashes --ignore-timeouts --throttle 700 -v 10000"
    }
    node('master') {
        stage 'send email'
        mail to: 'test@gmail.com',
        subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) succeeded",
        body: "Please go to ${env.BUILD_URL} and verify the build"
    }
} catch (Exception e) {
    node('master') {
        stage 'send email'
        echo '$e'
        mail to: 'test@gmail.com',
        subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) failed",
        body: "Please go to ${env.BUILD_URL} and verify the build"
    }
}
这样持续了一段时间后发现，跑Monkey过程中经常会下拉状态栏，然后点击里面的快捷按钮，而且经常会点击到Wifi按钮，从而导致Wifi被关闭。Wifi被关闭，意味着发现的泄漏信息无法上传到数据库，因此这个问题必须要解决。然而从网上搜索的结果来看并不理想，针对这个问题，大部分人都表示没有什么好的方法。

好在有一个GitHub项目被我发现了，叫simiasque。这是一款Android软件，通过全局遮罩遮住状态栏位置来防止Monkey下拉状态栏，测试效果非常好。使用方法也很简单，安装demo下的apk文件，打开软件，点击“Hide status bar”按钮即可。更方便的是，作者也提供了启动和关闭的命令，分别是：

开启：

adb shell am broadcast -a org.thisisafactory.simiasque.SET_OVERLAY --ez enable true
关闭：

adb shell am broadcast -a org.thisisafactory.simiasque.SET_OVERLAY --ez enable false
接下来要做的，就是在Pipeline script跑Monkey的命令之前加上安装和开启simiasque的命令，跑完Monkey后再加上关闭simiasque的命令即可。

最终的Pipeline script大致是这样的：

try {
    node('master') {
        stage 'build Job1'
        build 'Job1'

        stage 'scp apk to stf node'
        def apkDir="/home/test/.jenkins/jobs/Job1/workspace/app/build/outputs/apk"
        def destDir="stf@linux-for-stf:/home/stf/jenkins/apks"
        sh "scp $apkDir/test.apk $destDir"
    }
    node('Linux-for-stf') {
        stage 'install apk'
        def device="ABCD1234"
        def apkFile="/home/stf/jenkins/apks/test.apk"
        sh "adb -s $device install -r $apkFile"

        stage 'run monkey'
        sh "adb -s $device install -r /home/stf/jenkins/simiasque-debug.apk"
        sh "adb -s $device shell am broadcast -a org.thisisafactory.simiasque.SET_OVERLAY --ez enable true"
        sh "adb -s $device shell monkey -p com.example.ExampleApp -s 100 --ignore-crashes --ignore-timeouts --throttle 700 -v 10000"
        sh "adb -s $device shell am broadcast -a org.thisisafactory.simiasque.SET_OVERLAY --ez enable false"
    }
    node('master') {
        stage 'send email'
        mail to: 'test@gmail.com',
        subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) succeeded",
        body: "Please go to ${env.BUILD_URL} and verify the build"
    }
} catch (Exception e) {
    node('master') {
        stage 'send email'
        echo '$e'
        mail to: 'test@gmail.com',
        subject: "Job '${env.JOB_NAME}' (${env.BUILD_NUMBER}) failed",
        body: "Please go to ${env.BUILD_URL} and verify the build"
    }
}
到此为止，Jenkins Pipeline的步骤基本是完成了。接下来，设置好每天运行1次，泄漏信息尽收数据库之中。

后续流程

以上流程完成后，LeakCanary+Jenkins的内存泄漏监控实践基本上是完成了。但在公司的实际项目中，这样仅仅是发现和收集了泄漏信息，最关键的还是让研发修改这些问题。由于不同公司采用的Bug平台不尽相同，不同Bug平台的区别可能也很大，因此这里就不具体展开后面的步骤了。大体思路就是，定期将数据库中的泄漏信息提交到Bug平台上。至于实现方法，如果提供接口当然是直接用调用接口；如果不提供接口，也可以尝试直接向数据库添加信息。

总之，发现内存泄漏的关键还是解决，如果不解决，上面所做的一切都是白费。

当然，上面的一些方法可能并不完美，不过都是我在最近一段时间的工作中慢慢摸索得到的。如果你有更好的解决方案，欢迎交流。