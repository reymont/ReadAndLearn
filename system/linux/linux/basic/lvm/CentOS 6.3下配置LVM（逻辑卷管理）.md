

四、安装LVM管理工具

```sh
#4.1 检查系统中是否安装了LVM管理工具
rpm -qa|grep lvm
#4.2 如果未安装，则使用yum 方式安装
yum install lvm*
rpm -qa|grep lvm
```