

http://blog.csdn.net/O_ORick/article/details/73012319

1.格式化:
mkfs -t xfs /dev/sda
2.硬盘挂载:
No.1: mkdir /sda
No.2:mount /dev/sda
No.3:mount /dev/sda /sda
查询是否成功: df -T