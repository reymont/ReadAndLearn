#进程别名
ln -s /rootfs/sbin/ss /sbin/ss


#清理进程
delete from falcon_portal.grp where grp.grp_type=200;
delete from falcon_portal.tpl where tpl.type=200;
delete from falcon_portal.domain_ip;
delete from falcon_portal.team where team.type=200;


#docker本地模式
--net="host"

#安装godep
go get github.com/tools/godep
#加入环境变量
export PATH=$GOPATH/bin:$PATH
#编译
godep go build .

#登陆docker hub
docker login -u admin -p admin@123 -e y docker.dev.yihecloud.com

#Dockerfile
RUN ln -s /rootfs/sbin/ss /sbin/ss
#创建镜像
docker build -t docker.dev.yihecloud.com/openbridge/agent:2.8 .

docker run -d --net=host --restart=always \
  -e HOSTNAME="\"192.168.0.179\"" \
  -e TRANSFER_ADDR="[\"192.168.0.179:8433\",\"192.168.0.179:8433\"]" \
  -e TRANSFER_INTERVAL="60" \
  -e HEARTBEAT_ENABLED="true" \
  -e HEARTBEAT_ADDR="\"192.168.0.179:6030\"" \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:rw \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  --name agent-1 \
  docker.dev.yihecloud.com/openbridge/agent:2.8;docker logs -f agent-1

#测试命令，执行sh start.sh可生成cfg.json
docker run -it --net=host --restart=always \
  -e HOSTNAME="\"192.168.0.179\"" \
  -e TRANSFER_ADDR="[\"192.168.0.179:8433\",\"192.168.0.179:8433\"]" \
  -e TRANSFER_INTERVAL="60" \
  -e HEARTBEAT_ENABLED="true" \
  -e HEARTBEAT_ADDR="\"192.168.0.179:6030\"" \
  -v /:/rootfs:ro \
  -v /var/run:/var/run:rw \
  -v /sys:/sys:ro \
  -v /var/lib/docker/:/var/lib/docker:ro \
  --name agent-1 \
  docker.dev.yihecloud.com/openbridge/agent:2.8 bash

#访问宿主机网络  
apiVersion: v1
kind: Pod
metadata:
  annotations:
    server: '127.0.0.1'
  name: nfsserver
  namespace: nfsserver
spec:
  hostNetwork: true
  volumes:
  - {hostPath: {path: /dev}, name: dev}
  - {hostPath: {path: /run}, name: run}
  containers:
    name: nfsserver
    image: hub.ob.local/paasos/nfsserver:1.0-latest
    # imagePullPolicy: Always
    securityContext: {privileged: true}
    env:
    - {name: VG_NAME, value: nfs}
    - {name: EXPORT_BASE_DIR, value: /share}
    ports:
    - {containerPort: 111, hostPort: 111, protocol: UDP, name: rpc}
    - {containerPort: 2049, hostPort: 2049, protocol: TCP, name: nfs}
    - {containerPort: 892, hostPort: 892, protocol: TCP, name: mount}
    volumeMounts:
    - {mountPath: /dev, name: dev}
    - {mountPath: /run, name: run}
  
  
