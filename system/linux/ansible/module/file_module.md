

http://docs.ansible.com/ansible/latest/file_module.html

```yml
# change file ownership, group and mode. When specifying mode using octal numbers, first digit should always be 0.
- file:
    path: /etc/foo.conf
    owner: foo
    group: foo
    mode: 0644
- file:
    src: /file/to/link/to
    dest: /path/to/symlink
    owner: foo
    group: foo
    state: link
- file:
    src: '/tmp/{{ item.src }}'
    dest: '{{ item.dest }}'
    state: link
  with_items:
    - { src: 'x', dest: 'y' }
    - { src: 'z', dest: 'k' }

# touch a file, using symbolic modes to set the permissions (equivalent to 0644)
- file:
    path: /etc/foo.conf
    state: touch
    mode: "u=rw,g=r,o=r"

# touch the same file, but add/remove some permissions
- file:
    path: /etc/foo.conf
    state: touch
    mode: "u+rw,g-wx,o-rwx"

# create a directory if it doesn't exist
- file:
    path: /etc/some_directory
    state: directory
    mode: 0755
```