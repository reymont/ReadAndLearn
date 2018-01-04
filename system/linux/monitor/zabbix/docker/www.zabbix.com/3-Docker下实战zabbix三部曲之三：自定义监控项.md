

Docker下实战zabbix三部曲之三：自定义监控项 - boling_cavalry的博客 - CSDN博客 http://blog.csdn.net/boling_cavalry/article/details/77410178

通过上一章《Docker下实战zabbix三部曲之二：监控其他机器》的实战，我们了解了对机器的监控是通过在机器上安装zabbix agent来完成的，zabbix agent连接上zabbix server之后，将自己所在机器的信息定时给到zabbix server，这样就实现了机器的监控； 
但是我们能监控到的只有cpu，磁盘这些基础信息，对于一些业务信息例如访问量，某个逻辑的执行成功失败次数等信息，我们也想进行监控，这就需要我们去制作自定义监控项了，本章我们就一起来实战自定义监控项吧。

机器部署情况一览

总的来说，有四台机器，各自的功能如下： 
a. 假设有一个机器在运行web应用，容器是tomcat，这个应用有个接口http://localhost:8080/zabbixcustomitemdemo/count，可以返回最近一分钟的某个业务量(例如网站访问次数)；

b. 有一台机器安装了zabbix agent，作为自定义监控项的载体； 
c. 有一台机器安装了zabbix server； 
d. 有一台机器安装了mysql，作为zabbix系统的数据库；

整体部署如下图所示：

这里写图片描述

运行web应用的server

这是个基于maven的java web应用，里面有个spring mvc的controller，提供一个http服务，范围某个业务每分钟的业务量，代码如下图所示：

@Controller
public class CountController {

    @RequestMapping("/count")
    @ResponseBody
    public int count(String model, String type) {
        int base;
        int max;
        int min;

        if("a".equals(model)){
            base = 50000;
        }else{
            base =10000;
        }

        if("0".equals(type)){
            max = 9000;
            min = 1000;
        }else{
            max = 1000;
            min = 0;
        }

        return base + new Random().nextInt(max)%(max-min+1);
    }
}
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
从以上代码我们可以看出，http服务会返回随机数，此服务接受两个参数model和type，当model等于”a”时返回的随机数从50000开始，model不等于”a”时返回的随机数从10000开始，当type等于”0”时，在base的基础上增加的值是1000到9000之间，当type不等于”0”时，在base的基础上增加的值是0到1000之间；

整个工程的代码已经上传到git上，地址是git@github.com:zq2599/blog_demos.git，这个目录下由多个工程，本次实战的工程是zabbixcustomitemdemo，如下图：

这里写图片描述

docker-compose.yml文件

上面我们已经把四台机器的功能和关系梳理清楚了，现在就来制定docker-compose.yml文件吧：

version: '2'
services:
  zabbix-mysql-service: 
    image: daocloud.io/library/mysql:8
    container_name: zabbix-mysql-service
    environment:
      - MYSQL_ROOT_PASSWORD=888888
    restart: always
  zabbix-server-service:
    image: monitoringartist/zabbix-xxl:3.2.6
    links: 
      - zabbix-mysql-service:mysqlhost
    container_name: zabbix-server-service
    restart: always
    depends_on:
      - zabbix-mysql-service
    ports:
      - "8888:80"
    environment:
      - ZS_DBHost=mysqlhost
      - ZS_DBUser=root
      - ZS_DBPassword=888888
  zabbix-agent-a:
    image: zabbix/zabbix-agent:ubuntu-3.2.6
    links: 
      - zabbix-server-service:zabbixserverhost
    container_name: zabbix-agent-a
    restart: always
    depends_on:
      - zabbix-server-service
    environment:
      - ZBX_HOSTNAME=zabbix-agent-service-a
      - ZBX_SERVER_HOST=zabbixserverhost
  tomcat-server-service:
    image: bolingcavalry/bolingcavalrytomcat:0.0.1
    container_name: tomcat-server
    restart: always
    ports:
      - "8080:8080"
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
yml文件的内容如上所示，其中mysql、zabbix server，zabbix agent的配置和上一章《Docker下实战zabbix三部曲之二：监控其他机器》是一样的，新增的是一个tomcat的镜像，这个镜像是我在tomcat官方镜像的基础上做了点小改动，使得这个tomcat支持在线部署web应用，关于tomcat在线部署应用，请看文章《实战docker，编写Dockerfile定制tomcat镜像，实现web应用在线部署》

准备好yml文件之后，打开终端，在yml文件所在目录下执行docker-compose up -d可以将yml文件中所有的容器都启动；

注意，如果您的电脑之前已经运行过上一章《Docker下实战zabbix三部曲之二：监控其他机器》中的docker-compose.yml文件，那么本次执行docker-compose up -d会提示启动失败，已有同样名称的容器存在，这时候可以去上一章的docker-compose.yml文件所在目录执行docker-compose down，也可以通过docker ps -a将所有容器列出，再通过docker stop命令依次停止所有容器，再执行docker-compose rm命令依次删除；

部署web应用

打开终端，进入web工程zabbixcustomitemdemo的目录下，执行命令mvn clean package -U -Dmaven.test.skip=true tomcat7:redeploy，即可将web工程部署到tomcat容器上，关于在线部署的细节请参照文章《实战docker，编写Dockerfile定制tomcat镜像，实现web应用在线部署》;

部署成功后，打开浏览器，访问http://localhost:8080/zabbixcustomitemdemo/count，web server会返回一个数字，如下图所示：

这里写图片描述

制作访问url的shell脚本

接下来我们要在zabbix agent上做一个shell脚本，此脚本的功能时发起http请求http://localhost:8080/zabbixcustomitemdemo/count?model=a&type=0，就能得到web服务响应的数字，如果此脚本每分钟被调用一次，就能得到完整的监控曲线图了；

a. 首先，执行docker exec -it zabbix-agent-a /bin/bash登录zabbix agent的容器； 
b. 登录后，执行apt-get update更新apt； 
c. 先后执行apt-get install wget和apt-get install vim，安装wget和vi工具； 
d. 新建目录/usr/work/,在此目录下用vi创建一个shell文件biz_count.sh，内容如下：

#"!/bin/bash
wget -qO- http://tomcathost:8080/zabbixcustomitemdemo/count?model=$1\&type=$2
echo ""
1
2
3
上面代码的功能是访问http服务获取一个数字，其中model和type用的是shell的入参； 
注意两个细节： 
第一个：最后一行代码echo “”，实践证明这一行是很有用的，有了这一行就会在输出http返回的数字后进行换行，有了换行数据才能成功上报到zabbix server； 
第二个：wget命令后面的url参数中,”&”符号前面要加转义的斜杠”\”；

e. 执行chmod a+x biz_count.sh，给shell赋予可执行权限；

agent上添加监控项

继续在zabbix agent容器上，我们要添加一个自定义监控项，这样后面在zabbix server上就能使用该监控项了： 
a. 在/etc/zabbix/zabbix_agentd.d目录下，新增一个biz.conf文件，内容如下：

UserParameter=get_total_num[*],/usr/work/biz_count.sh $1 $2
1
以上代码配置了一个自定义监控项，名称是get_total_num，可以接受两个入参，该监控项会调用biz_count.sh这个脚本，并且把外部传来的两个入参直接传递给biz_count.sh;

b. 执行chmod a+r biz.conf使得该文件可读；

在zabbix agent上测试

继续在zabbix agent容器上，执行以下命令来测试刚刚新加的监控项：

/usr/sbin/zabbix_agentd -t get_total_num[a,0]
1
中括号中的a,0表示两个入参分别是”a”和”0”，我们执行四次，入参分别用[a,0]、[b,0]、[a,1]、[b,1]，得到的结果如下图所示：

这里写图片描述

四个返回值分别是54741、17097、50564、10919，结合前面的java代码可以发现两个参数都生效了，数字的大小范围因入参而变化；

为了让监控项生效，需要重启zabbix agent，不过这里有个更快捷的方法可以试试： 
a. 执行exit退出zabbix agent容器； 
b. 执行docker restart zabbix-agent-a重启zambia agent容器；

到了这里，自定义监控项已经准备好了，接下来在zabbix server上把它配置成功，我们就能看到监控数据和曲线图了，不过在配置前，我们可以在zabbix server上测试一下能否成功调用zabbix agent上的监控项；

在zabbix server上测试agent机器的监控项

首先我们要搞清楚zabbix agent机器的ip，有两种方法： 
第一种，执行docker exec -it zabbix-agent-a /bin/bash登录zabbix agent的容器，在容器中执行ip addr命令可以得到ip； 
第二种，直接执行docker exec -it zabbix-agent-a ip addr命令得到ip；

不论哪种，都能得到zabbix-agent的ip是172.31.0.5;

现在我们登录zabbix server容器，执行命令docker exec -it zabbix-server-service /bin/bash即可登录,登录后执行以下命令：

zabbix_get -s 172.31.0.5 -k get_total_num[a,0]
1
如下图所示，测试成功，调用agent的监控项返回了符合预期的数据：

这里写图片描述

还记得我们刚才在zabbix agent上配置好之后，需要重启agent服务或者重启zabbix agent容器，如果您忘了这一步，现在zabbix server上测试会得到如下错误提示：

这里写图片描述

这时候去重启一下，再回来测试就可以成功了。

在管理页面上添加监控项

在浏览器上输入”http://localhost:8888/“登录管理页面，先添加agent机器，如下图：

这里写图片描述

添加之后，点击下图红框位置，进入监控项页面：

这里写图片描述

如下图，点击右上角的“Create item”即可开始添加监控项：

这里写图片描述

新增的监控项，我们只要填写Name，Key，Update interval（更新频率）这几个字段，其他的保持不变，每个要更新的字段的内容如下图：

这里写图片描述

填写并保存后，我们可以在Monitoring -> Latest data中看到最新的监控项数据，如下图：

这里写图片描述

接下来我们添加一个监控图形，操作如下图所示，可以进入图形管理页面：

这里写图片描述

如下图，点击右上角的“Create graph”创建一个图形：

这里写图片描述

新建图形的时候，名称随意，只要Items选中刚刚创建的监控项即可，如下图：

这里写图片描述

创建成功，现在要看看效果了，操作如下图所示：

这里写图片描述

点击”add”之后，在弹出的页面上选择刚刚我们新建的图形选项，操作完毕后，点击下图红框位置，就能看见曲线图了：

这里写图片描述

曲线图如下：

这里写图片描述

以上就是自定义监控项开发和设置的所有过程，基于监控项的操作，除了图形还能添加tirgger用来告警，在添加action用来确定告警的动作，例如邮件短信的，有兴趣的读者可以实际操作实战。

