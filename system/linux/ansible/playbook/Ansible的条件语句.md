
* [Ansible的条件语句 - CSDN博客 ](http://blog.csdn.net/kellyseeme/article/details/50609591)

Ansible的条件语句

# 1、    前言

在有的时候play的结果依赖于变量、fact或者是前一个任务的执行结果，从而需要使用到条件语句。
# 2、    When语句

有的时候在特定的主机需要跳过特定的步骤，例如在安装包的时候，需要指定主机的操作系统类型，或者是当操作系统的硬盘满了之后，需要清空文件等
         下面的例子表示为使用when语句，如下：
tasks:
  - name: "shutdownDebianflavoredsystems"
    command: /sbin/shutdown -t now
    when: ansible_os_family == "Debian"
 
 
         也可以使用括号来表示一组条件，如下所示：
tasks:
  - name: "shutdownCentOS6andDebian7systems"
    command: /sbin/shutdown -t now
    when: (ansible_distribution == "CentOS" and ansible_distribution_major_version == "6") or
          (ansible_distribution == "Debian" and ansible_distribution_major_version == "7")
 
 
         假设需要忽略一个语句的错误，根据执行的结果是成功还是失败从而执行不同的命令，如下（使用的是jinja2的过滤）：
tasks:
  - command: /bin/false
    register: result
    ignore_errors: True
  - command: /bin/something
    when: result|failed
  - command: /bin/something_else
    when: result|succeeded
  - command: /bin/still/something_else
    when: result|skipped
         当接收到一个变量是一个字符串的时候，然后想做一个数字的比较，那么可以使用如下的方式（在这个例子中远程主机上需要有lsb_package包）：
tasks:
  - shell: echo "only on Red Hat 6, derivatives, and later"
    when: ansible_os_family == "RedHat" and ansible_lsb.major_release|int >= 6
 
 
在playbooks中或者inventory清单中定义的变量也是可以使用，假设任务的执行依赖于一个布尔变量，如下：
vars:
  epic: true
 
         条件执行如下所示：
tasks:
    - shell: echo "This certainly is epic!"
      when: epic
 
         或者使用如下形式：
tasks:
    - shell: echo "This certainly isn't epic!"
      when: not epic
 
```yaml
#如果需要的变量没有定义，那么可以skip或者使用jinja2的defined如下所示：
tasks:
    - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
      when: foo is defined
 
    - fail: msg="Bailing out. this play requires 'bar'"
      when: bar is undefined
```
 
当结合使用when和with_items的时候，需要注意的是when语句会对每个item进行单独的处理，如下所示：
tasks:
    - command: echo {{ item }}
      with_items: [ 0,2,4,6,8,10 ]
      when: item > 5
 
# 3、    在roles中和include中使用when

当几个任务都是使用相同的条件的时候，那么可以将条件写在include之中，那么当写在include的时候，每个任务都会去判断条件，如下所示：
- include: tasks/sometasks.yml
  when: "'reticulatingsplines'inoutput"
 
         或者在roles中使用，如下：
- hosts: webservers
  roles:
     - { role:debian_stock_config,when:ansible_os_family == 'Debian' }
 
4、    条件导入

在playbook中可能会根据一些特定的标准从而做不同的事情，在一个playbook中工作在不同的平台和os版本是最好的例子
         如下的例子表示，在centos和debian中apache的包是不同的，从而可以使用以下：
```yaml         
---
- hosts: all
  remote_user: root
  vars_files:
    - "vars/common.yml"
    - [ "vars/{{ansible_os_family}}.yml","vars/os_defaults.yml" ]
  tasks:
  - name: make sure apache is running
    service: name={{ apache }} state=running
 
         另外，在变量文件中只包含key和values，如下：
---
# for vars/CentOS.yml
apache: httpd
somethingelse: 42
 ```
         如何工作的呢 ？当操作系统为centos的时候，那么会加载变量/vars/centos.yml，当文件不存在的时候，那么会加载defaults.yml，当没有找到任何文件的时候，那么就会出错。当操作系统为debian的时候，那么就会加载变量/vars/debian.yml，没有就加载defaults.yml
 
         当使用整个功能的时候，在运行playbook之前必须先安装facter或者ohai，也可以直接在playbook中使用如下所示：
```sh
# for facter
ansible -m yum -a "pkg=facter state=present"
ansible -m yum -a "pkg=ruby-json state=present"
 
# for ohai
ansible -m yum -a "pkg=ohai state=present"
 ```
# 5、    基于变量选择文件和模板

在有的时候，配置文件使用copy或者是template的时候，可能会依赖于变量。
下面的例子中表示使用template输出一个配置文件，在centos和debian中不同，如下：
- name: template a file
  template: src={{ item }} dest=/etc/myapp/foo.conf
  with_first_found:
    - files:
       - {{ ansible_distribution }}.conf
       - default.conf
      paths:
       - search_location_one/somedir/
       - /opt/other_location/somedir/
 
# 6、    注册变量

在playbook中可以使用变量的值便于其他的任务用到。
关键字register用来保存变量值，整个变量可以使用在template中，动作行中，或者是when语句中，如下所示：
- name: test play
  hosts: all
 
  tasks:
 
      - shell: cat /etc/motd
        register: motd_contents
 
      - shell: echo "motd contains the word hi"
        when: motd_contents.stdout.find('hi') != -1
 
         注册的变量值可以用stdout得到，或者用with_items得到，也可以使用stdout_lines得到，如下所示：
- name: registered variable usage as a with_items list
  hosts: all
 
  tasks:
 
      - name: retrieve the list of home directories
        command: ls /home
        register: home_dirs
 
      - name: add home dirs to the backup spooler
        file: path=/mnt/bkspool/{{ item }} src=/home/{{ item }} state=link
        with_items: home_dirs.stdout_lines
        # same as with_items: home_dirs.stdout.split()
 
 
版权声明：转载的时候请注明转载路径~~~