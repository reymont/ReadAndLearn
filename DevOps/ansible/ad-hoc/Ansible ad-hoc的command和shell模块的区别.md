

* [Ansible ad-hoc的command和shell模块的区别 - Linux运维 - 51CTO技术博客 ](http://haohaozhang.blog.51cto.com/9176600/1831383)

* ad-hoc
  * 即时
  * playbook适用于批量部署环境，一般不用经常改动
  * 适用于业务变更等操作
  * 输入ad-hoc命令后，会生成一个可执行的python脚本文件
  * 这个脚本文件包含了命令行的所有信息
  * 然后把它拷贝到远程机器上执行
* ad-hoc命令的两个模块
  * subprocess.Popen(args,*kwargs)函数
  * command
    * shell=True，一个调用了shell
  * shell
    * shell=False，一个没有调用shell