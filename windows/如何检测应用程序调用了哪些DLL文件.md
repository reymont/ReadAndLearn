如何检测应用程序调用了哪些DLL文件？ - CSDN博客 https://blog.csdn.net/z215367701/article/details/77740236

之前所用的检测工具是Dllshow，后来突然不能用了，VS以前有Depends，后来高级版本也没了。最近找到一种简单方便的方法，利用windowsx系统自带的功能。

运行你想知道的应用程序，然后在进入dos窗口（开始->运行->command），输入命令:

tasklist /m |more

就可以看到你那个应用程序调用的dll文件了

或者
tasklist /m >c:\dll.txt

就把结果保存在c:\dll.txt文件里面，想怎么看就怎么看！