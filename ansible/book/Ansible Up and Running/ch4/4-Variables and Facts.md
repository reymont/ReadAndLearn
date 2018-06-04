
# Chapter 4. Variables and Facts

## 在命令行中设置变量

在ansible-playbook中，通过`-e var=value`传递变量拥有最高优先权

```sh
$ ansible-playbook example.yml -e token=12345
```

### 传参数

`$ ansible-playbook greet.yml -e greeting=hiya`
中间有空格
`$ ansible-playbook greet.yml -e 'greeting="hi there"'`

greet.yml
```yml
- name: pass a message on the command line
  hosts: localhost
  vars:
    greeting: "you didn't specify a message"
  tasks:
    - name: output a message
      debug: msg="{{ greeting }}"
```

### 传文件

`$ ansible-playbook greet.yml -e @greetvars.yml`
greetvars.yml
```yml
greeting: hiya
```