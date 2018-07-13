


from kye-lihai

这篇文档主要说明 Jenkins 环境配置, 及一些关键操作步骤, 关于 Jenkins 的详细介绍可以自行搜索.

## 环境搭建
因为 Jenkins 主服务器已经部署好, 所以搭建环境比较简单, 只需在 Mac mini 上安装一些常用软件和常用的命令行工具, 然后再在 Jenkins 主服务器里面将其添加成 slave node 即可. 

目前环境如下

* IP: 10.31.0.82 登录用户名: kyeios, 密码 kye2017
* SSH 已开启 (通过 System Perferences --> Sharing --> Remote Login 开启)
* VNC 已开启 (通过 System Perferences --> Sharing --> Screen Sharing 开启)
* homebrew  
* 翻墙 shadowsocks, sock5: 127.0.0.1:1080, http, https: 127.0.0.1:8118  
* iTerm 2 + Zsh  
* Git (通过 homebrew 安装, 非系统自带)
* Java 8 (Jenkins slave 需要 java 环境)
* Xcode 9.1 (command line tool 已安装)
* Ruby 2.4.1 (使用 rvm 安装, 非系统自带)
* Cocoapods 1.3.1 
* fastlane 2.64.1 (目前脚本比较简单没有用到)

### 配置 slave
在 Jenkins 主服务器里, Manage Jenkins --> Manage Nodes --> New Node
![Configure Slave](/uploads/1cd5a40b97f33d2bf9c0549765c399ef/slave.png)

* Name: 一个有意义的名字, 如 Mac mini  
* Description: 可不写    
* \#of executors: 一般是 CPU 核数, 这里写 2
* Remote root directory: Jenkins 将代码复制到哪个目录进行编译打包.这里放 ~/jenkins 下  
* Labels: iOS  
* Usage: 选"Only build jobs with label expressions matching this node", 
这样可以让 Macmini 只跑 iOS 工程的任务, 不跑其他工程的任务.  
* Launch method: SSH

## 配置项目进行持续集成
1. 复制 JenkinsDemo 项目下的 build.sh, 修改 project_name 变量为项目的名称. 根据项目需要对 build.sh 做相应修改. ( [build.sh 详细解释](#buildsh))
2. 使用 bundler 设置 cocoapods 版本. ( [bundler 说明](#bundler-%E7%AE%80%E5%8D%95%E8%AF%B4%E6%98%8E))
3. 在本地运行 build.sh, 确认编译正常.
4. 提交对 build.sh 修改, 同时 push 到 Gitlab 上.
5. 在 Jenkins 创建一个 freestyle 类型的 job, 对项目进行配置. ([Job 配置](#job-%E9%85%8D%E7%BD%AE))

### build.sh 
```bash
#!/usr/bin/env zsh
# 设置翻墙, 因为 pod install 需要翻墙才可以更新
export http_proxy=http://127.0.0.1:8118
export https_proxy=http://127.0.0.1:8118

# 下面的任何一条指令返回非0, 即报失败
set -e
# 管道中任何一条指令返回非0, 整个管道返回非0
set -o pipefail

echo "========== BUILD ENVIRONMENT =========="
env
echo "========== BUILD ENVIRONMENT =========="
echo "bundle version: $(bundle --version)"

# 根据 Gemfile 安装相应版本的 gems
bundle install

# 确认 pod fastlane 版本
echo "pod version: $(bundle exec pod --version)"
echo "$(bundle exec fastlane --version)"

# 主要改这个地方就可以了
project_name="JenkinsDemo"
scheme="$project_name"
destination="platform=iOS Simulator,OS=11.1,name=iPhone 8 Plus"

# 更新 cocoapods
bundle exec pod install

# 进行编译, 目前做得比较简单, 仅进行了编译. 以后根据实际项目可以做调整
xcodebuild -workspace "$project_name.xcworkspace" \
		   -scheme "$project_name" \
		   -destination "$destination" \
		   -configuration Debug clean build ONLY_ACTIVE_ARCH=NO | xcpretty
```

### Bundler 简单说明
使用 bundler 是为了保证各开发人员及 Mac mini 上运行的 cocoapods, fastlane 的版本和本地的一致.可类比为管理 gem 的 cocoapods, 用法也和 cocoapods 类似.  

首先使用 `gem install bundler` 来安装 bunlder. 

然后对每个项目都需要进行如下设置

1. bundle init (创建 Gemfile)
2. 修改 Gemfile 添加需要的 gems
```
gem "cocoapods", "1.3.1"
gem "fastlane", "~>2.64.1"
```
3. bundle install
4. 执行相关的 gem 时需要使用 bundle exec 如 `bundle exec pod --version `

参考 [Bundler 官网](http://bundler.io/)

### Job 配置
先创建一个 freestyle 类型的 job

#### General
主要是限制任务只能在 Mac mini 运行. 勾选 "Restrict where this project can be run", Label expression: iOS. 让这个任务只能在 Mac mini 上运行. 其他保持默认.

#### Source code management
* Repository URL 填项目在 Gitlab 上地址.
* credential: 根据上面地址是 SSH 或者 HTTP 设置不同的 credential

#### Build
Add build step --> Execute shell  
build 相关的代码都放在项目下的 build.sh 里面, 所以直接复制下面内容即可

```bash  
#!/usr/bin/env zsh --login

./build.sh
``` 
#### Gitlab 集成
Gitlab 集成有两个目的, 一是在提交代码后, 触发 Jenkins 进行一行 build, 二是在 Jenkins build 完成后, 将此次编译结果通知 Gitlab 显示在 Gitlab 上.  

1. 安装 Gitlab Plugin 和 Gitlab hook plugin.  

2. 配置 job 使得 gitlab push 后触发 build  
2.1 在 job 里 Build Trigger 部分, 勾选 "Build when a change is pushed to GitLab", 
后面紧跟一个 URL, 调用这个 URL 会触发 job 执行.  
2.2  secret token 部分新生成一个 secret token  
2.3  在 Gitlab 工程里, Settings --> Integrations 里新添加一个 webhook
URL: jenkins 提供的 URL. 如 http://10.31.0.75:8080/project/JenkinsDemo
secret token: jenkins 提供的 secret token.

3. 在 Jenkins 里面配置 gitlab 的 access token, 这样可以在编译完成后, post build status  
3.1 Gitlab 上 Settings --> Access Tokens, 创建一个新的 Access Token.  
3.2 Jenkins --> Configuration, 在 Gitlab 部分, 添加一个 Gitlab connection.  
connection name: 无特殊要求, 一个有意义的名字即可.  
gitlab host URL: 需要以 http:// 或者 https:// 开头
credential: 需要先添加一个 GitLab API Token 的 credential, 然后选择这个 credential  
3.3 在 job 里添加一个 post build actions 选择 push build status to gitlab commit.

参考
[Jenkins 与 Gitlab 集成](http://www.chenyp.com/2017/08/12/jenkins-gitlab/)

## 需要注意的问题
### login shell
Job 的 execute shell 部分第一行 `#!/usr/bin/env zsh --login`, 
这里的 `--login` 是让执行脚本时是在一个 login shell 里执行, 这样就会加载 ~/.zshrc 里面的设置, 这样环境变量和 PATH 就和用 ssh 登录上去的 shell 一致. 否则会出现找不到 cocoapod, fastlane 等.    
(这里比较奇怪的是 ~/.zshrc 理论上是在 interactive shell 时才会加载, login shell 不一定会加载它, 但这里把它设置成一个 login shell 就会加载 ~/.zshrc, 不设置就不会加载)

参考  
[Difference between Login Shell and Non-Login Shell?](https://unix.stackexchange.com/questions/38175/difference-between-login-shell-and-non-login-shell)


### 设置 LANG, LANGUAGE
cocoapods 需要设置 LANG, LANGUAGE 的 encoding 为 UTF-8. 所以在 ~/.zlogin 添加如下两行  
(如果使用 bash 则需要在 ~/.profile 中添加)

```
export LANGUAGE=en_US.UTF-8
export LANG=en_US.UTF-8
```
参考: [Github issue](https://github.com/CocoaPods/CocoaPods/issues/6333)


### Cocoapods 使用私有仓库的问题
使用私有仓库时 某些 pod 的地址是 Gitlab 上某个项目的 http 地址, 同时需要进行认证.  
对于 http 类型地址的仓库, 系统会根据 credential helper 的配置来处理认证请求. 系统默认的 credential helper 是 osxkeychain, 也就是说这种情况下会去 keychain 里面取用户名和密码, 但 keychain 使用时可能需要用户进行访问确认, 这样会导致命令行下不能正常使用, 所以需要将 credential.helper 改成 store.  
```
git config --global credential.helper store
```

改为 store 方式后, 会将用户名,明文密码保存在 ~/.git-credential 里. 如果用户名密码更新后, 需要将 ~/.git-credential 删除掉, 然后重新创建.   
重新创建的方法就是在命令行下, 使用 git clone, clone 这个需要认证的项目, 会提示输入用户名和密码,重新输入后, 即可更新.

参考: [Git 凭证存储](https://git-scm.com/book/zh/v2/Git-%E5%B7%A5%E5%85%B7-%E5%87%AD%E8%AF%81%E5%AD%98%E5%82%A8)

### Java 版本升级
目前 Jenkins 的最新版本对 Java 9 支持还有问题.所以安装的是 Java 8, 如果以后需要升级可以按如下方法进行升级.    
首先删除以下目录  

* /Library/Internet Plug-Ins/JavaAppletPlugin.plugin 
* /Library/PreferencePanes/JavaControlPanel.prefPane 
* ~/Library/Application Support/Java  

然后删除 `/Library/Java/JavaVirtualMachines` 中旧的 JDK 

参考   
[卸载旧版本 Java](https://www.java.com/en/download/help/mac_uninstall_java.xml)   
[Java 安装说明](https://docs.oracle.com/javase/8/docs/technotes/guides/install/mac_jdk.html)