#卸载一个软件时
yum -y remove httpd
#卸载多个相类似的软件时
yum -y remove httpd*
#卸载多个非类似软件时
yum -y remove httpd php php-gd mysql