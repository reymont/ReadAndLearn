

ansible-3 主机清单hosts的设置 - BigBao的博客 - 博客园 
http://www.cnblogs.com/smail-bao/p/5569612.html

把一个组作为另一个组的子成员

可以把一个组作为另一个组的子成员,以及分配变量给整个组使用. 这些变量可以给 /usr/bin/ansible-playbook 使用,但不能给 /usr/bin/ansible 使用:

[atlanta]　　主机组一
host1
host2

[raleigh]　　主机组二
host2
host3

[southeast:children]　主机组一、二下的主机都是主机组southeast孩子（子组）
atlanta
raleigh

[southeast:vars]
some_server=foo.southeast.example.com
halon_system_timeout=30
self_destruct_countdown=60
escape_pods=2

[usa:children]
southeast
northeast
southwest
northwest
