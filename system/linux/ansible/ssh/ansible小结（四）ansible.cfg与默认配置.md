

ansible小结（四）ansible.cfg与默认配置 - 运维之路
 http://www.361way.com/ansible-cfg/4401.html

Ansible默认安装好后有一个配置文件`/etc/ansible/ansible.cfg`，该配置文件中定义了ansible的主机的默认配置部分，如默认是否需要输入密码、是否开启sudo认证、action_plugins插件的位置、hosts主机组的位置、是否开启log功能、默认端口、key文件位置等等。

```conf
[defaults]
# some basic default values...
hostfile       = /etc/ansible/hosts   \\指定默认hosts配置的位置
# library_path = /usr/share/my_modules/
remote_tmp     = $HOME/.ansible/tmp
pattern        = *
forks          = 5
poll_interval  = 15
sudo_user      = root  \\远程sudo用户
#ask_sudo_pass = True  \\每次执行ansible命令是否询问ssh密码
#ask_pass      = True  \\每次执行ansible命令时是否询问sudo密码
transport      = smart
remote_port    = 22
module_lang    = C
gathering = implicit
host_key_checking = False    \\关闭第一次使用ansible连接客户端是输入命令提示
log_path    = /var/log/ansible.log \\需要时可以自行添加。chown -R root:root ansible.log
system_warnings = False    \\关闭运行ansible时系统的提示信息，一般为提示升级
# set plugin path directories here, separate with colons
action_plugins     = /usr/share/ansible_plugins/action_plugins
callback_plugins   = /usr/share/ansible_plugins/callback_plugins
connection_plugins = /usr/share/ansible_plugins/connection_plugins
lookup_plugins     = /usr/share/ansible_plugins/lookup_plugins
vars_plugins       = /usr/share/ansible_plugins/vars_plugins
filter_plugins     = /usr/share/ansible_plugins/filter_plugins
fact_caching = memory
[accelerate]
accelerate_port = 5099
accelerate_timeout = 30
accelerate_connect_timeout = 5.0
# The daemon timeout is measured in minutes. This time is measured
# from the last activity to the accelerate daemon.
accelerate_daemon_timeout = 30
```

在ansible.cfg配置文件中，也会找到如下部分：
```conf
# uncomment this to disable SSH key host checking
host_key_checking = False  
```
默认host_key_checking部分是注释的，通过找开该行的注释，同样也可以实现跳过 ssh 首次连接提示验证部分。由于配置文件中直接有该选项，所以推荐用方法2 。

# 其他部分

由于官方给的说明比较详细，同时ansible.cfg 文件本身默认也有注释提示部分，所以不做过多说明，这里再举个例子，默认ansible 执行的时候，并不会输出日志到文件，不过在ansible.cfg 配置文件中有如下行：
```yml
# logging is off by default unless this path is defined
# if so defined, consider logrotate
log_path = /var/log/ansible.log
```

同样，默认log_path这行是注释的，打开该行的注释，所有的命令执行后，都会将日志输出到`/var/log/ansible.log` 文件，便于了解在何时执行了何操作及其结果，如下：