# https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-compose-on-centos-7
# http://blog.csdn.net/kinginblue/article/details/73527832
# https://docs.docker.com/compose/install/

# Step 2 — Installing Docker Compose
# Now that you have Docker installed, let's go ahead and install Docker Compose. First, install python-pip as prerequisite:
yum install epel-release
yum install -y python-pip
pip install docker-compose
# 卸载
pip uninstall docker-compose
# https://github.com/docker/compose/releases?after=1.10.1
# Compose 1.10.0-rc2 requires Docker Engine 1.10.0 or later for version 2 of the Compose File format
## 降级 docker-compose，先卸载：
pip uninstall docker-compose
## 再安装指定版本：
pip install docker-compose==1.10.0
# You will also need to upgrade your Python packages on CentOS 7 to get docker-compose to run successfully:
yum upgrade python* -y

# ImportError: cannot import name IPAMConfig
## https://github.com/docker/compose/issues/4401
pip uninstall docker -y
pip uninstall docker-py -y
pip uninstall docker-compose -y
pip install docker-compose==1.9.0

cd /opt/rap/RAP/lab/docker-rap
docker-compose up -d
docker-compose ps

# To stop all running Docker containers for an application group,
docker-compose stop
# Note: docker-compose kill is also available if you need to shut things down more forcefully.
docker-compose kill
# In some cases, Docker containers will store their old information in an internal volume. 
# If you want to start from scratch you can use the rm command to fully delete all the containers 
# that make up your container group:
docker-compose rm 