# http://docs.ansible.com/ansible/latest/blockinfile_module.html

```yml
# Before 2.3, option 'dest' or 'name' was used instead of 'path'
- name: insert/update "Match User" configuration block in /etc/ssh/sshd_config
  blockinfile:
    path: /etc/ssh/sshd_config
    block: |
      Match User ansible-agent
      PasswordAuthentication no

- name: insert/update eth0 configuration stanza in /etc/network/interfaces
        (it might be better to copy files into /etc/network/interfaces.d/)
  blockinfile:
    path: /etc/network/interfaces
    block: |
      iface eth0 inet static
          address 192.0.2.23
          netmask 255.255.255.0

- name: insert/update configuration using a local file
  blockinfile:
    block: "{{ lookup('file', './local/ssh_config') }}"
    dest: "/etc/ssh/ssh_config"
    backup: yes

- name: insert/update HTML surrounded by custom markers after <body> line
  blockinfile:
    path: /var/www/html/index.html
    marker: "<!-- {mark} ANSIBLE MANAGED BLOCK -->"
    insertafter: "<body>"
    content: |
      <h1>Welcome to {{ ansible_hostname }}</h1>
      <p>Last updated on {{ ansible_date_time.iso8601 }}</p>

- name: remove HTML as well as surrounding markers
  blockinfile:
    path: /var/www/html/index.html
    marker: "<!-- {mark} ANSIBLE MANAGED BLOCK -->"
    content: ""

- name: Add mappings to /etc/hosts
  blockinfile:
    path: /etc/hosts
    block: |
      {{ item.ip }} {{ item.name }}
    marker: "# {mark} ANSIBLE MANAGED BLOCK {{ item.name }}"
  with_items:
    - { name: host1, ip: 10.10.1.10 }
    - { name: host2, ip: 10.10.1.11 }
    - { name: host3, ip: 10.10.1.12 }
```