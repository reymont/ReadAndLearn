

http://www.cnblogs.com/Ethan2lee/p/7508442.html

# 查看可用镜像
docker-machine ls
# 建立一个节点
docker-machine create --driver virtualbox default
# Run this command to configure your shell:
eval $(docker-machine env)
# 获取节点的ip地址 docker-machine ip default
```powershell
docker run -d -p 8000:80 nginx
curl $(docker-machine ip default):8000