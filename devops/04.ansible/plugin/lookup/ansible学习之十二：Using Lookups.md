

ansible学习之十二：Using Lookups http://sapser.github.io/ansible/2014/07/22/ansible-using-lookups

在playbooks中可以使用一个名为lookup()的函数，该函数用于ansible从外部资源访问数据，根据第一个参数的不同，该函数具有不同的功能，典型的就是读取外部文件内容。注意lookup()只在本地执行，而不是在远程主机上执行。



第一个参数为file，表示获取外部文件内容

- hosts: all
  vars:
     contents: "{{ lookup('file', '/etc/foo.txt') }}"      #将值保存到变量中，参数都要引号引起来，不然出错
  tasks:
     - debug: msg="the value of foo.txt is {{ contents }}"

     - debug: msg="the value of foo.txt is {{ lookup('file', '/etc/foo.txt') }}"      #直接使用


第一个参数为password，表示生成一个随机明文密码，并存储到指定文件中，生成的密码包括大小写字母、数字和.,:-_，默认密码长度为20个字符，该长度可以通过传递一个额外参数length=<length>修改

---
- hosts: 127.0.0.1
  gather_facts: no
  tasks:
    - debug: msg="password - {{ lookup('password', '/tmp/random_pass.txt length=10') }}"
测试：

$ ansible-playbook test.yml 

PLAY [127.0.0.1] ************************************************************** 

TASK: [debug msg="password - ejL.Ho_.mb"] ************************************* 
ok: [127.0.0.1] => {
    "msg": "password - ejL.Ho_.mb"
}

PLAY RECAP ******************************************************************** 
127.0.0.1                  : ok=1    changed=0    unreachable=0    failed=0 

$ cat /tmp/random_pass.txt 
ejL.Ho_.mb
如果用来保存密码的文件已经存在，则不会往里写入任何数据，且会读取文件已有内容作为密码，如果文件存在且为空，则返回一个空字符串作为密码。

除了length=<length>外，从ansible1.4开始还加入了chars=<chars>参数，用于自定义生成密码的字符集，而不是默认的大小写字母、数字和.,:-_

---
- hosts: 127.0.0.1
  gather_facts: no
  tasks:
    #create a random password using only ascii letters:
    - debug: msg="password - {{ lookup('password', '/tmp/passfile1 chars=ascii_letters') }}"

    #create a random password using only digits:
    - debug: msg="password - {{ lookup('password', '/tmp/passfile2 chars=digits') }}"
    
    #create a random password using many different char sets:
    - debug: msg="password - {{ lookup('password', '/tmp/passfile3 chars=ascii_letters,digits,hexdigits,punctuation,,') }}"   #逗号本身用",,"表示
测试：

$ ansible-playbook test.yml 

PLAY [127.0.0.1] ************************************************************** 

TASK: [debug msg="password - funEtMBYbqWTUdPlfIGC"] *************************** 
ok: [127.0.0.1] => {
    "msg": "password - funEtMBYbqWTUdPlfIGC"
}

TASK: [debug msg="password - 79223199493177921267"] *************************** 
ok: [127.0.0.1] => {
    "msg": "password - 79223199493177921267"
}

TASK: [debug msg="password - 0,92YO4R0m6iqg2=4RA8"] *************************** 
ok: [127.0.0.1] => {
    "msg": "password - 0,92YO4R0m6iqg2=4RA8"
}

PLAY RECAP ******************************************************************** 
127.0.0.1                  : ok=3    changed=0    unreachable=0    failed=0 


其他类型

---
- hosts: all
  tasks:

     - debug: msg="{{ lookup('env','HOME') }} is an environment variable"

     - debug: msg="{{ lookup('pipe','date') }} is the raw result of running this command"

     - debug: msg="{{ lookup('redis_kv', 'redis://localhost:6379,somekey') }} is value in Redis for somekey"

     - debug: msg="{{ lookup('dnstxt', 'example.com') }} is a DNS TXT record for example.com"

     - debug: msg="{{ lookup('template', './some_template.j2') }} is a value from evaluation of this template"