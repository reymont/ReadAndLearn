

# http://docs.ansible.com/ansible/latest/easy_install_module.html

```yaml
# Examples from Ansible Playbooks
- easy_install:
    name: pip
    state: latest

# Install Bottle into the specified virtualenv.
- easy_install:
    name: bottle
    virtualenv: /webapps/myapp/venv
```