

# https://gagor.pl/2013/12/ansible-dynamicaly-update-etc-hosts-files-on-target-servers/

Ansible – Dynamicaly update /etc/hosts files on target servers

I was configuring GlusterFS on few servers using Ansible and have a need to update /etc/hosts with hostnames for easier configuration. I found this one working:

- name: Update /etc/hosts
  lineinfile: dest=/etc/hosts regexp='.*{{item}}$' line='{{hostvars.{{item}}.ansible_default_ipv4.address}} {{item}}' state=present
  with_items: '{{groups.somegroup}}'
Update – that doesn’t work in Ansible version 2.x, you have to use this:

- name: Update /etc/hosts from inventory
  lineinfile: dest=/etc/hosts regexp='.*{{item}}$' line='{{hostvars[item].ansible_default_ipv4.address}} {{item}}' state=present
  with_items: '{{groups.all}}'
  tags:
    - hosts
Source:
http://xmeblog.blogspot.com/2013/06/ansible-dynamicaly-update-etchosts.html