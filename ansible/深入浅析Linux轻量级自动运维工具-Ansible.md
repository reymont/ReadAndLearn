
* [深入浅析Linux轻量级自动运维工具-Ansible_Linux_脚本之家 ](http://www.jb51.net/article/124632.htm)
* [Linux轻量级自动运维工具-Ansible浅析 - ~微风~ - 51CTO技术博客 ](http://weiweidefeng.blog.51cto.com/1957995/1895261)


```sh
#Ansible是什么
yum info ansible
```

* ansible特性
  * 模块化：调用特定的模块，完成特定的任务
  * 基于Python语言开发，由Paramiko, PyYAML和Jinia2三个核心库实现
  * 部署简单：agentless
  * 支持自定义模块，使用任意编程语言
  * 强大的playbook机制
  * 幂等性
* 安装
  * 程序
    * ansible
    * ansible-playbook
    * ansible-doc
  * 配置文件
    * /etc/ansible/ansible.cfg
  * 主机清单
    * /etc/ansible/hosts
  * 插件目录
    * /usr/share/ansible_plugins
  * 安装
    * yum install -y ansible
* 命令使用
  * Usage: ansible <host-pattern> [options]
    * 常用选项：
      -m MOD_NAME
      -a MOD_ARGS
* 配置Host Inventory
  * /etc/ansible/hosts
    [group_id]
    HOST_PATTERN1
    HOST_PATTERN2
  * 备份默认配置文件
    cp host{,.bak}