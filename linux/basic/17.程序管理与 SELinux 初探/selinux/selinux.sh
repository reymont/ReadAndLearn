

http://roclinux.cn/?p=2264

# 如果SELinux status参数为enabled即为开启状态
/usr/sbin/sestatus -v      

# 永久方法 – 需要重启服务器
# 修改/etc/selinux/config文件中设置SELINUX=disabled ，然后重启服务器。

# 临时方法 – 设置系统参数
# 使用命令setenforce 0
## 设置SELinux 成为enforcing模式
setenforce 1 
## 设置SELinux 成为permissive模式
setenforce 0