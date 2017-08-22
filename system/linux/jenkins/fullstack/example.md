

* [Jenkins持续集成 - 使用案例 | 会飞的污熊 ](https://www.xncoding.com/2017/03/25/fullstack/jenkins03.html)

Jenkins持续集成 - 使用案例
 发表于 2017-03-25 |  分类于 fullstack |  阅读次数 2507
这一篇我通过两个实际的真实例子来演示Jenkins常见使用案例。 第一个例子演示一个标准的SpringMVC这个Java Web工程怎样自动抓取最新源码、测试、打包和部署， 第二个例子演示目前我做的Winstore这个Python项目怎样实现自定义构建指令、在线升级、自动打包和自动部署。

SpringMVC

关于怎样写SpringMVC项目我这里就不去讲了，这里我构建了一个最简单的Web工程，把它放到开源中国码云上面了，大家可以下载下来测试。 地址：http://git.oschina.net/yidao620/javaweb

环境准备

当然，在跟Jenkins集成的时候我还是使用的内部gitlab源码管理系统， 这个项目的git地址为：git@192.168.217.161:xiongneng/javaweb.git

在Jenkins机器上面安装JDK8，并设置好环境变量JAVA_HOME。

安装sqlite3：

1
yum install -y sqlite sqlite-devel
由于Jenkins要单独占用一个tomcat，所以我将/opt/tomcat复制出来一份/opt/tomcat1用来作为测试这个java web工程的环境， 并修改里面多个端口号，通过8083端口访问。

另外，还有修改catalina.sh，指定3个环境变量，否则会影响到主tomcat：

1
2
3
export CATALINA_BASE=/opt/tomcat1
export CATALINA_HOME=/opt/tomcat1
export CATALINA_PID=/opt/tomcat1/temp/tomcat.pid
安装maven-3.5.0，同时配置好M2_HOME和PATH

配置Jenkins

通过系统设置->Global Tool Configuration配置JDK、Git、Maven，就是设置环境变量， 并且每个配置都会有一个名字，这个名字后面的Pipeline可以用到。



然后新建一个Job，名字叫做javaweb， 类型选择Pipeline，触发器选择GitLab Push。 然后在Pipeline定义中配置Repository URL，同时指定私钥，这些步骤在前面一篇已经讲得很详细了。



GitLab里面设置好Web Hook



定义Pipeline

环境都准备好之后，就可以定义这个Pipeline了，还是通过Jenkinsfile使用代码方式定义， 在项目根目录下面添加这个Jenkinsfile文件

最主要步骤是：拉取最新源码、测试、部署。看看内容其实很简单：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
node("master") {
    checkout scm
    def workspace = pwd()
    def TOMCAT_HOME = "/opt/tomcat1"
    def MVN_HOME = tool 'maven-3.5.0'
    def MVN_BIN = "${MVN_HOME}/bin/mvn"
    stage('InitDB') {
        echo "InitDB start..."
        sh 'sh dbinit.sh'
        return
    }
    stage('Build') {
        echo "InitDB start..."
        return
    }
    stage('Test') {
        echo "Test start..."
        sh """
            ${MVN_BIN} clean && ${MVN_BIN} test
        """
    }
    stage('Deploy') {
        echo "Deploy start..."
        sh """
            ${MVN_BIN} package -Dmaven.test.skip=true
            ${TOMCAT_HOME}/bin/catalina.sh stop || true
            rm -rf ${TOMCAT_HOME}/webapps/ROOT/*
            cp target/javaweb.war ${TOMCAT_HOME}/webapps/ROOT/
            unzip ${TOMCAT_HOME}/webapps/ROOT/javaweb.war -d ${TOMCAT_HOME}/webapps/ROOT >/dev/null
            rm -f ${TOMCAT_HOME}/webapps/ROOT/javaweb.war
            ${TOMCAT_HOME}/bin/catalina.sh start
        """
    }
}
稍微解释一下：InitDB这一构建阶段提前初始化数据库，这里使用的是文件数据库sqlite3。 tool 'maven-3.5.0'这一行就是通过之前配置的maven名称来获得MAVEN_HOME的。

验证

最后首页随便改点东西，push上去后看看效果，大概十几秒就能完成。



成功后打开http://192.168.217.161:8083看首页是否正常显示：



然后，修改首页页面内容，再次提交后push上去，再看看是否更新过来。

另外，如果单元测试不通过，构建就会失败，修改一下单元测试，

1
2
3
4
@Test
public void testIndex() {
    assertEquals("www", "www1");
}
再次push后看看结果：



看看详细日志：



可以非常清楚直观告诉我们哪里出错了。

Winstore

我们组开发的项目名称叫分布式存储winstore，使用的python语言开发。 之前的开发流程为：用最新的安装包在服务器集群上面安装并初始化配置。配置好和服务器源码映射后进行相应开发， 结果没有问题后，提交至版本管理系统，然后去某台机器上面执行winstore_install.sh脚本， 发布最新的安装包至某个samba服务器。最后将这个新包复制到安装服务器上面进行安装。

这时候还要分两种情况，一种是不需要重新安装和配置的在线升级，只需覆盖相应文件重启服务器即可。 另一种是必须重新卸载再安装，要完整的执行整个安装配置流程。

现在想将整个过程通过Jenkins做自动化，并通过提交注释来控制是否在线升级或者重新安装。

这里我先定义一个大致框图，分4个阶段：

Check阶段将源码pull下来后，对最后一次commit的注释进行分析，如果有关键字才会进行后续步骤
Build阶段依据不同的注释执行不通过的操作
Test阶段暂时保留用作测试
Deploy阶段依据不同的情况进行远程文件更新或重新安装，以及后续的处理
前期准备

有几个工作需要预先准备好

jenkins主机上面，编辑visudo，将tomcat用户加入sudo组并且可免密码执行”sudo”。

测试集群：

1
2
3
192.168.217.231
192.168.217.232
192.168.217.233
192.168.217.231为安装机器，保证该主机可ssh无密码登录其他主机。 并将这些IP地址配置写到Jenkinsfile开头的配置中。

保证jenkins主机上面root用户无密码访问集群的所有节点，

1
2
3
4
sudo su root
ssh-copy-id root@192.168.217.231
ssh-copy-id root@192.168.217.232
ssh-copy-id root@192.168.217.233
将winstore项目版本管理由svn迁移至git，我自己构建了一个内部的gitlab服务器。 新建一个名字为winstore-ansible的项目，在项目根目录添加之前的Jenkinsfile， 同时将本地最新项目push上来。

创建job

创建一个Pipeline类型的job，同时设置它的git仓库地址，添加相应的私钥。 然后在gitlab上面配置winstore-ansible项目的webhook即可。

自定义构建指令

这里我通过push的注释部分来自定义构建指令。

在线升级指令： 对每台主机执行替换操作，这里分替换前端web，还是替换后台代码，再或者是两个都修改了替换。 另外还有一个更新shell脚本。

我用四种commit来表示这4种指令：

[update web]
[update back]
[update all]
[update shell]
打包指令： 也就是使用最新的源码构建安装包上传至samba服务器。 对应的commit为[package]和[package all]，后者连mysql包也一起打。

打包并安装指令： 先执行打包任务，然后将samba上面的安装包复制到安装节点执行自动化安装。 对应的commit为：[reinstall]

Pipeline中执行shell

在Pipeline中通过sh执行shell脚本有很多现在，最好不要在里面写复杂逻辑， 可以将复杂逻辑拿出来写到一个单独的脚本文件中，比如我的打包和安装写到单独的sh文件中, 并且将它们纳入版本管理中。

下面是打包脚本：

1
2
3
4
5
6
7
8
9
10
11
#!/bin/bash
# winstore package
param="$1"
cd /root/winstore_git/
if [[ "$param" -eq "winstore" ]]; then
    ./winstore_deploy.sh 4.0 >/dev/null
elif [[ "$param" -eq "all" ]]; then
    ./winstore_deploy.sh 4.0 mysql >/dev/null
fi
exit 0
下面是安装winstore集群脚本：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
#!/bin/bash
# winstore package
install_node="$1"
cluster_nodes_str="$2"
IFS=',' read -r -a cluster_nodes <<< "$cluster_nodes_str"
mount -t cifs -o username="samba",password="samba" //10.10.161.99/public /mnt/ -o rw
cd /mnt/winstore-liuhua/winstore4.0Beta/
ssh root@${install_node} "rm -rf /root/mysql-ansible" >/dev/null || true
ssh root@${install_node} "rm -rf /root/mysql_install*" >/dev/null || true
ssh root@${install_node} "rm -rf /root/winstore4.0_install*" >/dev/null || true
ssh root@${install_node} "rm -rf /root/winstore-ansible" >/dev/null || true
mysql_tar=`ls -l mysql_install* |tail -n1 |awk '{print $NF}'`
winstore_tar=`ls -l winstore4.0* |tail -n1 |awk '{print $NF}'`
echo "mysql_tar=${mysql_tar}, winstore_tar=${winstore_tar}"
scp ${mysql_tar} root@${install_node}:/root/ || true
scp ${winstore_tar} root@${install_node}:/root/ || true
cd /root/
umount /mnt/
ssh root@${install_node} "cd /root; tar zxf ${winstore_tar} &>/dev/null" || true
ssh root@${install_node} "echo '[localhost]' > /root/winstore-ansible/hosts" || true
ssh root@${install_node} "echo 'localhost ansible_connection=local' >> /root/winstore-ansible/hosts" || true
for i in "${cluster_nodes[@]}"; do
    if [[ "$i" != "$install_node" ]]; then
        echo "install node ip = ${i}"
        ssh root@${install_node} "echo \"$i ansible_connection=ssh ansible_user=root\" >> /root/winstore-ansible/hosts" || true
    fi
done
echo "start to install winstore"
ssh root@${install_node} "cd /root/winstore-ansible; ./install_winstore_simple.sh" || true
echo "end to install winstore"
exit 0
最后的Jenkinsfile

最终的Jenkinsfile文件如下，简单起见我只写了2种指令：

1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
node("master") {
    // -------------------------------配置部分start----------------------------------
    // 集群节点列表，安装节点放第一个
    def cluster_nodes_str = "192.168.217.231,192.168.217.232,192.168.217.233"
    //def cluster_nodes_str = "192.168.212.200,192.168.212.201,192.168.212.202,192.168.212.203"
    // -------------------------------配置部分end---------------------------------
    // 集群节点
    def cluster_nodes = cluster_nodes_str.split(",")
    // 安装节点
    def install_node = cluster_nodes[0]
    // 默认忽略所有push请求，除非commit说明包含特定字符串
    def skip = '-1'
    def workspace = pwd()
    stage('Check') {
        checkout scm
        // 一个优雅的退出pipeline的方法，这里可执行任意逻辑
        def resultUpdateshell = sh script: 'git log -1 --pretty=%B | grep "\\[update shell\\]" &>/dev/null', returnStatus: true
        def resultUpdateweb = sh script: 'git log -1 --pretty=%B | grep "\\[update web\\]" &>/dev/null', returnStatus: true
        currentBuild.result = 'SUCCESS'
        if (resultUpdateshell == 0) {
            skip = '0'
            return
        }
        if (resultUpdateweb == 0) {
            skip = '1'
            return
        }
        echo "Skipping ci build..."
        return
    }
    stage('Build') {
        if (skip == '-1') {
            echo "skipping building. lalala,"
            currentBuild.result = 'SUCCESS'
            return
        }
        def node = null
        if (skip == '0') {
            echo "Build Updateshell only... "
            for (int i = 0; i < cluster_nodes.size(); i++) {
                node = cluster_nodes[i]
                echo "Updateshell ${node}"
                sh """
                    cd resource/winstore/tools
                    sudo tar zcf configure.tar.gz configure/
                    sudo ssh root@${node} "rm -rf /opt/winstore/tools/configure/" 2>/dev/null || true
                    sudo scp configure.tar.gz root@"${node}":/opt/winstore/tools/ 2>/dev/null || true
                    sudo ssh root@${node} "cd /opt/winstore/tools/; tar zxf configure.tar.gz; chown -R sdsadmin:sdsadmin *; chmod +x configure/*; rm -f configure.tar.gz" 2>/dev/null || true
                    cd ${workspace}
                    sudo ssh root@${node} "rm -f /opt/winstore/venv/bin/query_wwid_disk.sh" 2>/dev/null || true
                    sudo scp update_resource/winstore/scripts/query_wwid_disk.sh root@"${node}":/opt/winstore/venv/bin/ 2>/dev/null || true
                    sudo ssh root@${node} "chown sdsadmin:sdsadmin /opt/winstore/venv/bin/query_wwid_disk.sh; chmod +x /opt/winstore/venv/bin/query_wwid_disk.sh" 2>/dev/null || true
                """
            }
            currentBuild.result = 'SUCCESS'
            return
        }
    }
    stage('Test') {
        currentBuild.result = 'SUCCESS'
        echo "Test do nothing..."
    }
    stage('Deploy') {
        if (skip == '5') {
            echo "step deploying..."
            sh """
                echo "Deploy reinstall ..........."
                sudo resource/shell/jk_install.sh "${install_node}" "${cluster_nodes_str}" || true
                echo "Deploy reinstall finished..."
            """
            currentBuild.result = 'SUCCESS'
            return
        }
        currentBuild.result = 'SUCCESS'
        echo "Deploy do nothing..."
    }
}
我测试下[update shell]，随便改点什么，在提交时候前面加上[update shell]



点击构建查看详细构建日志：



成功，其他的情况我就一一演示了！

更进一步

这里我以一个python项目为例子来说明自动化的实现，经过对比后工作效率会比之前手动操作高了很多。 利用shell脚本、python脚本、git版本管理，最后在Jenkins这个平台上面就能实现常见的自动化工作。

这里我的任务都比较简单，并且就一个jenkins单节点，而且并没有涉及到繁重的任务，没用到agent节点， 权限和安全控制暂时还没做，以后会逐渐补全这些。

FAQ

构建历史太多了咋办，写个脚本清空下：

1
2
3
4
5
6
7
def jobName = "winstore-pipeline"
def job = Jenkins.instance.getItem(jobName)
job.getBuilds().each { it.delete() }
// uncomment these lines to reset the build number to 1:
job.nextBuildNumber = 1
job.save()
println('clear succesfully...')
在系统管理->脚本命令行里面输入上面的脚本。点击运行即可