
ansible官方文档翻译之变量 - CSDN博客 
http://blog.csdn.net/kellyseeme/article/details/50584775

# 1、    变量名

变量名用字母，数字和下划线，变量名的总是用字母进行开头，例如foo_port和foo5就是一个好的命名。而foo-port，foo.port，foo port和23则不是一个变量名。
YAML支持以下的变量格式，用字典来进行存储变量，如下：
foo:
  field1: one
  field2: two
 
那么可以用下面的方式来引用变量，如下：
foo['field1']
foo.field1
--两种方法均表示值为one
在进行变量命名的时候，注意一些保留关键字，如下：
add, append, as_integer_ratio, bit_length, capitalize, center, clear, conjugate, copy, count, decode, denominator, difference,difference_update, discard, encode, endswith, expandtabs, extend, find, format, fromhex, fromkeys, get, has_key, hex, imag,index, insert, intersection, intersection_update, isalnum, isalpha, isdecimal, isdigit, isdisjoint, is_integer, islower,isnumeric, isspace, issubset, issuperset, istitle, isupper, items, iteritems, iterkeys, itervalues, join, keys, ljust, lower,lstrip, numerator, partition, pop, popitem, real, remove, replace, reverse, rfind, rindex, rjust, rpartition, rsplit, rstrip,setdefault, sort, split, splitlines, startswith, strip, swapcase, symmetric_difference, symmetric_difference_update, title,translate, union, update, upper, values, viewitems, viewkeys, viewvalues, zfill.
# 2、    定义变量

定义变量的位置有很多，可以在playbook中定义变量，可以在inventory文件中定义变量，在playbook中定义变量形式如下：
- hosts: webservers
  vars:
    http_port: 80
 
在使用roles和inclued的时候，也是可以定义变量的
在使用模板语言jinja2的时候，也是可以定义变量的
Ansible允许你在playbook中引用变量使用jinja2的模板，在jinja2中可以使用更加复杂的模板
在一个简单的模板中，可以使用如下的方式来使用变量：
My amp goes to {{ max_amp_value }}
--最基本的变量替换方式
在playbook中，还可以使用如下的方式来使用变量：
template: src=foo.cfg.j2 dest={{ remote_install_path }}/foo.cfg
--使用一个变量来决定哪个位置去存放文件
 
在模板中，jinja2允许你使用循环loops和条件conditions，但是在playbook中，是不会使用的，ansible的playbook是纯YAML，从而不会使用这些
 
当你在使用变量的时候，如果是用变量名开头，那么必须用引号进行包括起来，如下是不能正常运行的：
- hosts: app_servers
  vars:
      app_path: {{ base_path }}/22
 
如下是可以正常运行的：
```yml
- hosts: app_servers
  vars:
       app_path: "{{base_path}}/22"
#如果是变量开头，那么必须将所有的用引号进行包括起来
```
# 3、    系统变量：FACTS

除了以上所讲述的变量的位置，还可以从系统变量FACTS中找到变量，查看系统信息如下所示：
ansible hostname -m setup
 
执行此命令后会返回大量的变量的内容，如下所示例子：

在以上的信息中，如果要在playbook中或模板中引用第一块硬盘的模型变量，那么可以使用如下：
{{ansible_devices.sda.model }}
 
使用hostname可以使用如下：
{{ansible_nodename }}
 
并且不合格的主机名称会显示第一个点前面的内容，如下：
{{ansible_hostname }}
 
 
FACTS主要使用在条件语句中和模板中。
# 4、    关闭FACTS

当你的主机系统不需要使用FACTS的时候，可以在playbook中关闭FACTS，从而可以减少数据的传输，如下所示：
- hosts: whatever
  gather_facts: no
 
# 5、    本地FACTS（Facts.d）

Ansible中playbook里使用的变量值可以从FACTS获取得到。在使用的时候，ansible都是自动的获取到FACTS变量内容使用的是setup模块。
当需要使用到一些指定的变量的时候，可以自己书写一份Facts.d，从而来使用这些本地的变量
 
假设存在一份Facts.d的内容如下（/etc/ansible/facts.d/preferences.fact）：
[general]
asdf=1
bar=2
 
在上面的例子中，从而创建了一个名称为general的组包括asdf和bar，在验证的时候可以使用如下命令：
ansible <hostname> -m setup -a "filter=ansible_local"
 
从而可以看到如下结果：
"ansible_local": {
        "preferences": {
            "general": {
                "asdf" : "1",
                "bar"  : "2"
            }
        }
 }
 
在playbook中或者是template中可以使用如下的方式来引用变量：
{{ansible_local.preferences.general.asdf }}
 
使用的是local这个命名空间，从而防止本地变量将系统变量进行了覆盖
 
当有一个playbook是将本地的fact进行拷贝的时候，注意要显示进行运行setup的模块，否则只会在下一个play中得到这些变量，如下所示：
- hosts: webservers
  tasks:
    - name: create directory for ansible custom facts
      file: state=directory recurse=yes path=/etc/ansible/facts.d
    - name: install custom impi fact
      copy: src=ipmi.fact dest=/etc/ansible/facts.d
    - name: re-read facts after adding custom fact
      setup: filter=ansible_local
 
# 6. 缓存FACT

在有的情况下，可能一个服务器在引用一个变量的时候同时也引用了另外一个变量，如下所示：
{{hostvars['asdf.example.com']['ansible_os_family'] }}
 
当使用缓存FACT的时候，主要是用来做临时任务的时候能直接hit到，从而提高速度
当需要从缓存FACT中收益时，在play中需要修改gathering的配置，设置为smart或者explicit或者将gather_facts设置为false
目前情况下，ansible使用redis和jsonfile来进行持久化缓存。
当使用redis进行缓存的时候，在ansible.cfg中进行开启，如下：
```yml
[defaults]
gathering = smart
fact_caching = redis
fact_caching_timeout = 86400
# seconds
 
当使用redis的时候，需要用下面的os命令进行开启，如下：
yum install redis
service redis start
pip install redis
 
 
当使用jsonfile进行缓存的时候，在ansible.cfg中进行开启，如下：
[defaults]
gathering = smart
fact_caching = jsonfile
fact_caching_connection = /path/to/cachedir #本地写入路径
fact_caching_timeout = 86400 #facts保存的时间
# seconds
```
 
6、    注册变量

变量还有一个用途就是当运行一个命令的时候，可以使用变量来存储结果，这个变量在从模块到模块的时候，是可以发生变化的。在执行playbook的时候可以使用参数-v来显示变量的值。
在ansible中执行完一个任务之后，可以将结果保存在变量中，从而在后面使用，如下所示：

```yml
- hosts: web_servers
 
  tasks:
 
     - shell: /usr/bin/foo
       register: foo_result
       ignore_errors: True
 
     - shell: /usr/bin/bar
       when: foo_result.rc == 5
```
在这个里面使用注册变量的时候，生命周期和fact的生命周期是一样的
 
当任务失败或者跳过的时候，这个变量保存的是失败或者跳过的状态，唯一能避免这个变量的方法是使用tags
 
# 7、    接触复杂的变量数据

```yml
对于嵌套的数据结构，可以用如下的方式得到数据：
{{ansible_eth0["ipv4"]["address"] }}
 
或者使用如下的方式：
{{ansible_eth0.ipv4.address }}
 
类似的，可以使用数组中的第一个元素：
{{foo[0] }}
 
 
Ansible会提供一些神奇的变量，如hostvars, group_names, and groups重要的变量，，用户不能自己使用这些名字的变量，这些变量名是保留字，environment 也是的
Hostvars可以让你询问其他主机的变量，包括收集到的其他主机的facts，这种是不能显示设置的，但是依然可以找到这个变量。
如果数据服务器想使用fact的值从另外一个节点上，或者是另外节点分配的inventory文件，从而可以做如下操作：
{{hostvars['test.example.com']['ansible_distribution'] }}
 
另外group_names是inventory文件中的一个数组或者是列表，从而此种可以在一个组中进行遍历，如下所示：
{% if 'webserver' in group_names %}
   # some part of a configuration file that only applies to webservers
{% endif %}
 
Groups是在inventory文件中的所有组或者是主机，这种可以在一个组中遍历所有的主机，如下所示：
{% for host in groups['app_servers'] %}
   # something that applies to all app servers.
{% endfor %}
 
一种普遍的做法是使用组然后查找到所有的主机IP地址，如下所示：
{% for host in groups['app_servers'] %}
   {{ hostvars[host]['ansible_eth0']['ipv4']['address'] }}
{% endfor %}
```
 
inventory_hostname 表示在ansible的inventory文件中设置的主机名
inventory_hostname_short 表示从开始到第一个点的位置，剩余的domain不包含
play_hosts 表示当前play中的主机列表
delegate_to 表示当前主机的赋权操作
inventory_dir 表示inventory文件名称
role_path 表示会返回当前role的路径名称，只能在整个role中生效

# 8、    分割变量文件

```yml
在有的时候，会需要将变量分割开来，从而将变量保存在不同的文件之中。
分割变量文件的时候，可以使用外部变量文件或者是文件，如下所示：
---
 
- hosts: all
  remote_user: root
  vars:
    favcolor: blue
  vars_files:
    - /vars/external_vars.yml
 
  tasks:
 
  - name: this is just a placeholder
    command: /bin/echo foo
 
在使用分割变量文件的时候，可以避免敏感的参数被获取
变量文件中的内容是简单的YAML字典，如下所示：
---
# in the above example, this would be vars/external_vars.yml
somevar: somevalue
password: magic
``` 

# 9、    在命令行中传递参数

除了vars_prompt和vars_files，还可以直接在命令行中进行传递参数，如下所示：
ansible-playbook release.yml --extra-vars "version=1.23.45 other_variable=foo"
 
从而可以使用这种在playbook中进行设置主机和用户，如下所示：
```yml
---
 
- hosts: '{{hosts}}'
  remote_user: '{{user}}'
 
  tasks:
     - ...
ansible-playbook release.yml --extra-vars "hosts=vipers user=starbuck"
 
 
传递外部变量的时候，也可以使用json数据的方式，如下所示：
--extra-vars '{"pacman":"mrs","ghosts":["inky","pinky","clyde","sue"]}'
 
在使用key=value的时候显得更加简单
 
外部变量文件也可以使用@符号来进行引用，如下所示：
--extra-vars "@some_file.json"
```
 
# 10、 变量优先级

如果变量在不同的地方进行定义，并且名字相同，那么是会造成覆盖的效果的。
在2.x中，优先级顺序如下：
·         role defaults [1]
·         inventory vars [2]
·         inventory group_vars
·         inventory host_vars
·         playbook group_vars
·         playbook host_vars
·         host facts
·         registered vars
·         set_facts
·         play vars
·         play vars_prompt
·         play vars_files
·         role and include vars
·         block vars (only for tasks in block)
·         task vars (only for the task)
·         extra vars
优先级逐步上升的原则
# 11、 变量范围

Ansible具有三个变量范围：
Global：这个是由配置文件、环境变量和命令行所设置
Play：每个play包含的结构，变量入口，include_Vars，默认的role和变量
Host：和主机直接关联的变量，如inventory文件中，facts中和注册的任务输出结果
# 12、 变量举例

```yml
组变量超级强大。定义的路径为group_vars/al，如下所示：
---
# file: /etc/ansible/group_vars/all
# this is the site wide default
ntp_server: default-time.example.com
 
局部变量定义的位置为：group_vars/region如果这个组是all组中的一员，会覆盖整个变量，如下所示：
---
# file: /etc/ansible/group_vars/boston
ntp_server: boston-time.example.com
 
当使用主机变量的时候，会覆盖组的变量值，如下所示：
---
# file: /etc/ansible/host_vars/xyz.boston.example.com
ntp_server: override.example.com
 
规则如下：
Child groups override parent groups, and hosts always override their groups.
 
在使用roles的时候，默认路径下roles/x/defaults/main.yml的优先级比较低，如下：
---
# file: roles/x/defaults/main.yml
# if not overridden in inventory or as a parameter, this is the value that will be used
http_port: 80
 
当要使用roles的时候，如果要确保变量值不会被默认值覆盖，也不会被inventory文件中的变量覆盖，那么放置路径为roles/x/vars/main.yml，如下所示：
---
# file: roles/x/vars/main.yml
# this will absolutely be used in this role
http_port: 80
``` 
 
当在使用role的时候，如果想覆盖默认值，那么可以像如下例子传递参数：
roles:
   - { role:apache,http_port:8080 }
 
 
从而也可以使用如下的方式：
roles:
   - { role:app_user,name:Ian    }
   - { role:app_user,name:Terry  }
   - { role:app_user,name:Graham }
   - { role:app_user,name:John   }
 
 
一般来说，变量在一个role中设置之后，对于其他的role来说，变量也是可以使用的，如下所示：（变量定义位置：roles/common/vars/main.yml）
roles:
   - { role:common_settings }
   - { role:something,foo:12 }
   - { role:something_else }
 
