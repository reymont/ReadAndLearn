

# http://docs.ansible.com/ansible/latest/patch_module.html

```yml
- name: Apply patch to one file
  patch:
    src: /tmp/index.html.patch
    dest: /var/www/index.html

- name: Apply patch to multiple files under basedir
  patch:
    src: /tmp/customize.patch
    basedir: /var/www
    strip: 1
```