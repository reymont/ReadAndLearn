

# http://docs.ansible.com/ansible/latest/unarchive_module.html

```yml
- name: Extract foo.tgz into /var/lib/foo
  unarchive:
    src: foo.tgz
    dest: /var/lib/foo

- name: Unarchive a file that is already on the remote machine
  unarchive:
    src: /tmp/foo.zip
    dest: /usr/local/bin
    remote_src: yes

- name: Unarchive a file that needs to be downloaded (added in 2.0)
  unarchive:
    src: https://example.com/example.zip
    dest: /usr/local/bin
    remote_src: yes
```