

Ansible change default value according to a condition - Server Fault 
https://serverfault.com/questions/715769/ansible-change-default-value-according-to-a-condition



I suggest this solution:

---
 - set_fact:
     composer_opts: ""
   when: "{{env}}" == 'dev'
It will set composer_opts variable to string "" when variable env is equal to 'dev'.

Here is example of playbook based on updated question:

$ cat test.yml

---
- hosts: 127.0.0.1
  connection: local
  tasks:
  - set_fact:
      composer_opts: "{% if env == 'prod' %} '--no-dev --optimize-autoloader --no-interaction' {% else %} '' {% endif %}"

  - debug: var=composer_opts