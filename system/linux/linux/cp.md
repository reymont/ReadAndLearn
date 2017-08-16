


# overwrite

* [在linux下的使用复制命令cp，不让出现“overwrite”（文件覆盖）提示的方法。 - iw1210的专栏 - CSDN博客 ](http://blog.csdn.net/iw1210/article/details/46550707)

在linux下的使用复制命令cp，不让出现“overwrite”（文件覆盖）提示的方法。

一般我们在使用cp命令时加上-f选项，希望不让出现“overwrite”的提示（文件覆盖的提示）。如：
```sh
# cp -rf sourcefile targetdir 
或
#cp -r -f sourcefile targetdir
-r的意思是递归复制，也就是复制文件夹及其下所有文件。
-f的意思是遇到同名的文件时不提示，直接覆盖。
```

但是为什么加上-f了，还出现“overwrite”的提示呢？

这是因为系统为防止我们误操作，覆盖了不该覆盖的文件，而使用了命令的别名。使用alias命令查看一下：
```sh
# alias
alias cp='cp -i'
alias l.='ls -d .* --color=tty'
alias ll='ls -l --color=tty'
alias ls='ls --color=tty'
alias mv='mv -i'
alias rm='rm -i'
```

从上边我们可以看出，我们输入的cp命令，其实是“cp -i”命令。其他几个命令，如ll，ls mv，rm等也使用了别名。

第一种解决办法：
在cp前加上一个"\"符号就不使用别名运行了，如下：
```
# \cp -f sourcefile targetdir 
```
第二种解决办法：
编辑文件，注释掉别名。
```
# vi ~/.bashrc
```
在alias cp='cp -i'前加上“#”注释掉这行，wq!保存推出，然后重新登陆就可以了。

第三种方法

直接调用/bin/cp
[root@erpappdev erp_bak]# /bin/cp -f test_cp.txt test/