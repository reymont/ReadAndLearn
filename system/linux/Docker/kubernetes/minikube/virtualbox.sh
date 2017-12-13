

# https://wiki.centos.org/HowTos/Virtualization/VirtualBox
# http://www.cnblogs.com/waitingforspring/p/4986076.html
cd /etc/yum.repos.d
wget http://download.virtualbox.org/virtualbox/rpm/rhel/virtualbox.repo
# yum --enablerepo=epel install -y dkms
yum groupinstall -y "Development Tools"
yum install -y dkms kernel-devel gcc make
yum install -y kernel-devel-3.10.0-514.16.1.el7.x86_64
yum install -y VirtualBox-5.1
yum remove -y VirtualBox-5.1
yum install -y VirtualBox-5.1
/sbin/vboxconfig


Creating group 'vboxusers'. VM users must be member of that group!

This system is currently not set up to build kernel modules.
Please install the Linux kernel "header" files matching the current kernel
for adding new hardware support to the system.
The distribution packages containing the headers are probably:
    kernel-devel kernel-devel-3.10.0-514.16.1.el7.x86_64
This system is currently not set up to build kernel modules.
Please install the Linux kernel "header" files matching the current kernel
for adding new hardware support to the system.
The distribution packages containing the headers are probably:
    kernel-devel kernel-devel-3.10.0-514.16.1.el7.x86_64

There were problems setting up VirtualBox.  To re-start the set-up process, run
  /sbin/vboxconfig
as root.
  Verifying  : VirtualBox-5.2-5.2.2_119230_el7-1.x86_64                                                                                                                                                      1/1 

Installed:
  VirtualBox-5.2.x86_64 0:5.2.2_119230_el7-1                                                                                                                                                                     

Complete!