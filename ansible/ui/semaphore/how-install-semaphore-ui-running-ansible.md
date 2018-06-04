

# http://www.oaktable.net/content/how-install-semaphore-ui-running-ansible

This blogpost is about how to install the semaphore user-interface for running ansible. Ansible is an automation language for automating IT infrastructures. It consists of command-line executables (ansible, ansible-playbook for example) that can run a single task using a module (using the ansible executable), or can run multiple tasks using multiple modules in order to perform more complex setup requirements (using the ansible-playbook executable). The downside of running IT tasks via the command-line is that there is no logging by default, unless someone decides to save the standard out to a file, which, if multiple people start doing that by hand will probably lead to a huge collection of text files which are hard to navigate. Also, when tasks are run via a common place, it’s an all or nothing situation: everybody has access to all the scripts, or to nothing.

This is where semaphore comes in: semaphore is a web-based user interface for running Ansible playbooks, for which you can define users, grant users access to certain templates (groups of playbooks, inventories (=groups of hosts) and ssh keys), which they can run, for which the output is saved in a database.

Semaphore is an alternative to Ansible Tower, which is a non-free product from RedHat. Semaphore is an open source project under active development, and is relatively “young”, which means it can (still) have “sharp edges”. Also Ansible Tower has more functionality.

An other feature from semaphore (and tower for that matter), is that any manipulation done via the web interface can also be done via a REST API. This means that if you use another language or product for the planning and/or deployment of (virtual, cloud, etc) machines which can do REST calls, or if you can craft REST calls with it, you can hand over the management of running Ansible for provisioning to a machine or a group of machines to semaphore, so tracking and logging of running Ansible is taken care of.

However, I did find the documentation of how to install semaphore in a real-life usable way not as verbose as I would like it. For that reason, I decided to write it down in this blogpost. Actually, most of the tasks are done using an Ansible playbook, so the installation is quite simple.

I am using a machine running Centos 7.3, I think this instruction is usable on any version of enterprise linux 7.

1. Install EPEL
EPEL has additional packages to the packages in the distribution repositories.

# rpm -i https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
2. Install Ansible and git

# yum install -y ansible git
Git is necessary for being able to clone from a git repository, and ansible is necessary to run a playbook. The playbook will actually update git to version 2.x because that is stated as a requirement on the semaphore repository.

3. Clone install_semaphore repository

# git clone https://gitlab.com/FritsHoogland/install_semaphore.git 
You might want to change the admin_(username|email|desc|password), which are the credentials for the semaphore superuser in the install_semaphore.yml file. If you like you can change the mysql credentials, however I do think the default settings are okay, because the mysql database will be hidden behind the firewall.

4. Run the semaphore install playbook from the repository

# ansible-playbook install_semaphore/install_semaphore.yml
Please mind this requires root to be allowed to sudo to any user.

Done!

Tagged: ansible, ansible-playbook, firewalld, git, install, nginx, playbook, semaphore, yum  

