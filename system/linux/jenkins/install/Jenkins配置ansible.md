

Jenkins配置ansible - 一个运维的自我修养 https://my.oschina.net/luoyedao/blog/715049

Centos 7安装Jenkins，因为Jenkins需要java环境，安装之前要确认一下。

当然最简单的安装是到官网下载jenkins.war，因为Centos7中已经装好了java，所以就不安装了

直接用java -jar jenkins.war 通过浏览器http://ip:8080就可以访问，第一次启动会在启动结束的时候出现密码

也可以通过过yum安装配置自启动。

sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo 
sudo rpm --import http://pkg.jenkins-ci.org/redhat-stable/jenkins-ci.org.key 
sudo yum install jenkins

启动

sudo service jenkins restart 
sudo chkconfig jenkins on 

yum install ansible 别忘记用 ssh-keygen生产密钥一路回车默认就好

通过浏览器登陆成功以后在 系统管理--->管理插件--->可选插件 搜索ansible勾选ansible plugin即可。颜色高亮显示把AnsiColor装上。安装完成后如下图



安装完成后再搜索git或者GIT Client Plugin和GIT Plugin把git也随便装上。so easy。

安装完成后回到系统管理--->Global Tool Configuration----Ansible安装。点击Ansible安装配置如下图



完成后回到首页，点击新建。项目名为Ansible Ad-Hoc Commad，别的不用管，直接找到“构建”位置，配置如下图host pattern是要匹配的主机，file是hosts配置路径我就用默认的/etc/ansible/hosts下面。Credentials配置密钥，点击add，勾选



另外一个Ansible playbook步骤和这个一样，配置如下

    Ansible playbook测试文件都放在/etc/ansible/下面。如下：

[root@localhost ansible]# cat create_user.yaml 

---
- name: create_user

  hosts: web

  user: root

  gather_facts: false

  vars:

    - user: "ansi_user001_test"

  tasks:

    - name: create user

      user: name="{{ user }}"
配置完成后，点击“构建”执行结果如图