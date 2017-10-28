

* [ssh登陆之忽略known_hosts文件 - CSDN博客 ](http://blog.csdn.net/yasaken/article/details/7348441)

有以下两个解决方案：
1. 手动删除修改known_hsots里面的内容；
2. 修改配置文件“~/.ssh/config”，加上这两行，重启服务器。
   StrictHostKeyChecking no
   UserKnownHostsFile /dev/null

优缺点：
1. 需要每次手动删除文件内容，一些自动化脚本的无法运行（在SSH登陆时失败），但是安全性高；
2. SSH登陆时会忽略known_hsots的访问，但是安全性低；