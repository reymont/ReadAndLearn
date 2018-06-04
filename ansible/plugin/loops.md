
# http://sapser.github.io/ansible/2014/07/21/ansible-loops

当遇到一些重复的任务，比如通过yum模块安装多个包，为每个包写一个task就太无聊了，可以在playbook中使用循环来解决这类问题。



with_items

标准循环，最常用到的就是它，with_items可以用于迭代一个列表或字典，通过{{ item }}获取每次迭代的值，如通过一条task创建多个用户：

- name: add several users
  user: name={{ item }} state=present groups=wheel               #创建user1、user2、user3三个用户
  with_items:               #这里还可以直接写成with_items: ['user1', 'user2', 'user3']
     - user1
     - user2
     - user3
迭代一个简单字典：

- name: add several users
  user: name={{ item.name }} state=present groups={{ item.groups }}
  with_items:
    - { name: 'user1', groups: 'wheel' }
    - { name: 'user2', groups: 'root' }


with_nested

嵌套循环

- name: give users access to multiple databases
  mysql_user: name={{ item[0] }} priv={{ item[1] }}.*:ALL append_privs=yes password=foo
  with_nested:
    - [ 'alice', 'bob', 'eve' ]
    - ['clientdb', 'employeedb', 'providerdb']              
上面例子不容易看懂，我们通过debug模块写另一个例子测试：

---
- hosts: 127.0.0.1
  gather_facts: no
  tasks:
    - debug: msg="{{ item[0] }} - {{ item[1] }}"
      with_nested:
        - ['alice', 'bob']
        - ['clientdb', 'employeedb', 'providerdb']
执行：

$ ansible-playbook test.yml 

PLAY [127.0.0.1] ************************************************************** 

TASK: [debug msg="{{item[0]}} - {{item[1]}}"] ********************************* 
ok: [127.0.0.1] => (item=['alice', 'clientdb']) => {
    "item": [         #每次循环item变量是一个双元素列表
        "alice", 
        "clientdb"
    ], 
    "msg": "alice - clientdb"
}
ok: [127.0.0.1] => (item=['alice', 'employeedb']) => {
    "item": [
        "alice", 
        "employeedb"
    ], 
    "msg": "alice - employeedb"
}
ok: [127.0.0.1] => (item=['alice', 'providerdb']) => {
    "item": [
        "alice", 
        "providerdb"
    ], 
    "msg": "alice - providerdb"
}
ok: [127.0.0.1] => (item=['bob', 'clientdb']) => {
    "item": [
        "bob", 
        "clientdb"
    ], 
    "msg": "bob - clientdb"
}
ok: [127.0.0.1] => (item=['bob', 'employeedb']) => {
    "item": [
        "bob", 
        "employeedb"
    ], 
    "msg": "bob - employeedb"
}
ok: [127.0.0.1] => (item=['bob', 'providerdb']) => {
    "item": [
        "bob", 
        "providerdb"
    ], 
    "msg": "bob - providerdb"
}

PLAY RECAP ******************************************************************** 
127.0.0.1                  : ok=1    changed=0    unreachable=0    failed=0 
所以最开始例子其实相当于两个for循环：

for user in [ 'alice', 'bob', 'eve' ]:
    for db in ['clientdb', 'employeedb', 'providerdb']:
        mysql_user: name=user priv=db.*:ALL append_privs=yes password=foo


with_dict

迭代字典，接受一个字典类型的值，{{ item.key }}是字典的键，{{ item.value }}是字典的值，字典值还可以是一个子字典

在变量文件定义一个复杂的字典变量：

---
users:
  alice:
    name: Alice Appleworth
    telephone: 123-456-7890
  bob:
    name: Bob Bananarama
    telephone: 987-654-3210
playbook文件test.yml内容：

---
- hosts: 127.0.0.1
  gather_facts: no
  tasks:
    - name: Print phone records
      debug: msg="User {{ item.key }} is {{ item.value.name }} ({{ item.value.telephone }})"
      with_dict: users
执行：

$ ansible-playbook test.yml 
TASK: [Print phone records] ***************************************************
ok: [127.0.0.1] => (item={'value': {'name': 'Bob Bananarama', 'telephone': '987-654-3210'}, 'key': 'bob'}) => {
    "item": {
        "key": "bob",
        "value": {
            "name": "Bob Bananarama",
            "telephone": "987-654-3210"
        }
    },
    "msg": "User bob is Bob Bananarama (987-654-3210)"
}
ok: [127.0.0.1] => (item={'value': {'name': 'Alice Appleworth', 'telephone': '123-456-7890'}, 'key': 'alice'}) => {
    "item": {
        "key": "alice",
        "value": {
            "name": "Alice Appleworth",
            "telephone": "123-456-7890"
        }
    },
    "msg": "User alice is Alice Appleworth (123-456-7890)"
}


with_fileglob

匹配指定目录下的所有文件(非递归)，或指定目录下和pattern匹配的文件

---
- hosts: all
  tasks:
    - name: first ensure our target directory exists
      file: dest=/etc/fooapp state=directory

    - name: copy each file over that matches the given pattern
      copy: src={{ item }} dest=/etc/fooapp/ owner=root mode=600
      with_fileglob:
        - /playbooks/files/fooapp/*          #这里如果是"*.py"，就只会复制该目录下所有py文件


with_together

迭代并行数据集

---
- hosts: '192.168.12.238'
  tasks:
  - debug: msg="{{ item.0 }} and {{ item.1 }}"
    with_together:          #相当于: for item in [('a',1), ('b', 2), ('c', 3), ('d', 4)]
      - ['a', 'b', 'c', 'd']
      - [1, 2, 3, 4]


with_subelements

迭代子元素

---
- hosts: 127.0.0.1
  gather_facts: no
  vars:
    users:      #定义一个字典变量
      - name: alice
        authorized:    #列表
          - /tmp/alice/onekey.pub
          - /tmp/alice/twokey.pub
      - name: bob
        authorized:
          - /tmp/bob/id_rsa.pub
  tasks:
    - debug: msg="{{ item.0.name }} - {{ item.1 }}"
      with_nested:
        - users
        - authorized
执行：

$ ansible-playbook test.yml 

PLAY [127.0.0.1] ************************************************************** 

TASK: [debug msg="{{item.0.name}} - {{item.1}}"] ****************************** 
ok: [127.0.0.1] => (item=[{'name': 'alice', 'authorized': ['/tmp/alice/onekey.pub', '/tmp/alice/twokey.pub']}, 'authorized']) => {
    "item": [     #每次迭代item变量的结构
        {
            "authorized": [
                "/tmp/alice/onekey.pub", 
                "/tmp/alice/twokey.pub"
            ], 
            "name": "alice"
        }, 
        "authorized"
    ], 
    "msg": "alice - authorized"
}
ok: [127.0.0.1] => (item=[{'name': 'bob', 'authorized': ['/tmp/bob/id_rsa.pub']}, 'authorized']) => {
    "item": [
        {
            "authorized": [
                "/tmp/bob/id_rsa.pub"
            ], 
            "name": "bob"
        }, 
        "authorized"
    ], 
    "msg": "bob - authorized"
}

PLAY RECAP ******************************************************************** 
127.0.0.1                  : ok=1    changed=0    unreachable=0    failed=0


with_sequence

按照升序生成一个数字序列，可以指定开始(start)、结束(stop)和步长(stride)

---
- hosts: all
  tasks:
    - user: name={{ item }} state=present groups=evens
      with_sequence: start=1 end=32 format=testuser%02d          #创建用户testuser01、testuser02、...、testuser32

    - file: dest=/var/stuff/{{ item }} state=directory
      with_sequence: start=0 end=20 stride=5               #stride表示步长step，也就是间隔

    # a simpler way to use the sequence plugin create 4 groups
    - group: name=group{{ item }} state=present
      with_sequence: count=4


with_random_choice

从列表中随机选择一项

- debug: msg={{ item }}
  with_random_choice:               #每次都随机选择一项
     - "go through the door"
     - "drink from the goblet"
     - "press the red button"
     - "do nothing"


until

不停重试，直到某些条件完成

- shell: /usr/bin/foo
  register: result          #保存命令结果，和until搭配使用时，result还有个attempts属性，表示当前重试次数
  until: result.stdout.find("all systems go") != -1          
  retries: 5
  delay: 10
不停重新执行命令，直到命令输出中出现”all systems go”，或者重试次数达到5次间隔10秒，默认重试3次间隔5秒



with_first_found

查找并返回列表中第一个存在的文件

简略版：

- name: INTERFACES | Create Ansible header for /etc/network/interfaces
  template: src={{ item }} dest=/etc/foo.conf
  with_first_found:          #第一个文件不存在，就去找第二个文件
    - "{{ansible_virtualization_type}_foo.conf"
    - "default_foo.conf"
高级版：

- name: some configuration template
  template: src={{ item }} dest=/etc/file.cfg mode=0444 owner=root group=root
  with_first_found:
    - files:
       - "{{inventory_hostname}}/etc/file.cfg"
      paths:
       - ../../../templates.overwrites
       - ../../../templates
    - files:
        - etc/file.cfg
      paths:
        - templates


with_lines

按行迭代命令输出

---
- hosts: "192.168.12.238"
  tasks:
  - debug: msg="stdout - {{ item }}"
    with_lines: /bin/echo -e "111\n222\n333"          #按行迭代echo命令的输出
通过之前学过的with_items也能达到同样的效果

---
- hosts: "192.168.12.238"
  tasks:
  - shell: /bin/echo -e "111\n222\n333"
    register: results
  - debug:  msg="stdout - {{ item }}"
    with_items: results.stdout_lines


with_indexed_items

迭代一个列表，获取每一项的索引和值，{{ item.0 }}是索引，{{ item.1 }}是值

- name: indexed loop demo
  debug: msg="at array position {{ item.0 }} there is a value {{ item.1 }}"
  with_indexed_items: ['a', 'b', 'c']


with_flattened

展开嵌套列表并循环，如[1, [2, [3]]]展开为[1, 2, 3]并循环这个列表

---
- hosts: "192.168.12.238"
  vars:
    packages_base:
      - ['foo-package', 'bar-package']
    packages_apps:
      - [['one-package', 'two-package']]
      - [['red-package'], ['blue-package']]
  tasks:
    - name: indexed loop demo
      debug: msg="value - {{ item }}"
      with_flattened:
        - packages_base
        - packages_apps


register

注册一个标量，用来保存命令task的输出。在循环中使用register，数据结构会变得不同，注册变量会包含一个results属性，该属性的值是一个列表，包含该模块本次循环的所有响应数据：

- shell: echo "{{ item }}"
  with_items:
    - one
    - two
  register: echo
此时echo变量的内容为：

{
    "changed": true,
    "msg": "All items completed",
    "results": [
        {
            "changed": true,
            "cmd": "echo \"one\" ",
            "delta": "0:00:00.003110",
            "end": "2013-12-19 12:00:05.187153",
            "invocation": {
                "module_args": "echo \"one\"",
                "module_name": "shell"
            },
            "item": "one",
            "rc": 0,
            "start": "2013-12-19 12:00:05.184043",
            "stderr": "",
            "stdout": "one"
        },
        {
            "changed": true,
            "cmd": "echo \"two\" ",
            "delta": "0:00:00.002920",
            "end": "2013-12-19 12:00:05.245502",
            "invocation": {
                "module_args": "echo \"two\"",
                "module_name": "shell"
            },
            "item": "two",
            "rc": 0,
            "start": "2013-12-19 12:00:05.242582",
            "stderr": "",
            "stdout": "two"
        }
    ]
}
在随后一个task中迭代echo.results这个列表：

- name: Fail if return code is not 0
  debug: msg="The command ({{ item.cmd }}) did not have a 0 return code"
  when: item.rc != 0
  with_items: echo.results