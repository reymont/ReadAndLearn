
* [ansible的playbook配置及template模板的使用 - 峰云，就她了。 - 51CTO技术博客 ](http://rfyiamcool.blog.51cto.com/1030776/1413031/)


```yaml
#这个是你选择的主机
- hosts: webservers
#这个是变量
  vars:
    http_port: 80
    max_clients: 200
#远端的执行权限
  remote_user: root
  tasks:
#利用yum模块来操作
  - name: ensure apache is at the latest version
    yum: pkg=httpd state=latest
  - name: write the apache config file
    template: src=/srv/httpd.j2 dest=/etc/httpd.conf
#触发重启服务器
    notify:
    - restart apache
  - name: ensure apache is running
    service: name=httpd state=started
#这里的restart apache 和上面的触发是配对的。这就是handlers的作用。相当于tag
  handlers:
    - name: restart apache
      service: name=httpd state=restarted
```

# sudo

```yaml
- hosts: web
  remote_user: xiaorui
  tasks:
    - service: name=nginx state=started
      sudo: yes
```

# user.yaml

创建一个xiaorui的用户，里面引用了一个user的变量，用jinja2模板给赋值进去了

```sh
#执行
ansible-playbook user.yaml
#验证
ansible web -m shell -a "id xiaorui"
```

```yaml
- name: create user
  hosts: web
  user: root
  gather_facts: false
  vars:
  - user: "xiaorui"
  tasks:
  - name: create {{ user }}
    user: name="{{ user }}"
```

# 启动nginx

```sh
#监听
ansible web -m shell -a "lsof -i :80"
```

```yaml
- name: create user
  hosts: web
  user: root
  gather_facts: false
  vars:
  - user: "xiaorui"
  tasks:
  - name: create {{ user }}
    user: name="{{ user }}"
  tasks:
  - service: name=nginx state=started
```

# python-selinux

使用copy传送文件的时候，经常出些问题，是ansible需要python-selinux包而已

yum install -y libselinux-python