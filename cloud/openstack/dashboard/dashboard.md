
```sh
### 1. 列举出所有openstack服务
systemctl list-units --type=service|grep openstack
### 2. 重启服务
systemctl restart rabbitmq-server
systemctl restart openstack-nova-api openstack-nova-consoleauth openstack-nova-novncproxy
systemctl restart neutron-linuxbridge-agent
systemctl restart neutron-l3-agent.service
systemctl restart neutron-server.service

systemctl restart openstack-nova-api.service   openstack-nova-consoleauth.service openstack-nova-scheduler.service   openstack-nova-conductor.service openstack-nova-novncproxy.service
### 3. 
tail -f /var/log/neutron/server.log
```