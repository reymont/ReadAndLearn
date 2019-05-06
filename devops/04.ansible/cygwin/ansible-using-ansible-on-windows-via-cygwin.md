
Ansible - Using Ansible on Windows via Cygwin - EverythingShouldBeVirtual 
https://everythingshouldbevirtual.com/automation/ansible-using-ansible-on-windows-via-cygwin/

As I continue down the Ansible journey to automate all things it is apparent that Windows is a second class citizen in some regards. I had a need to run Ansible from my Windows desktop and figured I would give this a shot. After some searching I found bits and pieces around the google results and pieced this all together and it works. And hopefully someone else will benefit from this.

First we need to install Cygwin from the following x64 (64-Bit) or x86 (32-Bit).

# Install the following Cygwin components.

```sh
binutils
curl
gmp
libgmp-devel
make
python (2.7.x)
python2-devel
python-crypto
python-openssl
python-setuptools
git (2.5.x)
nano
openssh
openssl
openssl-devel
gcc
```
Once the Cygwin installer completes open the Cygwin desktop shortcut to open up the Cygwin BASH prompt.

There are two ways we can install the following.

# The first way (more involved).
NOTE: See further down for the easy method.

```sh
# Download the following packages to install.
curl -O https://pypi.python.org/packages/source/P/PyYAML/PyYAML-3.10.tar.gz
curl -O https://pypi.python.org/packages/source/J/Jinja2/Jinja2-2.8.tar.gz
# Now extract the packages downloaded above.
tar -zxvf Jinja2-2.8.tar.gz
tar -zxvf PyYAML-3.10.tar.gz
# Now install the packages downloaded above.
cd Jinja2-2.8
python setup.py install
cd ..
cd PyYAML-3.10
python setup.py install
```

# The second way (easy)

```sh
easy_install-2.7 pip
CFLAGS="-g -O2 -D_BSD_SOURCE" pip install -U pycrypto
pip install ansible
```

# Now let’s pull down the Ansible code from GitHub.

```sh
git clone <https://github.com/ansible/ansible> /opt/ansible
# Change to the latest stable branch of Ansible.
cd /opt/ansible
git checkout stable-1.9
# Now we need to update some of the Ansible modules
cd /opt/ansible
git submodule update --init lib/ansible/modules/core
git submodule update --init lib/ansible/modules/extras
# We now need to update our BASH profile to include the path to our Ansible folder.
cd ~
nano .bashrc
# Paste the following at the bottom of the file and save.

# Ansible settings
ANSIBLE=/opt/ansible
export PATH=$PATH:$ANSIBLE/bin
export PYTHONPATH=$ANSIBLE/lib
export ANSIBLE_LIBRARY=$ANSIBLE/library
```
Now exit Cygwin

exit
And launch our Cygwin desktop shortcut once again to open up our Cygwin BASH prompt. You should be able to launch ansible at this point to validate that our profile is correct in seeing the path to Ansible.


# ansible
....
Usage: ansible  [options]

Options:
  -a MODULE_ARGS, --args=MODULE_ARGS
                        module arguments
  --ask-become-pass     ask for privilege escalation password
  -k, --ask-pass        ask for SSH password
  --ask-su-pass         ask for su password (deprecated, use become)
  -K, --ask-sudo-pass   ask for sudo password (deprecated, use become)
  --ask-vault-pass      ask for vault password
  -B SECONDS, --background=SECONDS
                        run asynchronously, failing after X seconds
                        (default=N/A)
  -b, --become          run operations with become (nopasswd implied)
  --become-method=BECOME_METHOD
                        privilege escalation method to use (default=sudo),
                        valid choices: [ sudo | su | pbrun | pfexec | runas ]
  --become-user=BECOME_USER
                        run operations as this user (default=None)
  -C, --check           don't make any changes; instead, try to predict some
                        of the changes that may occur
  -c CONNECTION, --connection=CONNECTION
                        connection type to use (default=smart)
  -e EXTRA_VARS, --extra-vars=EXTRA_VARS
                        set additional variables as key=value or YAML/JSON
  -f FORKS, --forks=FORKS
                        specify number of parallel processes to use
                        (default=5)
  -h, --help            show this help message and exit
  -i INVENTORY, --inventory-file=INVENTORY
                        specify inventory host file
                        (default=/etc/ansible/hosts)
  -l SUBSET, --limit=SUBSET
                        further limit selected hosts to an additional pattern
  --list-hosts          outputs a list of matching hosts; does not execute
                        anything else
  -m MODULE_NAME, --module-name=MODULE_NAME
                        module name to execute (default=command)
  -M MODULE_PATH, --module-path=MODULE_PATH
                        specify path(s) to module library
                        (default=/opt/ansible/library)
  -o, --one-line        condense output
  -P POLL_INTERVAL, --poll=POLL_INTERVAL
                        set the poll interval if using -B (default=15)
  --private-key=PRIVATE_KEY_FILE
                        use this file to authenticate the connection
  -S, --su              run operations with su (deprecated, use become)
  -R SU_USER, --su-user=SU_USER
                        run operations with su as this user (default=root)
                        (deprecated, use become)
  -s, --sudo            run operations with sudo (nopasswd) (deprecated, use
                        become)
  -U SUDO_USER, --sudo-user=SUDO_USER
                        desired sudo user (default=root) (deprecated, use
                        become)
  -T TIMEOUT, --timeout=TIMEOUT
                        override the SSH timeout in seconds (default=10)
  -t TREE, --tree=TREE  log output to this directory
  -u REMOTE_USER, --user=REMOTE_USER
                        connect as this user (default=larry.smith)
  --vault-password-file=VAULT_PASSWORD_FILE
                        vault password file
  -v, --verbose         verbose mode (-vvv for more, -vvvv to enable
                        connection debugging)
  --version             show program's version number and exit
BOOM!

Installing Ansible (Easy way)

easy_install-2.7 pip
pip install ansible
Now let’s do a test download of some Ansible Galaxy roles.

ansible-galaxy install mrlesmithjr.base
ansible-galaxy install mrlesmithjr.bootstrap
Now generate your SSH keys in order to execute ssh-passwordless logins.

# ssh-keygen
One more thing that I ran into was when running an ansible-playbook was the following error.

ansible-playbook -i hosts gather_interfaces.yml
....
PLAY [all] ********************************************************************

GATHERING FACTS ***************************************************************
fatal: [elk-pre-processor-1] => SSH Error: mux_client_request_session: send fds failed
    while connecting to 10.0.101.91:22
It is sometimes useful to re-run the command using -vvvv, which prints SSH debug output to help diagnose the issue.

TASK: [grabbing interfaces] ***************************************************
FATAL: no hosts matched or all hosts have already failed -- aborting


PLAY RECAP ********************************************************************
           to retry, use: --limit @/home/larry.smith/gather_interfaces.retry

elk-pre-processor-1    : ok=0    changed=0    unreachable=1    failed=0
This error above is from using Cygwin and can easily be solved by creating an ansible.cfg file in your playbook folder with the following.

nano ansible.cfg
....
[ssh_connection]
ssh_args = -o ControlMaster=no
Now when running the playbook again success.

    PLAY [all] ********************************************************************

    GATHERING FACTS ***************************************************************
    ok: [elk-pre-processor-1]

    TASK: [grabbing interfaces] ***************************************************
    changed: [elk-pre-processor-1]

    TASK: [ensuring host_vars exists] *********************************************
    ok: [elk-pre-processor-1 -> localhost]

    TASK: [configuring host_vars] *************************************************
    changed: [elk-pre-processor-1 -> localhost]

    PLAY RECAP ********************************************************************
    elk-pre-processor-1    : ok=4    changed=2    unreachable=0    failed=0
So there you have it! Now happy Ansibling! :) And report back on any of your findings.

Enjoy!