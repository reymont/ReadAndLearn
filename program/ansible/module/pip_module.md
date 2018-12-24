

# http://docs.ansible.com/ansible/latest/pip_module.html

```yaml
 Install (Bottle) python package.
- pip:
    name: bottle

# Install (Bottle) python package on version 0.11.
- pip:
    name: bottle
    version: 0.11

# Install (MyApp) using one of the remote protocols (bzr+,hg+,git+,svn+). You do not have to supply '-e' option in extra_args.
- pip:
    name: svn+http://myrepo/svn/MyApp#egg=MyApp

# Install MyApp using one of the remote protocols (bzr+,hg+,git+).
- pip:
    name: git+http://myrepo/app/MyApp

# Install (MyApp) from local tarball
- pip:
    name: file:///path/to/MyApp.tar.gz

# Install (Bottle) into the specified (virtualenv), inheriting none of the globally installed modules
- pip:
    name: bottle
    virtualenv: /my_app/venv

# Install (Bottle) into the specified (virtualenv), inheriting globally installed modules
- pip:
    name: bottle
    virtualenv: /my_app/venv
    virtualenv_site_packages: yes

# Install (Bottle) into the specified (virtualenv), using Python 2.7
- pip:
    name: bottle
    virtualenv: /my_app/venv
    virtualenv_command: virtualenv-2.7

# Install (Bottle) within a user home directory.
- pip:
    name: bottle
    extra_args: --user

# Install specified python requirements.
- pip:
    requirements: /my_app/requirements.txt

# Install specified python requirements in indicated (virtualenv).
- pip:
    requirements: /my_app/requirements.txt
    virtualenv: /my_app/venv

# Install specified python requirements and custom Index URL.
- pip:
    requirements: /my_app/requirements.txt
    extra_args: -i https://example.com/pypi/simple

# Install (Bottle) for Python 3.3 specifically,using the 'pip-3.3' executable.
- pip:
    name: bottle
    executable: pip-3.3

# Install (Bottle), forcing reinstallation if it's already installed
- pip:
    name: bottle
    state: forcereinstall

# Install (Bottle) while ensuring the umask is 0022 (to ensure other users can use it)
- pip:
    name: bottle
    umask: 0022
  become: True
```