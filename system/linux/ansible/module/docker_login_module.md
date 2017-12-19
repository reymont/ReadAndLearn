
# http://docs.ansible.com/ansible/latest/docker_login_module.html

* Requirements (on host that executes module)
  * python >= 2.6
  * docker-py >= 1.7.0
  * Docker API >= 1.20
  * Only to be able to logout (state=absent): the docker command line utility

```yaml
- name: Log into DockerHub
  docker_login:
    username: docker
    password: rekcod
    email: docker@docker.io

- name: Log into private registry and force re-authorization
  docker_login:
    registry: your.private.registry.io
    username: yourself
    password: secrets3
    reauthorize: yes

- name: Log into DockerHub using a custom config file
  docker_login:
    username: docker
    password: rekcod
    email: docker@docker.io
    config_path: /tmp/.mydockercfg

- name: Log out of DockerHub
  docker_login:
    state: absent
    email: docker@docker.com
```