
* [ansible playbook如何处理错误（rescue） | 张志明的个人博客 ](http://www.503error.com/2017/ansible-playbook%E5%A6%82%E4%BD%95%E5%A4%84%E7%90%86%E9%94%99%E8%AF%AF%EF%BC%88rescue%EF%BC%89/1198.html)



```yml
tasks:
  - block:
      - debug: msg='i execute normally'
      - command: /bin/false
      - debug: msg='i never execute, cause ERROR!'
    rescue:
      - debug: msg='I caught an error'
      - command: /bin/false
      - debug: msg='I also never execute :-('
    always:
      - debug: msg="this always executes"
```

第一部分出错后，会被rescue捕捉到，然后做一些补救性的工作

```yml


tasks:
  - block:
    - name: Create {{ maildir_path }}
      copy:
        src: "{{ maildir }}"
        dest: "{{ maildir_path }}"
        mode: 0755
      register: command_output
    rescue:
    - name: Install mail packages
      yum:
        name: "{{ item }}"
        state: latest
      with_items:
        - "{{ mail_package }}"
        - dovecot
    always:
    - name: start the mail service 
      service:
        name: "{{ mail_service }}"
        state: restarted
```