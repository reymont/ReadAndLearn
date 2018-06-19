

最近再看Openstack相关知识，一直想试试安装一下，可是参考了很多资料，并不如人意。由于一直用的Linux版本为CentOS，大部分Openstack安装都要求在Ubuntu上进行。我也不知到什么原因，并不喜欢Ubuntu，可能是觉得太花哨了，而且总提示更新什么的，好了，废话不多说。
       找到一个网站，国外的，  http://openstack.redhat.com/Main_Page，进入到quickstart页面中，简单翻译如下：
       用到的工具是一个被成为RDO的东东， 能够在基于RHEL内核的linux系统，如RedHat，CentOS，Scientific Linux下，快速实现三步安装。
      一：安装RDO软件
    
sudo yum install -y http://rdo.fedorapeople.org/rdo-release.rpm
      
      二：安装一个叫packstack的部署包
 
sudo yum install -y openstack-packstack

     三：一键自动安装

packstack --allinone
       执行后需要输入密码，一键安装截图如下：

            安装完毕，可以通过OpenStack的网络管理接口Horizon进行访问，地址如：http://$YOURIP/dashboard  ，用户名为admin，密码可以在
/root/ 下的keystonerc_admin文件中找到到。
         
            后续工作，可以添加实例，自行进行测试。参考网站：http://openstack.redhat.com/Running_an_instance
           当一切就绪，还可以添加节点，但需要进行配置，具体参考： http://openstack.redhat.com/Adding_a_compute_node
          网络管理配置，具体参考：http://openstack.redhat.com/Floating_IP_range
        
           正在学习openstack中，欢迎留言交流。