

# http://docs.ansible.com/ansible/latest/authorized_key_module.html

```yaml
- name: Set authorized key took from file
  authorized_key:
    user: charlie
    state: present
    key: "{{ lookup('file', '/home/charlie/.ssh/id_rsa.pub') }}"

- name: Set authorized key took from url
  authorized_key:
    user: charlie
    state: present
    key: https://github.com/charlie.keys

- name: Set authorized key in alternate location
  authorized_key:
    user: charlie
    state: present
    key: "{{ lookup('file', '/home/charlie/.ssh/id_rsa.pub') }}"
    path: /etc/ssh/authorized_keys/charlie
    manage_dir: False

- name: Set up multiple authorized keys
  authorized_key:
    user: deploy
    state: present
    key: '{{ item }}'
  with_file:
    - public_keys/doe-jane
    - public_keys/doe-john

- name: Set authorized key defining key options
  authorized_key:
    user: charlie
    state: present
    key: "{{ lookup('file', '/home/charlie/.ssh/id_rsa.pub') }}"
    key_options: 'no-port-forwarding,from="10.0.1.1"'

- name: Set authorized key without validating the TLS/SSL certificates
  authorized_key:
    user: charlie
    state: present
    key: https://github.com/user.keys
    validate_certs: False

- name: Set authorized key, removing all the authorized key already set
  authorized_key:
    user: root
    key: '{{ item }}'
    state: present
    exclusive: True
  with_file:
    - public_keys/doe-jane

- name: Set authorized key for user ubuntu copying it from current user
  authorized_key:
    user: ubuntu
    state: present
    key: "{{ lookup('file', lookup('env','HOME') + '/.ssh/id_rsa.pub') }}"
```