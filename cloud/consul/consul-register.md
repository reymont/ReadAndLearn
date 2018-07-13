

# 手工注册


http://192.168.0.140:8500/v1/agent/services

```sh
./register.sh alertmanager 192.168.0.143 9093
./register.sh dns 192.168.0.140 53
./register.sh elk 192.168.0.143 4310
./register.sh es 192.168.0.143 9200
./register.sh etcd 192.168.0.140 2379
./register.sh image 192.168.0.142 5000
./register.sh k8s 192.168.0.140 6443
./register.sh nfsadmin 192.168.0.142 4210
./register.sh nginx 192.168.0.140 80
./register.sh ntp 192.168.0.140
./register.sh phpmyadmin 192.168.0.142 4220
./register.sh prom 192.168.0.143 9090
./register.sh runtime 192.168.0.143 8000
./register.sh webssh 192.168.0.142 4200
./register.sh db 192.168.0.144 3306
./register.sh jenkins 192.168.0.147 8180
./register.sh gitlab 192.168.0.147 1022
```


ntp服务器是yum安装的
./register.sh ntp 192.168.0.140 123
{ "id": "ntp", "name": "ntp", "address": "192.168.0.140", "port": 123, "tags": [ "static" ], "checks": [ { "tcp": "192.168.0.140:123", "interval": "5s" } ] }

./register.sh nginx 192.168.0.140 80

jvm是addon方式安装内部网络
./register.sh jvmviewer 192.168.0.141

./register.sh image 192.168.0.142 5000
```json
{ "id": "image", "name": "image", "address": "192.168.0.142", "port": 5000, "tags": [ "static" ], "checks": [ { "tcp": "192.168.0.142:5000", "interval": "5s" } ] }
```
./register.sh nfsadmin 192.168.0.142 4210
```json
{ "id": "nfsadmin", "name": "nfsadmin", "address": "192.168.0.142", "port": 4210, "tags": [ "static" ], "checks": [ { "tcp": "192.168.0.142:4210", "interval": "5s" } ] }
```
./register.sh phpmyadmin 192.168.0.142 4220
```json
{ "id": "phpmyadmin", "name": "phpmyadmin", "address": "192.168.0.142", "port": 4220, "tags": [ "static" ], "checks": [ { "tcp": "192.168.0.142:4220", "interval": "5s" } ] }
```
./register.sh webssh 192.168.0.142 4200
```json
{ "id": "webssh", "name": "webssh", "address": "192.168.0.142", "port": 4200, "tags": [ "static" ], "checks": [ { "tcp": "192.168.0.142:4200", "interval": "5s" } ] }
```

script/register.sh
```sh
srv_config=`cat <<EOF
{
    "id": "$name",
    "name": "$name",
    "address": "$srv_ip",
    $str_port
    "tags": [
        "static"
    ],
    "checks": [
      $str_heathz
    ]
}
EOF`

echo $srv_config
curl -s -L http://$consul_addr:8500/v1/agent/service/register -XPUT -d "${srv_config}"
```
