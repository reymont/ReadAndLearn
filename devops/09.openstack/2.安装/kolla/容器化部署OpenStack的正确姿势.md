

容器化部署OpenStack的正确姿势_搜狐科技_搜狐网 http://www.sohu.com/a/154655271_198222

当前，以OpenStack为代表的IaaS开源技术和以Docker为代表的PaaS/CaaS容器技术日益成熟，二者如何强强联合，一直是业界颇为关心的焦点领域。本次分享主要是和大家交流基于Docker容器运行和部署OpenStack。那么，安装OpenStack都有哪些方法呢？对于很多刚接触OpenStack的新人而言，安装无疑是一大挑战，同时也直接提高了学习OpenStack云计算的技术门槛。
一．安装OpenStack有哪些方式
1．DevStack
在相当长一段时间内，DevStack仍将是众多开发者的首选安装工具。该方式主要是通过配置一个安装脚本，执行Shell命令来安装OpenStack的开发环境，支持CentOS、Debian等系列系统。
2．RDO
RDO是由Red Hat红帽开源的一个自动化部署OpenStack的工具，支持单节点（all-in-one）和多节点（multi-node）部署。但RDO只支持CentOS系列操作系统。需要注意的是，该项目并不属于OpenStack官方社区项目。
3．手动部署
按照社区官方提供的文档，可以使用手动方式部署单节点、多节点、HA节点环境。
4．Puppet
Puppet由Ruby语言编写。Puppet是进入OpenStack自动化部署中早期的一个项目。目前，它的活跃开发群体是Red Hat、Mirantis、UnitedStack等。Mirantis出品的Fuel部署工具，其大量的模块代码使用的便是Puppet。
5．Ansible
Ansible是一个自动化部署配置管理工具，已被Red Hat收购。它基于Python开发，集合了众多运维工具（Puppet、Chef、SaltStack等）的优点，实现了批量系统配置、批量程序部署、批量运行命令等功能。Ansible一方面总结了Puppet设计上的得失，另一方面也改进了很多设计。比如基于SSH方式工作，故而不需要在被控端安装客户端。
6．SaltStack
SaltStack也是一个开源的自动化部署工具，基于Python开发，实现了批量系统配置、批量程序部署、批量运行命令等功能，和Ansible很相似。不同之处是，由于SaltStack的Master和Minion认证机制及工作方式，因此需要在被控端安装Minion客户端。
7．TripleO
TripleO项目最早由HP于2013年4月在Launchpad上注册BP，用于完成OpenStack的安装与部署。TripleO全称为“OpenStack On OpenStack”，意思为“云上云”，可以简单理解为利用OpenStack来部署OpenStack，即首先基于V2P（和P2V相反，指把虚拟机的镜像迁移到物理机上）的理念事先准备好一些OpenStack节点（计算、存储、控制节点）的镜像，然后利用已有OpenStack环境的Ironic裸机服务和软件安装部分的diskimage-builder部署裸机，最后通过Heat项目和镜像内的自动化部署工具（Puppet或Chef）在裸机上配置运行OpenStack。和其他部署工具不同的是，TripleO是利用OpenStack已有的基础设施来部署OpenStack的。
8．Fuel
Fuel是针对OpenStack的一个可以通过“界面部署”的工具，它大量采用了Python、Ruby和Java等语言。其功能涵盖了通过自动化PXE方式安装操作系统、DHCP服务、Orchestration编排服务和Puppet安装相关服务等，此外还有OpenStack关键业务健康检查和log实时查看等非常好用的功能。
9．Kolla
上面说了这么多，现在终于轮到主角上场了——kolla。Kolla是具有广阔应用前景和市场的一个自动化部署工具。相比于其他部署工具，Kolla完全革新地使用了Docker容器技术，将每一个OpenStack服务运行在不同的Docker容器中。
小结
如上所述，OpenStack的安装部署方式多种多样，新手应该如何选择呢，这里，我推荐使用Rdo或手动部署方式（过程是艰难的，但能很好的加深对OpenStack的理解）；对于老手而言，可以尝试使用Kolla方式，体验Docker和OpenStack融合的新方式。
当前，OpenStack除了与Docker融合相关的Kolla项目之外，社区还有诸如Magnum、Murano、Solum等非常优秀的项目。
二．Docker容器化部署OpenStack
什么是Kolla
以前，我们要想在OpenStack版本发布后或者在版本开发过程中，立即安装体验等只能使用DevStack源码方式安装。但现在更多了一种新的选择，——即使用Kolla。
该项目由思科于2014年9月提出，是OpenStack社区“Big Tent”开发模式下的项目。Kolla的优势和使用场景体现在如下几个方面：
原子性升级或者回退OpenStack部署。
基于组件升级OpenStack。
基于组件回退OpenStack。
具体而言，Kolla的最终目标是为OpenStack的每一个服务都创建一个对应的Docker镜像，通过Docker镜像将升级的粒度减小到服务级别，从而在升级时对OpenStack的影响降到最小，并且一旦升级失败，也很容易回滚。升级只需要三步：拉取新版本的容器镜像，停止老版本的容器服务，启动新版本的容器。回滚也不需要重新安装包，直接启动老版本的容器服务就行，非常方便。
Kolla可以使用Ansible、Kubernetes或者Mesos来部署OpenStack环境，Kolla负责容器化OpenStack各个服务；后者则负责部署这些容器，搭建出一个可用的OpenStack环境。来实现基于Docker容器的OpenStack服务全生命周期管理，如安装、升级、回滚、迁移等。在部署Docker容器时，默认的网络配置都是Host模式。因为Kolla的Docker镜像粒度很小，它针对每个OpenStack服务都有特定的镜像，所以我们也可以通过Docker命令来操作某个具体的OpenStack服务。
Kolla项目，及其相关的其他项目，如下：
Kolla项目：负责docker build OpenStack每个服务，如nova-compute容器等；
Kolla-Ansible项目：使用Ansible部署这些容器，搭建OpenStack环境；
Kolla-Kubernetes项目：使用Kubernetes部署这些容器，搭建OpenStack环境；
Kolla-Mesos项目：使用Mesos部署这些容器，搭建OpenStack环境。
简言而之，Kolla就是OpenStack社区的一个用于docker build容器化OpenStack服务的项目，最后，使用其他的社区项目，即kolla-ansible或者kolla-kubernetes执行部署任务。
Kolla为OpenStack的部署提供了有效、快捷、方便、易于维护、方便版本更新与回退的方案。基于Docker容器部署和运维的OpenStack架构，如下图所示：

Kolla所涉及到的技术点，有：
Docker
Ansible
Python
docker-py
Jinja2
Kolla支持部署HA高可用性的OpenStack环境，如下图所示，大家应该一看就明白吧。是的，正如其他OpenStack HA部署方案一样，如MySQL采用的是Galera等。
目前，Kolla提供的镜像支持部署如下OpenStack项目，包括但不限于：
Aodh
Ceilometer
Cinder
Designate
Glance
Gnocchi
Heat
Horizon
Ironic
Keystone
Magnum
Mistral
Murano
Nova
Neutron
Swift
Tempest
Zaqar
以及这些基础设施组件：
Ceph分布式存储
Openvswitch和Linuxbridge
MongoDB数据库
RabbitMQ消息队列服务
HAProxy和Keepalived 服务高可用组件
MariaDB数据库等
Kolla的Docker镜像制作，支持红帽的RPM包，Ubuntu和Debian的Deb包，还能支持源码的方式。理论上源码制作的镜像，可以运行在所有的支持容器的操作系统上。
我们可以选择Ansible来做容器的管理，也可以选择Kubernetes或Mesos来管理。目前Ansible已经比较完善，Kubernetes和Mesos还在积极开发中。但我个人感觉，Kubernetes会是未来一段时间的新宠儿，但是它对使用/管理人员的要求会比较高。
Kolla解决的问题
过去，无论是个人还是公司尝试使用OpenStack，在安装和部署，都花费和消耗大量的精力。这其实也是影响OpenStack推广的一个重要障碍。如何让大家从部署的枷锁中解放出来，用好OpenStack，才能真正体现出OpenStack的价值。
一般安装好操作系统后，采用Kolla部署OpenStack环境，大概只需要30分钟的时间，就可以搭建完成OpenStack。社区的各种最佳实践，高可用等都集成在上面。Kolla让OpenStack的部署、升级变得更加的优雅。
所谓软件的升级就是把以前老的删掉，再装新的版本。如果你是采用包的安装，例如Rdo，那就非常的痛苦了。如果没有其他定制化开发的需求，使用社区提供的已构建好的OpenStack镜像即可（http://tarballs.openstack.org/kolla/images/）。
OK，下面进入正题吧，咱们用Kolla部署一个Ocata版本的OpenStack（all-in-one环境）。
准备操作系统
这里，我使用一个CentOS 7.2系统（6GB内存、4个CPU、50GB磁盘），配置IP地址（172.16.X.225），并关闭Firewalld和Selinux。
安装依赖
加入Docker的repo源
# tee /etc/yum.repos.d/docker.repo << 'EOF'[dockerrepo]name=Docker Repositorybaseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/enabled=1gpgcheck=1gpgkey=https://yum.dockerproject.org/gpgEOF
安装EPEL源
yum install -y epel-release
安装和配置Docker服务
1）安装基础包
yum install python-devel libffi-devel gcc openssl-devel git python-pip ansible -y
2）安装Docker 1.12.5
yum install docker-engine-1.12.5 docker-engine-selinux-1.12.5 -y
3）设置Docker
mkdir /etc/systemd/system/docker.service.dtee /etc/systemd/system/docker.service.d/kolla.conf << 'EOF'[Service]MountFlags=sharedEOF
4）重启相关服务
systemctl daemon-reloadsystemctl enable dockersystemctl restart docker
5）编辑
/usr/lib/systemd/system/docker.service文件
E=/usr/bin/dockerdExecStart=/usr/bin/dockerd --insecure-registry 172.16.70.225:4000
6）重启Docker服务
systemctl daemon-reloadsystemctl restart docker
7）这里，可以配置阿里云的Docker加速器（可选），加快pull registry镜像。
mkdir -p /etc/dockertee /etc/docker/daemon.json <<-'EOF'{"registry-mirrors": ["https://a5aghnme.mirror.aliyuncs.com"]}EOF
再重启下Docker服务
systemctl daemon-reload && systemctl restart docker
8）默认Docker的Registry是使用5000端口，对于OpenStack来说，有端口冲突，所以需要改成4000。Pull并启动registry镜像。
docker run -d -v /opt/registry:/var/lib/registry -p 4000:5000 --restart=always --name registry registry:2
安装Kolla
1）这里，下载使用Kolla社区的Ocata版本镜像（免去在本地环境docker build的过程，大大加快安装时间）。
wget http://tarballs.openstack.org/kolla/images/centos- binary-registry-ocata.tar.gztar zxvf centos-binary-registry-ocata.tar.gz -C /opt/registry/
2）下载kolla-ansible的代码
cd /homegit clone http://git.trystack.cn/openstack/kolla-ansible
3）安装kolla-ansible
cd kolla-ansible && pip install .
4）复制相关文件
cp -r etc/kolla /etc/kolla/cp ansible/inventory/* /home/
说明：如果是在虚拟机里安装Kolla，希望可以在OpenStack平台上创建虚拟机，那么你需要把virt_type=qemu，默认是KVM。
mkdir –p /etc/kolla/config/novacat << EOF > /etc/kolla/config/nova/nova-compute.conf[libvirt]virt_type=qemuEOF
5）生成密码文件
kolla-genpwd
6）编辑 /etc/kolla/passwords.yml文件，配置keystone管理员用户的密码。
keystone_admin_password: admin
同时，也是登录Dashboard，admin使用的密码，你可以根据自己需要进行修改。
7）编辑 /etc/kolla/globals.yml 配置文件
kolla_internal_vip_address: " 172.16.X.225" //访问Dashboard的地址docker_registry: " 172.16.X.225:4000"docker_namespace: "lokolla"network_interface: "eth0" //IP地址为172.16.X.225neutron_external_interface: "eth1" //该网卡不配置IP地址
如果部署的是单节点，需要编辑/usr/share/kolla-ansible/ansible/group_vars/all.yml文件，设置enable_haproxy为no。
enable_haproxy: "no"
说明：建议，在执行安装命令前，先使用kolla-ansible –help命令，了解下kolla-ansible支持的具体命令或参数。
执行安装OpenStack的命令
kolla-ansible deploy -i /home/all-in-one -vvvv
如果顺利，这个过程大约需要30分钟时间，这时候，不妨泡杯茶，慢慢品饮。
安装结束后，创建环境变量文件
kolla-ansible post-deploy
这样就创建 了/etc/kolla/admin-openrc.sh 环境变量文件。
安装OpenStack client端
pip install python-openstackclient
部署技巧：
1）如果，在部署过程中失败了，亦或是变更了配置信息，需要重新部署，则先执行如下命令，清除掉已部署的Docker容器，即OpenStack服务。
kolla-ansible destroy -i /home/all-in-one --yes-i-really-really-mean-it
2）除此外，还有一些小工具，在自己需要时，可以使用。
kolla-ansible prechecks：在执行部署命令之前，先检查环境是否正确；
tools/cleanup-containers：可用于从系统中移除部署的容器；
tools/cleanup-host：可用于移除由于网络变化引发的Docker启动的neutron-agents主机；
tools/cleanup-images：可用于从本地缓存中移除所有的docker image。
最后，可以使用docker ps –a命令查看到OpenStack 所有服务的容器。
验证部署
登录Dashboard
URL：http://172.16.X.225
用户名：admin
密码：admin

接着，我们创建一个镜像试试。
编辑 /usr/share/kolla-ansible/init-runonce文件，改成国内的trystack镜像源下载，速度快（感谢国内TryStack社区做出的贡献，服务大家）。
运行命令
source /etc/kolla/admin-openrc.shcd /usr/share/kolla-ansible./init-runonce
这将自动创建一个镜像、租户网络等。如下，可以查看到自动创建的cirros测试镜像。
小结
至此，我们便通过Kolla和Ansible，部署成功了一个基于Docker容器运行的OpenStack环境。对于Ceph分布式存储、Haproxy高可用性、OpenDaylight SDN软件定义网络等这些功能，Kolla和Ansible都是支持的。
Troubleshoot
通过Kolla和Ansible部署或运行OpenStack环境时，如果出现问题，通常可以使用如下一些方法来排查/解决。
1）查看指定容器（即指定的服务）的输出日志信息。
docker logs container_name
2）进入到fluentd日志收集容器里，查看指定服务的日志。
docker exec -it fluentd bash
接着，cd到/var/log/kolla/SERVICE_NAME目录下。
3）还可以，直接CD到主机的/var/lib/docker/volumes/kolla_logs/_data/目录下，查看指定服务的日志信息。
4）如果在部署时失败，通过日志无法查找到原因，可以使用Ansible的debug模块进行部署代码调试。
Q&A
Q：容器虚拟CPU支持虚拟化吗？
A：容器只是一个进程服务，依赖于CPU虚拟化。
Q：Kolla-Ansible部署的OpenStack是否满足生产环境？
A：完全满足，已有客户上生产环境跑重要业务。
Q：OpenStack服务的可靠性，主被仲裁，配置变更等，可以怎么管理呢？
A：OpenStack服务的可靠性，主被仲裁，Kolla和Ansible均支持包括HAproxy等在内的OpenStack服务和Mariadb数据库的高可用性，社区推荐DB使用主主方式；至于管理，使用Ansible。
Q： OpenStack容器化部署后数据持久化的问题如何解决？
A：默认情况下，配置文件数据存放在主机的/etc/kolla目录下，数据库数据则在容器中，对于持久化等，可以考虑docker volume等相关方案，多种多样。
Q：通过Kolla-Ansible部署之后的OpenStack对网络是否有要求，或者需要单独配置网络这块？
A：使用Kolla-Ansible部署的OpenStack环境，和使用其他方式部署的网络环境一样，管理网、业务网和外网等。
Q：可否对Kolla-Ansible项目做Socker化，目的是通过这个镜像去部署OpenStack，减少重复配置Kolla-Ansible的运行环境？
A：Kolla-Ansible只是一个部署工具，做配置管理。可以把Kolla、Ansible和Docker镜像都放在一个部署模板上，通过这个部署模板去任意 部署OpenStack环境，这类似于Fuel ISO。
3 天烧脑式容器存储网络训练营
本次培训以容器存储和网络为主题，包括：Docker Plugin、Docker storage driver、Docker Volume Pulgin、Kubernetes Storage机制、容器网络实现原理和模型、Docker网络实现、网络插件、Calico、Contiv Netplugin、开源企业级镜像仓库Harbor原理及实现等。点击识别下方二维码加微信好友了解