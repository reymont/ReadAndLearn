
* [手把手教你利用Jenkins持续集成iOS项目 - 简书 ](http://www.jianshu.com/p/41ecb06ae95f)

开发规范建议，CI + FDD，就可以帮助我们极大程度的解决客观因素。主要讨论 Continuous Integration 持续集成（简称CI）

* 目录
1.为什么我们需要持续集成
2.持续化集成工具——Jenkins
3.iOS自动化打包命令——xcodebuild + xcrun 和 fastlane - gym 命令
4.打包完成自动化上传 fir / 蒲公英 第三方平台
5.完整的持续集成流程
6.Jenkins + Docker




## 三. iOS自动化打包命令——xcodebuild + xcrun 和 fastlane - gym 命令

在日常开发中，打包是最后上线不可缺少的环节，如果需要把工程打包成 ipa 文件，通常的做法就是在 Xcode 里点击 「Product -> Archive」，当整个工程 archive 后，然后在自动弹出的 「Organizer」 中进行选择，根据需要导出 ad hoc，enterprise 类型的 ipa 包。虽然Xcode已经可以很完美的做到打包的事情，但是还是需要我们手动点击5，6下。加上我们现在需要持续集成，用打包命令自动化执行就顺其自然的需要了。

### 1. xcodebuild + xcrun命令

Xcode为我们开发者提供了一套构建打包的命令，就是xcodebuild
和xcrun命令。xcodebuild把我们指定的项目打包成.app文件，xcrun将指定的.app文件转换为对应的.ipa文件。

具体的文档如下， xcodebuild官方文档、xcrun官方文档

https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcodebuild.1.html
https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man1/xcrun.1.html


NAME
xcodebuild – build Xcode projects and workspaces

SYNOPSIS
1. xcodebuild [-project name.xcodeproj] [[-target targetname] … | -alltargets] [-configuration configurationname] [-sdk [sdkfullpath | sdkname]] [action …] [buildsetting=value …] [-userdefault=value …]
2. xcodebuild [-project name.xcodeproj] -scheme schemename [[-destination destinationspecifier] …] [-destination-timeout value] [-configuration configurationname] [-sdk [sdkfullpath | sdkname]] [action …] [buildsetting=value …] [-userdefault=value …]
3. xcodebuild -workspace name.xcworkspace -scheme schemename [[-destination destinationspecifier] …] [-destination-timeout value] [-configuration configurationname] [-sdk [sdkfullpath | sdkname]] [action …] [buildsetting=value …] [-userdefault=value …]
4. xcodebuild -version [-sdk [sdkfullpath | sdkname]] [infoitem]
5. xcodebuild -showsdks
6. xcodebuild -showBuildSettings [-project name.xcodeproj | [-workspace name.xcworkspace -scheme schemename]]
7. xcodebuild -list [-project name.xcodeproj | -workspace name.xcworkspace]
8. xcodebuild -exportArchive -archivePath xcarchivepath -exportPath destinationpath -exportOptionsPlist path
9. xcodebuild -exportLocalizations -project name.xcodeproj -localizationPath path [[-exportLanguage language] …]
10. xcodebuild -importLocalizations -project name.xcodeproj -localizationPath path
上面10个命令最主要的还是前3个。

接下来来说明一下参数：
-project -workspace：这两个对应的就是项目的名字。如果有多个工程，这里又没有指定，则默认为第一个工程。
-target：打包对应的targets，如果没有指定这默认第一个。
-configuration：如果没有修改这个配置，默认就是Debug和Release这两个版本，没有指定默认为Release版本。
-buildsetting=value ...：使用此命令去修改工程的配置。
-scheme：指定打包的scheme。

上面这些是最最基本的命令。

上面10个命令的第一个和第二个里面的参数，其中 -target
和 -configuration 参数可以使用 xcodebuild -list
获得，-sdk 参数可由 xcodebuild -showsdks
获得，[buildsetting=value ...] 用来覆盖工程中已有的配置。可覆盖的参数参考官方文档 Xcode Build Setting Reference。
* https://developer.apple.com/documentation/DeveloperTools/Reference/XcodeBuildSettingRef/


build
Build the target in the build root (SYMROOT). This is the default action, and is used if no action is given.
analyze
Build and analyze a target or scheme from the build root (SYMROOT). This requires specifying a scheme.
archive
Archive a scheme from the build root (SYMROOT). This requires specifying a scheme.
test
Test a scheme from the build root (SYMROOT). This requires specifying a scheme and optionally a destination.
installsrc
Copy the source of the project to the source root (SRCROOT).
install
Build the target and install it into the target’s installation directory in the distribution root (DSTROOT).
clean
Remove build products and intermediate files from the build root (SYMROOT).
上面第3个命令就是专门用来打带有Cocopods的项目，因为这个时候项目工程文件不再是xcodeproj了，而是变成了xcworkspace了。

再来说说xcrun命令。

Usage:
PackageApplication [-s signature] application [-o output_directory] [-verbose] [-plugin plugin] || -man || -help

Options:

[-s signature]: certificate name to resign application before packaging
[-o output_directory]: specify output filename
[-plugin plugin]: specify an optional plugin
-help: brief help message
-man: full documentation
-v[erbose]: provide details during operation
参数不多，使用方法也很简单，xcrun -sdk iphoneos -v PackageApplication + 上述一些参数。

参数都了解之后，我们就来看看该如何用了。下面这个是使用了xcodebuild + xcrun命令写的自动化打包脚本

```sh
# 工程名
APP_NAME="YourProjectName"
# 证书
CODE_SIGN_DISTRIBUTION="iPhone Distribution: Shanghai ******* Co., Ltd."
# info.plist路径
project_infoplist_path="./${APP_NAME}/Info.plist"
#取版本号
bundleShortVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" "${project_infoplist_path}")
#取build值
bundleVersion=$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" "${project_infoplist_path}")
DATE="$(date +%Y%m%d)"
IPANAME="${APP_NAME}_V${bundleShortVersion}_${DATE}.ipa"
#要上传的ipa文件路径
IPA_PATH="$HOME/${IPANAME}"
echo ${IPA_PATH}
echo "${IPA_PATH}">> text.txt

//下面2行是没有Cocopods的用法
echo "=================clean================="
xcodebuild -target "${APP_NAME}"  -configuration 'Release' clean

echo "+++++++++++++++++build+++++++++++++++++"
xcodebuild -target "${APP_NAME}" -sdk iphoneos -configuration 'Release' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)'

//下面2行是集成有Cocopods的用法
echo "=================clean================="
xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}"  -configuration 'Release' clean

echo "+++++++++++++++++build+++++++++++++++++"
xcodebuild -workspace "${APP_NAME}.xcworkspace" -scheme "${APP_NAME}" -sdk iphoneos -configuration 'Release' CODE_SIGN_IDENTITY="${CODE_SIGN_DISTRIBUTION}" SYMROOT='$(PWD)'

xcrun -sdk iphoneos PackageApplication "./Release-iphoneos/${APP_NAME}.app" -o ~/"${IPANAME}"
```


### 2. gym 命令

说到gym，就要先说一下fastlane。
fastlane是一套自动化打包的工具集，用 Ruby 写的，用于 iOS 和 Android 的自动化打包和发布等工作。gym是其中的打包命令。

fastlane 的官网看这里, fastlane 的 github 看这里

要想使用gym，先要安装fastlane。

sudo gem install fastlane --verbose
fastlane包含了我们日常编码之后要上线时候进行操作的所有命令。

deliver：上传屏幕截图、二进制程序数据和应用程序到AppStore
snapshot：自动截取你的程序在每个设备上的图片
frameit：应用截屏外添加设备框架
pem：可以自动化地生成和更新应用推送通知描述文件
sigh：生成下载开发商店的配置文件
produce：利用命令行在iTunes Connect创建一个新的iOS app
cert：自动创建iOS证书
pilot：最好的在终端管理测试和建立的文件
boarding：很容易的方式邀请beta测试
gym：建立新的发布的版本，打包
match：使用git同步你成员间的开发者证书和文件配置
scan：在iOS和Mac app上执行测试用例
整个发布过程可以用fastlane描述成下面这样

lane :appstore do
  increment_build_number
  cocoapods
  xctool
  snapshot
  sigh
  deliver
  frameit
  sh "./customScript.sh"

  slack
end
Ps：这里可能大家还会听过一个命令叫 xctool
xctool是官方xcodebuild命令的一个增强实现，输出的内容比xcodebuild直观可读得多。通过brew即可安装。

brew install xctool
使用gym自动化打包，脚本如下

```sh
#计时
SECONDS=0
#假设脚本放置在与项目相同的路径下
project_path=$(pwd)
#取当前时间字符串添加到文件结尾
now=$(date +"%Y_%m_%d_%H_%M_%S")
#指定项目的scheme名称
scheme="DemoScheme"
#指定要打包的配置名
configuration="Adhoc"
#指定打包所使用的输出方式，目前支持app-store, package, ad-hoc, enterprise, development, 和developer-id，即xcodebuild的method参数
export_method='ad-hoc'
#指定项目地址
workspace_path="$project_path/Demo.xcworkspace"
#指定输出路径
output_path="/Users/your_username/Documents/"
#指定输出归档文件地址
archive_path="$output_path/Demo_${now}.xcarchive"
#指定输出ipa地址
ipa_path="$output_path/Demo_${now}.ipa"
#指定输出ipa名称
ipa_name="Demo_${now}.ipa"
#获取执行命令时的commit message
commit_msg="$1"
#输出设定的变量值
echo "===workspace path: ${workspace_path}==="
echo "===archive path: ${archive_path}==="
echo "===ipa path: ${ipa_path}==="
echo "===export method: ${export_method}==="
echo "===commit msg: $1==="
#先清空前一次build
gym --workspace ${workspace_path} --scheme ${scheme} --clean --configuration ${configuration} --archive_path ${archive_path} --export_method ${export_method} --output_directory ${output_path} --output_name ${ipa_name}
#输出总用时
echo "===Finished. Total time: ${SECONDS}s==="
```

## 四. 打包完成自动化上传 fir / 蒲公英 第三方平台

要上传到 fir / 蒲公英 第三方平台，都需要注册一个账号，获得token，之后才能进行脚本化操作。

1. 自动化上传fir

安装fir-clifir的命令行工具
需要先装好ruby再执行

```sh
gem install fir-cli
#上传到fir
fir publish ${ipa_path} -T fir_token -c "${commit_msg}"
2.自动化上传蒲公英

#蒲公英上的User Key
uKey="7381f97070*****c01fae439fb8b24e"
#蒲公英上的API Key
apiKey="0b27b5c145*****718508f2ad0409ef4"
#要上传的ipa文件路径
IPA_PATH=$(cat text.txt)

rm -rf text.txt

#执行上传至蒲公英的命令
echo "++++++++++++++upload+++++++++++++"
curl -F "file=@${IPA_PATH}" -F "uKey=${uKey}" -F "_api_key=${apiKey}" http://www.pgyer.com/apiv1/app/upload
```

## 五. 完整的持续集成流程

经过上面的持续化集成，现在我们就拥有了如下完整持续集成的流程


## 六. Jenkins + Docker

关于Jenkins的部署，其实是分以下两种：
单节点（Master）部署
这种部署适用于大多数项目，其构建任务较轻，数量较少，单个节点就足以满足日常开发所需。
多节点(Master-Slave)部署
通常规模较大，代码提交频繁（意味着构建频繁），自动化测试压力较大的项目都会采取这种部署结构。在这种部署结构下，Master通常只充当管理者的角色，负责任务的调度，slave节点的管理，任务状态的收集等工作，而具体的构建任务则会分配给slave节点。一个Master节点理论上可以管理的slave节点数是没有上限的，但通常随着数量的增加，其性能以及稳定性就会有不同程度的下降，具体的影响则因Master硬件性能的高低而不同。

但是多节点部署又会有一些缺陷，当测试用例变得海量以后，会造成一些问题，于是有人设计出了下面这种部署结构，Jenkins + Docker


由于笔者现在的项目还处于单节点（Master）部署，关于多节点(Master-Slave)部署也没有实践经验，改进版本的Docker更是没有接触过，但是如果有这种海量测试用例，高压力的大量复杂的回归测试的需求的，那推荐大家看这篇文章。

最后

以上就是我关于Jenkins持续集成的一次实践经验。分享给大家，如果里面有什么错误，欢迎大家多多指教。

 iOS

作者：一缕殇流化隐半边冰霜
链接：http://www.jianshu.com/p/41ecb06ae95f
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。