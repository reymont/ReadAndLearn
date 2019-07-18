https://blog.csdn.net/ymaini/article/details/82227680

问题
在Linux系统下， 通过进程的ID号， 找到进程的启动位置。

应用场景： 想重启某个占用资源较多的进程， 但是找不到启动位置。

解决
使用Linux命令 pwdx

1. 22521为进程的PID, 通过ps命令可以查看

$ pwdx 22521

pwdx
显示进程的当前工作路径
