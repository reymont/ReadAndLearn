

* [自动化运维工具Ansible之Playbooks的when语句 - diannaowa - 51CTO技术博客 ](http://diannaowa.blog.51cto.com/3219919/1681885/)

Ansible提供when语句，可以控制任务的执行流程。

```yml
tasks:
      - name: "shutdown Debian flavored systems"
        command: /sbin/shutdown -t now
        when: ansible_os_family == "Debian

tasks:
      - name: "shutdown CentOS 6 and 7 systems"
        command: /sbin/shutdown -t now
        when: ansible_distribution == "CentOS" and
              (ansible_distribution_major_version == "6" or ansible_distribution_major_version == "7")

#在`when`语句中也可以使用过滤器。如，我们想跳过一个语句执行中的错误，但是后续的任务的执行需要由该任务是否成功执行决定：

tasks:
      - command: /bin/false
        register: result
        ignore_errors: True
      - command: /bin/something
        when: result|failed
      - command: /bin/something_else
        when: result|success
      - command: /bin/still/something_else
        when: result|skipped
# 有时候需要将一个字符串的变量转换为整数来进行数字比较：
 tasks:
      - shell: echo "only on Red Hat 6, derivatives, and later"
        when: ansible_os_family == "RedHat" and ansible_lsb.major_release|int >= 6
# 如果引用的变量没有被定义，使用Jinja2的`defined`测试，可以跳过或者是抛出错误：
   tasks:
        - shell: echo "I've got '{{ foo }}' and am not afraid to use it!"
          when: foo is defined
     
        - fail: msg="Bailing out. this play requires 'bar'"
          when: bar is not defined

# register关键字可以将任务执行结果保存到一个变量中，该变量可以在模板或者playbooks文件中使用：

- name: test play
      hosts: all
     
      tasks:
     
          - shell: cat /etc/motd
            register: motd_contents
     
          - shell: echo "motd contains the word hi"
            when: motd_contents.stdout.find('hi') != -1
```