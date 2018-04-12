

local.prooerties


ionic2 打包android包时报'C:\Users\Administrator\AppData\Local\Android\sdk' does not exist.


https://blog.csdn.net/li11_/article/details/79194002


What went wrong: 
A problem occurred configuring root project ‘android’.

The SDK directory ‘C:\Users\Administrator\AppData\Local\Android\sdk’ does not exist.
Try: 
Run with –stacktrace option to get the stack trace. Run with –info or –debug option to get more log output.

Error: cmd: Command failed with exit code 1 Error output: 
FAILURE: Build failed with an exception.

What went wrong: 
A problem occurred configuring root project ‘android’.

The SDK directory ‘C:\Users\Administrator\AppData\Local\Android\sdk’ does not exist.
Try: 
Run with –stacktrace option to get the stack trace. Run with –info or –debug option to get more log output.

解决方案：

这里写图片描述

找到如图中的local.prooerties文件，将下图的sdk换成你的本地SDK的位置即可。 
这里写图片描述