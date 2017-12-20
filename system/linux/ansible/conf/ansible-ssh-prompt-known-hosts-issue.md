

# https://stackoverflow.com/questions/30226113/ansible-ssh-prompt-known-hosts-issue

ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook path/to/the/yml/above/ssh-known_hosts.yml

The ansible docs have a section on this. Quoting:

Ansible 1.2.1 and later have host key checking enabled by default.

If a host is reinstalled and has a different key in ‘known_hosts’, this will result in an error message until corrected. If a host is not initially in ‘known_hosts’ this will result in prompting for confirmation of the key, which results in an interactive experience if using Ansible, from say, cron. You might not want this.

* If you understand the implications and wish to disable this behavior, 
* you can do so by editing `/etc/ansible/ansible.cfg or ~/.ansible.cfg`:
[defaults]
host_key_checking = False
Alternatively this can be set by an environment variable:
$ export ANSIBLE_HOST_KEY_CHECKING=False

Also note that host key checking in paramiko mode is reasonably slow, therefore switching to ‘ssh’ is also recommended when using this feature.