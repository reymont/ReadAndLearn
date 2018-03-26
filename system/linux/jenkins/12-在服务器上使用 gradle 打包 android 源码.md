# https://segmentfault.com/a/1190000008395219

安装 android-tools
mkdir ~/android && cd ~/android

wget https://dl.google.com/android/repository/tools_r25.2.3-linux.zip
unzip tools_r25.2.3-linux.zip
配置环境变量
echo 'export ANDROID_HOME=~/android' >> ~/.bashrc
echo 'export PATH=${ANDROID_HOME}/tools/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
以编译 https://github.com/drakeet/Ti... 为例

git clone https://github.com/drakeet/TimeMachine.git
cd TimeMachine
./gradlew build
漫长的等待后错误如下：

FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring project ':timemachine'.
> You have not accepted the license agreements of the following SDK components:
  [Android SDK Build-Tools 25.0.2, Android SDK Platform 25].
  Before building your project, you need to accept the license agreements and complete the installation of the missing components using the Android Studio SDK Manager.
  Alternatively, to learn how to transfer the license agreements from one workstation to another, go to http://d.android.com/r/studio-ui/export-licenses.html

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

BUILD FAILED

Total time: 2 mins 40.822 secs
可以看出是因为缺少 [Android SDK Build-Tools 25.0.2, Android SDK Platform 25]
这时执行android list sdk --all 寻找匹配的序号



从上图可以看出匹配的是 3 
执行 android update sdk -u -a -t 3 询问时输入 "y" 并耐心等待

Installing Archives:
  Preparing to install archives
  Downloading Android SDK Build-tools, revision 25.0.2
  Installing Android SDK Build-tools, revision 25.0.2
    Installed Android SDK Build-tools, revision 25.0.299%)
  Done. 1 package installed.
可以看出安装成功,再次执行 ./gradlew build 尝试编译, 报错如下：

root@hostker:~/work/TimeMachine# ./gradlew build
Checking the license for package Android SDK Platform 25 in /root/android/licenses
Warning: License for package Android SDK Platform 25 not accepted.

FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring project ':timemachine'.
> You have not accepted the license agreements of the following SDK components:
  [Android SDK Platform 25].
  Before building your project, you need to accept the license agreements and complete the installation of the missing components using the Android Studio SDK Manager.
  Alternatively, to learn how to transfer the license agreements from one workstation to another, go to http://d.android.com/r/studio-ui/export-licenses.html

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

BUILD FAILED

Total time: 3.94 secs
可以看出是缺少 '[Android SDK Platform 25]',重复上次的过程


从上图可以看出匹配的是 33 
执行 android update sdk -u -a -t 33 询问时输入 "y" 并耐心等待

Installing Archives:
  Preparing to install archives
  Downloading SDK Platform Android 7.1.1, API 25, revision 3
  Installing SDK Platform Android 7.1.1, API 25, revision 3
    Installed SDK Platform Android 7.1.1, API 25, revision 396%)
  Done. 1 package installed.
可以看出安装成功,再次执行 ./gradlew build 尝试编译, 报错如下：

FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring project ':timemachine'.
> You have not accepted the license agreements of the following SDK components:
  [Android SDK Platform-Tools].
  Before building your project, you need to accept the license agreements and complete the installation of the missing components using the Android Studio SDK Manager.
  Alternatively, to learn how to transfer the license agreements from one workstation to another, go to http://d.android.com/r/studio-ui/export-licenses.html

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

BUILD FAILED

Total time: 4.913 secs

android update sdk -u -a -t 2

Installing Archives:
  Preparing to install archives
  Downloading Android SDK Platform-tools, revision 25.0.3
  Installing Android SDK Platform-tools, revision 25.0.3
  Stopping ADB server failed (code -1).
    Installed Android SDK Platform-tools, revision 25.0.397%)
    Stopping ADB server succeeded.
    Starting ADB server succeeded.
  Done. 1 package installed.
FAILURE: Build failed with an exception.

* What went wrong:
A problem occurred configuring project ':timemachine'.
> You have not accepted the license agreements of the following SDK components:
  [Android Support Repository].
  Before building your project, you need to accept the license agreements and complete the installation of the missing components using the Android Studio SDK Manager.
  Alternatively, to learn how to transfer the license agreements from one workstation to another, go to http://d.android.com/r/studio-ui/export-licenses.html

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.

BUILD FAILED

android update sdk -u -a -t 160

Installing Archives:
  Preparing to install archives
  Downloading Android Support Repository, revision 43
  Installing Android Support Repository, revision 43
    Installed Android Support Repository, revision 4399%)
  Done. 1 package installed.
再次尝试编译 ./gradlew build


FAILURE: Build failed with an exception.

* What went wrong:
Gradle build daemon disappeared unexpectedly (it may have been killed or may have crashed)

* Try:
Run with --stacktrace option to get the stack trace. Run with --info or --debug option to get more log output.
额... 好像 gradle 进程被杀了,可能我内存太小了吧, 下次换个大点的再试