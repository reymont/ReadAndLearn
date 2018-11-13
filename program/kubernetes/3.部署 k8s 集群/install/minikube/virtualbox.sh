

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

# http://rpm.pbone.net/index.php3/stat/4/idpl/34702632/dir/scientific_linux_7/com/kernel-devel-3.10.0-514.el7.x86_64.rpm.html
wget ftp://mirror.switch.ch/pool/4/mirror/scientificlinux/7.0/x86_64/updates/security/kernel-devel-3.10.0-514.el7.x86_64.rpm
wget ftp://ftp.icm.edu.pl/vol/rzm6/linux-centos-vault/7.3.1611/updates/x86_64/Packages/kernel-devel-3.10.0-514.16.1.el7.x86_64.rpm
yum localinstall -y kernel-devel-3.10.0-514.16.1.el7.x86_64.rpm