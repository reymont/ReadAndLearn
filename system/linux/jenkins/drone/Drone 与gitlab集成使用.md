

Drone 与gitlab集成使用 - wenwenxiong的专栏 - CSDN博客 http://blog.csdn.net/wenwenxiong/article/details/78963073

Drone 与gitlab集成使用

参考网址：http://docs.drone.io/installation/ 
http://docs.drone.io/install-for-gitlab/

下载Drone docker镜像

docker pull drone/drone:0.8
docker pull drone/agent:0.8
1
2
Drone与gitlab集成

docker-compose运行Drone

version: '2'

services:
  gitlab:
    image: gitlab/gitlab-ce:latest

    ports:
      - 8929:80
      - 2289:22
    volumes:
      - /media/xww/sda1/myproject/gitlab-ce/gitlab/config:/etc/gitlab
      - /media/xww/sda1/myproject/gitlab-ce/gitlab/logs:/var/log/gitlab
      - /media/xww/sda1/myproject/gitlab-ce/gitlab/data:/var/opt/gitlab
    restart always
  drone-server:
    image: drone/drone:0.8

    ports:
      - 8381:8000
      - 9000
    volumes:
      - /media/xww/sda1/myproject/drone:/var/lib/drone/
    restart: always
    environment:
     - DRONE_OPEN=true
     - DRONE_HOST=http://drone-server:8000
     - DRONE_GITLAB=true
     - DRONE_GITLAB_CLIENT=44aca6668e69a0134a818f0c71f6c5d8ad2a6fc7c108b9edb8029afb71e91ac3
     - DRONE_GITLAB_SECRET=ab055dcb8cb39abca8787f180274e53ed6e4e3319278fd62a35641a8958773c9
     - DRONE_GITLAB_URL=http://gitlab
     - DRONE_GITLAB_SKIP_VERIFY=true
      - DRONE_SECRET=engine123

  drone-agent:
    image: drone/agent:0.8

    restart: always
    depends_on:
      - drone-server
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
    environment:
      - DRONE_SERVER=drone-server:9000
      - DRONE_SECRET=engine123
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
Drone需要与gitlab处于同一个网络，方可通信。docker-compose启动Drone时，会生成一个网络供drone-server和drone-agent使用。也可以单独启动一个gitlab处于该网络。

docker run --detach \
    --hostname gitlab.example.com \
    --publish 8929:80 --publish 2289:22 \
    --name gitlab \
    --restart always \
    --volume /media/xww/sda1/myproject/gitlab-ce/gitlab/config:/etc/gitlab \
    --volume /media/xww/sda1/myproject/gitlab-ce/gitlab/logs:/var/log/gitlab \
    --volume /media/xww/sda1/myproject/gitlab-ce/gitlab/data:/var/opt/gitlab \
    --network dronedocker_default \
    gitlab/gitlab-ce:latest
1
2
3
4
5
6
7
8
9
10
DRONE_GITLAB_CLIENT和DRONE_GITLAB_SECRET的获取如下： 
在gitlab的账户下点击setting 
drone1 
点击左侧的applications，新增一个application 
drone2 
输入name和Callback URL 
drone3 
save后会生成DRONE_GITLAB_CLIENT（Application Id）和DRONE_GITLAB_SECRET（Secret）的id 
drone4