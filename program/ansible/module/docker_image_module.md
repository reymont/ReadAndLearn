

# http://docs.ansible.com/ansible/latest/docker_image_module.html


```yaml
- name: pull an image
  docker_image:
    name: pacur/centos-7

- name: Tag and push to docker hub
  docker_image:
    name: pacur/centos-7
    repository: dcoppenhagan/myimage
    tag: 7.0
    push: yes

- name: Tag and push to local registry
  docker_image:
     name: centos
     repository: localhost:5000/centos
     tag: 7
     push: yes

- name: Remove image
  docker_image:
    state: absent
    name: registry.ansible.com/chouseknecht/sinatra
    tag: v1

- name: Build an image and push it to a private repo
  docker_image:
    path: ./sinatra
    name: registry.ansible.com/chouseknecht/sinatra
    tag: v1
    push: yes

- name: Archive image
  docker_image:
    name: registry.ansible.com/chouseknecht/sinatra
    tag: v1
    archive_path: my_sinatra.tar

- name: Load image from archive and push to a private registry
  docker_image:
    name: localhost:5000/myimages/sinatra
    tag: v1
    push: yes
    load_path: my_sinatra.tar

- name: Build image and with buildargs
  docker_image:
     path: /path/to/build/dir
     name: myimage
     buildargs:
       log_volume: /var/log/myapp
       listen_port: 8080
```