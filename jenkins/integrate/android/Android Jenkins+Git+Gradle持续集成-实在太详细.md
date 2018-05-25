Android Jenkins+Git+Gradle持续集成-实在太详细 - 简书 https://www.jianshu.com/p/38b2e17ced73

安装

上来就是干的，首先到Jenkins的官网下载https://jenkins.io，点击Download Jenkins按钮会弹出两个版本选择：LTS Release（长期支持版本），Weekly Release（每周更新版本）。首先说一下这两个版本，个人觉得和MIUI的更新类似，一个开发版本一个稳定版，大家可以自行选择，功能上几乎没区别。点击尖角号会弹出操作系统，可以选择对应的操作系统安装，也可以直接下载2.xx.x.war包然后放在Tomcat（下文会详细介绍Tomcat一些功能）的webapps目录，新建Jenkins文件夹再放入。

我选择的是Windows安装版的，首先安装版和war版我都尝试过，功能是没区别的，主要的区别在于目录上，安装版指定安装目录以后几乎所有的东西都会在对应的文件夹下生成，比如Jobs（即存放工程目录），不会在其他磁盘再生成多余的文件夹，而war版放在Tomcat目录下以后，用浏览器打开，所有的东西会在C盘生成.Jenkins文件夹。我自己是有一些强迫症的，喜欢目录整洁，不生成多余文件夹的。还有一个理由就是安装版可以不依赖Tomcat，即使本机没有安装Tomcat，安装版安装完成后依然可以用本机ip:port启动。大家可以自行选择喜欢的版本。

由于安装部分比较简单，就不上图了。

插件

1.进入管理插件

接下来就要说说，Jenkins最强大的部分之一了，那就是插件。Jenkins提供了非常多的插件，几乎你想要的插件全有，前提是你能找的到~官网提供了插件搜索功能，选择Plugins页就可以各种搜索了。

重点来了（敲黑板，啪啪啪~）：首次进入，首先要输入一个密钥来进入Jenkins，接下来...接下来...上图

setup.png

一般选择第一项即可，会自动安装推荐的插件，注意：这里并不是所有插件都能安装成功，有的安装失败也不影响，所有的安装完进行下一步就可以了。

But，有时候点击以后会发生下面的情况

setup_error.png

怎么点击Retry按钮依然是错误，这时候不要慌张，咱们选择第一张图中的第二项，进行自己选择，这里系统推荐的插件默认也是选中的，直接点安装即可。But，个别情况依然会出现上图的错误页面，那么解决办法就是：进入自行选择页面，清空选项即所有都不选，然后点安装按钮，进入下一页。
下一页就是创建用户页面，这里建议创建用户，下面提供了Continue as admin按钮也可进入主页，但是后期想创建用户还是很麻烦的，所以建议创建用户。

创建好用户，就可以进入到主页了~选择系统管理->管理插件->可选插件来开始安装我们需要的插件。

2.插件列表

注意：列表中为主要插件，而Jenkins的插件是有依赖关系的，安装一个插件可能要先安装它依赖的插件，否则会安装失败。在可选插件勾选列表中的插件即可，依赖插件会自动下载，是不是很棒。

Git plugin
Gradle Plugin
Email Extension Plugin
description setter plugin
build-name-setter
user build vars plugin
Post-Build Script Plug-in
Branch API Plugin
SSH plugin
Scriptler
Dynamic Parameter Plug-in
Git Parameter Plug-In
配置

插件安装完毕，我们就可以来配置Jenkins了，打包又离我们近了一步。

1.Global Tool Configuration

在系统管理选项中找到Global Tool Configuration进入，如果上面的插件安装成功，在这里会看到三个板块，如图


Global_Tool_Configuration.png

分别是JDK，Git，Gradle板块，分别配置这三个的路径。

JDK：别名=任意，JAVA_HOME=JDK目录
Git：别名=任意， Path to Git executable=Git安装目录\bin\git.exe
Gradle：别名=任意，GRADLE_HOME=Gradle下载目录\Gradle\gradle-2.xx
Gradle尽量配置多个，因为项目的gradle版本可能不一样，所以需要选择不同的Gradle版本进行编译
这个Gradle的目录，可以是Android Studio默认下载的Gradle目录，在用户目录的.gradle\wrapper\dists文件夹下，但是目录不是很整洁；也可以到http://www.androiddevtools.cn找到gradle资源处下载常用的gradle版本，放到一个指定的文件夹，然后配置路径即可，目录比较整洁。

2.全局属性

在这里最好配置一下全局属性，这里先说一个，就是配置Android SDK目录，在打包是有可能会出现ANDROID_HOME not found的情况，所以在系统管理->系统设置->全局属性版块勾选上Environment variables选项，然后添加
android_home.png

记得更改值内的路径为本机sdk目录。
注意：这里的键需要和本机环境变量内的Android SDK目录的键一致

打包

1.创建项目

距离开始打包又近了一步，接下来就开始创建新项目了，点击首页的新建，进入下图界面
create.png

给自己的项目起个名字，然后选择构建一个自由风格的软件项目，点击OK按钮，进入项目的配置界面。
2.项目配置

直接选择源码管理tab或者向下滚动找到源码管理，如图；
source_manage.png

选中Git选项，会出现上图的界面，配置Git项目的URL，我测试用的是Github项目，并且传输协议选择的是HTTP，需要选择Credentials选项，选择通行证，第一次需要点击Add添加通行证，如图：
credentials.png

Kind种类选择默认的Username with password，然后在Username和Pasword处分别输入Git账户的用户名和密码，然后滚动到下方点击Add，然后在Credentials中选择我们刚才添加的通行证。
接着滚动到构建Tab，点击添加构建步骤，然后选择Invoke Gradle script，如图：

build.png

然后配置构建时的Gradle版本，和需要执行的任务，如图：

build1.png

这个Tasks是先clean工程，然后打包所有渠道的Release版本，这是Gradle的命令，不多说了。然后点击保存按钮，马上就可以打包了。
3.开始构建

点击保存后，进入项目界面，如图：

project.png

点击左侧菜单栏的立即构建，开始构建项目，这时候Build History版块会出现构建任务列表，点击进入可以查看构建详情页，如图
project_build.png

又很多菜单可以选择来查看状态，点击Console Output来查看构建输出的日志，所有的信息都会显示，日志最后输出Finished: SUCCESS即构建成功。
成功之后，返回项目地址就可以点击工作空间，在app的build目录下面查看apk生成情况。

以上就是Jenkins打包最简单的配置，我知道大家想要的不止这些，更精彩的还在后面。

定制想要的功能

1.参数化构建

在我们打包的时候，我们大多时候不想只是简简单单打一个版本的包，我们想通过配置一下参数，来满足一些需求，比如根据渠道打不同版本的包、根据Tag打不同的包等，下面就来说一下Jenkins参数化构建。

在我们项目中需要配置的选项有：版本（Release 或 Debug），版本号，渠道包，根据Tag打包。另外我们还需要加上打包途径，AS打包还是Jenkins打的包，还要加一个时间戳。所有的参数列出来了，下面就配置Jenkins的参数化构建吧~

在Jenkins项目主页选择配置，进入配置页，在General tab将参数化构建过程选中，如图：

General.png

接下来就可以添加参数了，下面我先列出参数表格：

参数名	参数类型	参数值列表
BUILD_TYPE	Choice	Release or Debug
IS_JENKINS	Choice	true
PRODUCT_FLAVORS	Choice	Xiaomi 、Wandoujia等
BUILD_TIME	Dynamic Parameter	2016-12-21-11-11
APP_VERSION	Choice	1.0.0、1.0.1等
GIT_TAG	Git Parameter	tag1.0.0等
下面直接放我的配置截图：

build_type.png
product_flavor.png
app_version.png
is_jenkins.png
build_time.png
git_tag.png

配置完参数还不算完，我们要在下方构建时候引用，首先找到构建标签处，将Tasks属性值修改为：
clean assemble${PRODUCT_FLAVORS}${BUILD_TYPE} --stacktrace --debug
其中${PRODUCT_FLAVORS}和&{BUILD_TYPE}分别对应上面的参数名。配置如图：

build2.png

看了图大家肯定留意到了红色框内的选项而且很好奇吧，这个选项是APP_VERSION、IS_JENKINS、BUILD_TIME需要用到的，因为这三个参数需要注入到Android项目中的配置一样，而红色框中的这个选项可以帮我们侵入到gradle.properties文件中替换值，并且build.gradle文件能够直接引用gradle.properties文件中的属性，所以起到了侵入的效果。下面分别是我的gradle.properties和主项目的build.gradle文件全代码：
//gradle.properties

# Project-wide Gradle settings.
# IDE (e.g. Android Studio) users:
# Gradle settings configured through the IDE *will override*
# any settings specified in this file.
# For more details on how to configure your build environment visit
# http://www.gradle.org/docs/current/userguide/build_environment.html
# Specifies the JVM arguments used for the daemon process.
# The setting is particularly useful for tweaking memory settings.org.gradle.jvmargs=-Xmx1536m
# When configured, Gradle will run in incubating parallel mode.
# This option should only be used with decoupled projects. More details, visit
#http://www.gradle.org/docs/current/userguide/multi_project_builds.html
#sec:decoupled_projects
#org.gradle.parallel=true
APP_VERSION=1.0.1
IS_JENKINS=true
BUILD_TIME=''

//build.gradle

apply plugin: 'com.android.application'
def getDate() {    
    def date = new Date()    
    def formattedDate = date.format('yyyy-MM-dd-HH-mm')    
    return formattedDate
}
def verCode = 14
android {    
    compileSdkVersion 25    
    buildToolsVersion "25.0.0"    
    defaultConfig {        
        applicationId "com.zyyoona7.autobuildtest"        
        minSdkVersion 15        
        targetSdkVersion 23        
        testInstrumentationRunner "android.support.test.runner.AndroidJUnitRunner"        
        multiDexEnabled true        
        versionCode verCode        
        versionName APP_VERSION    
    }    
    signingConfigs {        
        signingConfig {            
            //由于本地打包使用的是本机上的KeyStore            
            //而Jenkins打包用的是服务器上的KeyStore            
            //两个路径不一样           
            if("true".equals(IS_JENKINS)){                
                storeFile file("服务器上KeyStore的路径")            
            }else {                
                storeFile file(STORE_FILE_PATH)            
            }            
            keyAlias KEY_ALIAS            
            keyPassword KEY_PASSWORD            
            storePassword STORE_FILE_PASSWORD        
        }    
    }    
    buildTypes {        
        release {           
            minifyEnabled true            
            zipAlignEnabled true            
            shrinkResources true            
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'            
            signingConfig signingConfigs.signingConfig        
        }        
        debug {  }    
    }    
    dexOptions {        
        javaMaxHeapSize "2g"    
    }    
    //渠道Flavors   
    productFlavors {        
        wandoujia {            
            manifestPlaceholders = [UMENG_CHANNEL_VALUE: "wandoujia"]        
        }        
        xiaomi {            
            manifestPlaceholders = [UMENG_CHANNEL_VALUE: "xiaomi"]        
        }    
    }    
    //修改生成的apk名字及输出文件夹    
    applicationVariants.all { variant ->        
        variant.outputs.each { output ->            
            //新名字            
           def newName            
           //时间戳            
           def timeNow            
           //输出文件夹            
           def outDirectory            
           //是否为Jenkins打包，输出路径不同           
            if ("true".equals(IS_JENKINS)) {                
               //Jenkins打包输出到服务器路径                
               timeNow = BUILD_TIME                
               //BUILD_PATH为服务器输出路径                
               outDirectory = BUILD_PATH                
               //AutoBuildTest-v1.0.1-xiaomi-release.apk                
               newName = 'AutoBuildTest-v' + APP_VERSION + '-' + variant.productFlavors[0].name + '-' + variant.buildType.name + '.apk'            
           } else {                
               //本机打包输出在本机路径                
               timeNow = getDate()                
               outDirectory = output.outputFile.getParent()                
               if ('debug'.equals(variant.buildType.name)) {                    
                   newName = "AutoBuildTest-v${APP_VERSION}-debug.apk"                
               } else {                    
                   //AutoBuildTest-v1.0.1-xiaomi-release.apk                    
                   newName = 'AutoBuildTest-v' + APP_VERSION + '-' + variant.productFlavors[0].name + '-' + variant.buildType.name + '.apk'                
               }            
           }            
           output.outputFile = new File(outDirectory+'/'+timeNow, newName)        
       }    
    }
}

dependencies {    
    compile fileTree(dir: 'libs', include: ['*.jar'])    
    androidTestCompile('com.android.support.test.espresso:espresso-core:2.2.2', {        
        exclude group: 'com.android.support', module: 'support-annotations'    
    })    
    compile 'com.android.support:appcompat-v7:25.0.0'    
    testCompile 'junit:junit:4.12'
}
这样在Jenkins打包的时候上面三个参数就会随着选择变化而变化了。

GIT_TAG参数使用配置，只需在源码管理处的Branch引用改为$GIT_TAG引用参数名，如图：
git_tag_use.png

参数配置完毕，看一下主页面的效果吧，现在立即构建选项变成了_ Build with Parameters_，完成图：
build_with_parameters.png
提示：

如果选中了GIT_TAG中的任意版本都无法取消选中，只能刷新；
还有使用GIT_TAG时最好选择tag版本大于等于支持Jenkins打包的版本，因为之前版本代码中没加需要侵入的属性
2.按时打包

由于篇幅原因加上这个功能我没用在项目中，所以请参考使用Jenkins搭建iOS/Android持续集成打包平台的配置构建触发器部分。

3.构建命名

每次构建的时候，Build History模块显示是这样的，如图：

build_history.png

每次构建都只显示数字（#xx），这样很不好看，我们想要它显示更多的信息怎么办呢？比如加入构建者姓名、构建的app版本、构建的类型等。请看下图：

set_build_name.png

配置完以后再次打包，变成了这个样子，如图：
build_history1.png

是不是很Nice，当然大家还可以根据需求自行发挥~
4.Tomcat配置下载地址

打完包放在服务器上，我们得配置一下下载环境才能下载，首先是Tomcat的安装，这里对Tomcat安装就不做详细的介绍了，如果不熟悉的请自行谷歌或百度，下面内容需基于Tomcat环境进行，我的Tomcat版本为8.0+。

这里说一下如何使用Tomcat配置下载地址，首先进入Tomcat目录下的conf文件夹，然后打开server.xml文件在最后添加如图代码：

erver.png
<!-- docBase为绝对路径即板寸apk文件的文件夹，path为相对地址即在地址栏访问的地址-->
<Context  reloadable="true" docBase="C://android/downloadApk" crossContext="true" path="/downloadApk"/>
添加完这句话以后启动Tomcat服务，打开浏览器输入IP:Port/downloadApk，就可以访问了点击你想要的文件下载吧。

5.二维码下载

二维码下载功能，现在网上大多数的做法是通过蒲公英或者fir.im来生成二维码，这两个都是内测平台，我体验过蒲公英，需要将文件传到蒲公英网站然后他们生成二维码返回，传到别处总感觉怪怪的，于是我决定自己生成二维码然后放在下载地址的文件夹中，通过链接显示。

首先要在电脑上安装python环境，请看http://www.cnblogs.com/yuanzm/p/4089856.html和(Python问题一)python 安装PIL (Python Imaging Library )来进行安装，如果已经安装继续往下看。生成二维码我用了qrcode这个库，感谢大神的分享，这个库如何使用就不介绍了，我只说一下Jenkins如何执行python。

添加python的环境变量到Jenkins的环境变量中，文章前面有提到过，在系统管理->系统设置中，如图添加python环境变量：

python.png

注意：键名需要和电脑上系统环境变量内的键名保持一致。
然后打开项目配置页面，在构建版块点击添加构建步骤，如图：

add_build.png

在编辑框内输入qrcode项目的使用命令
python_build.png
注意：下载地址需要自己拼接，生成路径也需要自己拼接。

这样每次打包后都会在生成apk的文件夹内生成一个对应的二维码。扫一扫就可以下载啦~~~

6.构建后操作

构建完成后，我希望将下载地址和二维码放在Build History的版块中，方便下载，那么我们就来设置一下，打开项目配置页，如图操作：
build_after.png

在Description输入框内添加
<!-- 需替换链接地址 -->
![](http:/192.168.1.88:8088/downloadApk/${BUILD_TIME}/qrcode.png)<br>
<a href="http://192.168.1.88:8088/downloadApk/${BUILD_TIME}/AutoBuildTest-v${APP_VERSION}-${PRODUCT_FLAVOR}-${BUILD_TYPE}.apk">下载连接</a>
7.邮件通知

打完包，我想通知需要下载的人怎么办？发邮件~~Jenkins自带了邮件功能，但是不太好用，所以我选择了Email Extension Plugin这个插件来实现发邮件功能（已经在插件列表中）。进入系统管理->系统设置页面，如图：


mail.png

邮件格式：

[Jenkins构建通知]$PROJECT_NAME - Build # $BUILD_NUMBER - $BUILD_STATUS!

(邮件由Jenkins自动发出，请勿回复~)<br>
项目名称：$PROJECT_NAME<br>
构建编号：$BUILD_NUMBER<br>
构建状态：$BUILD_STATUS<br>
触发原因：${CAUSE}<br>
构建地址：<A HREF="${BUILD_URL}">${BUILD_URL}</A><br>
构建输出日志：<a href="http://192.168.1.201:8090/job/${PROJECT_NAME}/${BUILD_NUMBER}/console">http://192.168.1.201:8090/job/${PROJECT_NAME}/${BUILD_NUMBER}/console</a><br>
下载地址：<a href="http://192.168.1.88:8088/downloadApk">http://192.168.1.88:8088/downloadApk</a><br><br>
二维码下载：![](http://192.168.1.88:8088/downloadApk/${BUILD_TIME}/qrcode.png)<br>
最近修改：<br>${CHANGES, showPaths=false, format="%a：\"%m\"<br>", pathFormat="\n\t- %p"}
注意：请自行修改对应的地址，关于最近修改请参照http://stackoverflow.com/questions/7773010/how-to-include-git-changelog-in-jenkins-emails

最终的效果图是介个样子的：

mail1.png
遇到的错误

1.AAPT err(Facade for 26390200):build-tools/23.0.1/aapt: /lib/libc.so.6: version `GLIBC_2.11' not found /23.0.1/aapt)####

在将Jenkins部署到linux服务器的时候出现了这个错误，lib/libc.so.6是linux系统的c库，由于我们公司服务器的linux系统太老，导致最高支持GLIBC_2.5，虽然可以通过升级内核来解决，但是有风险，所以最后决定还是部署到了Windows服务器上面。所以在部署到Linux服务器上面之前先检查你的Linux系统所支持的GLIBC_2.xx的版本，Android Build-Tools 25.0.0的需要GLIBC_2.14。

2.local.properties：sdk.dir not found or ANDROID_HOME not found

不好意思，因为没及时记录所以这个错误我只记了大概，而且配置完以后，想出现这个错误竟然没复现，所以只能看个大概了。这个错误主要是配置Android SDK路径为ANDROID_HOME环境变量没有配置。Windows上面配置一下环境变量；名字ANDROID_HOME：值为Android SDK路径。还有一种方法，配置Jenkins的环境变量名字和值和上面一样，添加到系统管理->系统设置->全局属性下面有一个Environment variables 勾上，然后添加环境变量即可

总结

Jenkins打包并不难，最难的地方就是安装插件，由于公司网络不太给力导致安装插件至少半天，坑啊~~~

如果在Linux系统上和Mac上使用Jenkins的化设置起来几乎无差别，只是需要的文件格式大同小异而已。

由于篇幅比较多，希望大家看完多多反馈，有什么问题也可以留言。

参考

使用Jenkins搭建iOS/Android持续集成打包平台
利用Jenkins玩转Android自动打包发包

作者：zyyoona7
链接：https://www.jianshu.com/p/38b2e17ced73
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。