

Ansible系列(七)：执行过程分析、异步模式和速度优化 - 骏马金龙 - 博客园 
http://www.cnblogs.com/f-ck-need-u/p/7580170.html

本文目录：
1.1 ansible执行过程分析
1.2 ansible并发和异步
1.3 ansible的-t选项妙用
1.4 优化ansible速度
　　1.4.1 设置ansible开启ssh长连接
　　1.4.2 开启pipelining
　　1.4.3 修改ansible执行策略
　　1.4.4 设置facts缓存


## 1.1 ansible执行过程分析
使用ansible的-vvv或-vvvv分析执行过程。以下是一个启动远程192.168.100.61上httpd任务的执行过程分析。其中将不必要的信息都是用"....."替换了。

```sh

# 读取配置文件，然后开始执行对应的处理程序。
Using /etc/ansible/ansible.cfg as config file
META: ran handlers

# 第一个任务默认都是收集远程主机信息的任务。
# 第一个收集任务，加载setup模块
Using module file /usr/lib/python2.7/site-packages/ansible/modules/system/setup.py

# 建立连接，获取被控节点当前用户的家目录，用于存放稍后的临时任务文件，此处返回值为/root。
# 在-vvv的结果中，第一行属于描述性信息，第二行为代码执行段，第三行类似此处的<host_node>(，，，，，)为上一段代码的返回结果。后同
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C ..........................
<192.168.100.61> (0, '/root\n', '')

# 再次建立连接，在远端创建临时任务文件的目录，临时目录由配置文件中的remote_tmp指令控制
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C .......................... '/bin/sh -c '"'"'( umask 77 && mkdir -p "` echo /root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202 `" && echo ansible-tmp-1495977564.58-40718671162202="` echo /root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202 `" ) && sleep 0'"'"''
<192.168.100.61> (0, 'ansible-tmp-1495977564.58-40718671162202=/root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202\n', '')

# 将要执行的任务放到临时文件中，并使用sftp将任务文件传输到被控节点上
<192.168.100.61> PUT /tmp/tmpY5vJGX TO /root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202/setup.py
<192.168.100.61> SSH: EXEC sftp -b - -C ............. '[192.168.100.61]'
<192.168.100.61> (0, 'sftp> put /tmp/tmpY5vJGX /root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202/setup.py\n', '')

# 建立连接，设置远程任务文件其所有者有可执行权限
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C ......................... '/bin/sh -c '"'"'chmod u+x /root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202/ /root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202/setup.py && sleep 0'"'"''
<192.168.100.61> (0, '', '')

# 建立连接，执行任务，执行完成后立即删除任务文件，并返回收集到的信息给ansible。到此为止，setup收集任务结束，关闭共享连接
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C ............ '/bin/sh -c '"'"'/usr/bin/python /root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202/setup.py; rm -rf "/root/.ansible/tmp/ansible-tmp-1495977564.58-40718671162202/" > /dev/null 2>&1 && sleep 0'"'"''
<192.168.100.61> (0, '\r\n{"invocation": {"...........', 'Shared connection to 192.168.100.61 closed.\r\n')


# 进入下一个任务，此处为服务管理任务，所以加载service模块
Using module file /usr/lib/python2.7/site-packages/ansible/modules/system/service.py

# 建立连接，获取被控节点当前用户的家目录，用于存放稍后的临时任务文件，此处返回值为/root
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C .........................
<192.168.100.61> (0, '/root\n', '')

# 建立连接，将要执行的任务放入到临时文件中，并传输到远程目录
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C .............. '/bin/sh -c '"'"'( umask 77 && mkdir -p "` echo /root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241 `" && echo ansible-tmp-1495977564.97-137863382080241="` echo /root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241 `" ) && sleep 0'"'"''
<192.168.100.61> (0, 'ansible-tmp-1495977564.97-137863382080241=/root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241\n', '')

<192.168.100.61> PUT /tmp/tmpn5uZhP TO /root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241/service.py
<192.168.100.61> SSH: EXEC sftp -b - -C .............. '[192.168.100.61]'
<192.168.100.61> (0, 'sftp> put /tmp/tmpn5uZhP /root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241/service.py\n', '')

# 建立连接，设置远程任务文件其所有者有可执行权限
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C ........................ '/bin/sh -c '"'"'chmod u+x /root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241/ /root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241/service.py && sleep 0'"'"''
<192.168.100.61> (0, '', '')

# 建立连接，执行任务，执行完成后立即删除任务文件，并将执行的结果返回到ansible端。到此为止，service模块任务执行结束，关闭共享连接
<192.168.100.61> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.61> SSH: EXEC ssh -C .............. '/bin/sh -c '"'"'/usr/bin/python /root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241/service.py; rm -rf "/root/.ansible/tmp/ansible-tmp-1495977564.97-137863382080241/" > /dev/null 2>&1 && sleep 0'"'"''
<192.168.100.61> (0, '\r\n{"msg": "............', 'Shared connection to 192.168.100.61 closed.\r\n')
```

将上面的进行总结，执行过程将是这样的：

读取配置文件
加载inventory文件。包括主机变量和主机组变量
执行第一个任务：收集远程被控节点的信息
建立连接，获取家目录信息
将要执行的收集任务放到临时文件中
将临时任务文件传输到被控节点的临时目录中
ssh连接到远端执行收集任务
删除任务文件
将收集信息返回给ansible端
关闭连接
执行第二个任务，此为真正的主任务
建立连接，获取家目录信息
将要执行的任务放到临时文件中
将临时任务文件传输到被控节点的临时目录中
ssh连接到远端执行任务
删除任务文件
将执行结果返回给ansible端，ansible输出到屏幕或指定文件中
关闭连接
执行第三个任务
执行第四个任务
如果是多个被控节点，那么将同时在多个节点上并行执行每一个任务，例如同时执行信息收集任务。不同节点之间的任务没有先后关系，主要依赖于性能。每一个任务执行完毕都会立即将结果返回给ansible端，所以可以通过ansible端结果的输出顺序和速度判断执行完毕的先后顺序。

如果节点数太多，ansible无法一次在所有远程节点上执行任务，那么将先在一部分节点上执行一个任务(每一批节点的数量取决于fork进程数量)，直到这一批所有节点上该任务完全执行完毕才会接入下一个批节点(数量取决于fork进程数量)，直到所有节点将该任务都执行完毕，然后重新回到第一批节点开始执行第二个任务。依次类推，直到所有节点执行完所有任务，ansible端才会释放shell。这是默认的同步模式，也就是说在未执行完毕的时候，ansible是占用当前shell的，任务执行完毕后，释放shell了才可以输入其他命令做其他动作。

如果是异步模式，假如fork控制的并发进程数为5，远程控制节点为24个，则ansible一开始会将5个节点的任务扔在后台，并每隔一段时间去检查这些节点的任务完成情况，当某节点完成不会立即返回，而是继续等待直到5个进程都空闲了，才会将这5个节点的结果返回给ansible端，ansible会继续将下一批5个节点的任务扔在后台并每隔一段时间进行检查，依次类推，直到完成所有任务。

在异步模式下，如果设置的检查时间间隔为0，在将每一批节点的任务丢到后台后都会立即返回ansible，并立即将下一批节点的任务丢到后台，直到所有任务都丢到后台完成后，会返回ansible端，ansible会立即释放占用的shell。也就是说，此时ansible是不会管各个节点的任务执行情况的，不管执行成功还是失败。

因此，在轮训检查时间内，ansible仍然正在运行(尽管某批任务已经被放到后台执行了)，当前shell进程仍被占用处于睡眠状态，只有指定的检查时间间隔为0，才会尽快将所有任务放到后台并释放shell。

需要注意3点：

1 .按批(例如每次5台全部完成一个任务才进入下一批的5台)完成任务的模式在ansible 2.0版本之后可以通过修改ansible的执行策略来改变(见后文)，改变后会变成"前赴后继"的执行模式：当一个节点执行完一个任务会立即接入另一个节点，不再像默认情况一样等待这一批中的其他节点完成该任务。
2 .上面执行过程是默认的执行过程，如果开启了pipelining加速anisble执行效率，会省去sftp到远端的过程。
3 .信息收集任务是默认会执行的，但是可以设置禁用它。


## 1.2 ansible并发和异步
上面已经对ansible的执行过程进行了很详细的分析，也解释了同步和异步的模式是如何处理任务的。所以此处简单举几个例子。

ansible默认只会创建5个进程并发执行任务，所以一次任务只能同时控制5台机器执行。如果有大量的机器需要控制，例如20台，ansible执行一个任务时会先在其中5台上执行，执行成功后再执行下一批5台，直到全部机器执行完毕。使用-f选项可以指定进程数，指定的进程数量多一些，不仅会实现全并发，对异步的轮训poll也会有正面影响。

ansible默认是同步阻塞模式，它会等待所有的机器都执行完毕才会在前台返回。可以采取异步执行模式。

异步模式下，ansible会将节点的任务丢在后台，每台被控制的机器都有一个job_id，ansible会根据这个job_id去轮训该机器上任务的执行情况，例如某机器上此任务中的某一个阶段是否完成，是否进入下一个阶段等。即使任务早就结束了，但只有轮训检查到任务结束后才认为该job结束。可以指定任务检查的时间间隔，默认是10秒。除非指定任务检查的间隔为0，否则会等待所有任务都完成后，ansible端才会释放占用的shell。

如果指定时间间隔为0，则ansible会立即返回(至少得连接上目标主机，任务发布成功之后立即返回)，并不会去检查它的任务进度。

ansible centos -B200 -P 0 -m yum -a "name=dos2unix" -o -f 6 
192.168.100.61 | SUCCESS => {"ansible_job_id": "986026954359.9166", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/986026954359.9166", "started": 1}
192.168.100.59 | SUCCESS => {"ansible_job_id": "824724696770.9431", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/824724696770.9431", "started": 1}
192.168.100.60 | SUCCESS => {"ansible_job_id": "276581152579.10006", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/276581152579.10006", "started": 1}
192.168.100.64 | SUCCESS => {"ansible_job_id": "237326453903.72268", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/237326453903.72268", "started": 1}
192.168.100.63 | SUCCESS => {"ansible_job_id": "276700021098.73070", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/276700021098.73070", "started": 1}
192.168.100.65 | SUCCESS => {"ansible_job_id": "877427488272.72032", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/877427488272.72032", "started": 1}
关于同步、异步以及异步时的并行数、轮训间隔对ansible的影响，通过以下示例说明：

当有6个节点时，仅就释放shell的速度而言，以下几种写法：
```sh
# 同步模式，大约10秒返回。
ansible centos -m command -a "sleep 5" -o 
# 异步模式，分两批执行。大约10秒返回。
ansible centos -B200 -P 1 -m command -a "sleep 5" -o -f 5
# 异步模式，和上一条命令时间差不多，但每次检查时间长一秒，所以可能会稍有延迟。大约11-12秒返回。
ansible centos -B200 -P 2 -m command -a "sleep 5" -o -f 5
# 异步模式，一批就执行完，大约5-6秒返回。
ansible centos -B200 -P 1 -m command -a "sleep 5" -o -f 6
# 异步模式，一批就完成，大约5-6秒完成。
ansible centos -B200 -P 2 -m command -a "sleep 5" -o -f 6 
# 异步模式，分两批，且检查时间过长。即使只睡眠5秒，但仍需要10秒才能判断该批执行结束。所以大约20秒返回。
ansible centos -B200 -P 10 -m command -a "sleep 5" -o -f 5 
# 异步模式，一批执行完成，但检查时间超过睡眠时间，因此大约10秒返回。
ansible centos -B200 -P 10 -m command -a "sleep 5" -o -f 6
```
在异步执行任务时，需要注意那些有依赖性的任务。对于那些对资源要求占有排它锁的任务，如yum，不应该将Poll的间隔设置为0。如果设置为0，很可能会导致资源阻塞。

总结来说,大概有以下一些场景需要使用到ansible的异步特性：

某个task需要运行很长的时间,这个task很可能会达到ssh连接的timeout
没有任务是需要等待它才能完成的，即没有任务依赖此任务是否完成的状态
需要尽快返回当前shell
当然也有一些场景不适合使用异步特性：

这个任务是需要运行完后才能继续另外的任务的
申请排它锁的任务
当然，对于有任务依赖性的任务，也还是可以使用异步模式的，只要检查它所依赖的主任务状态已完成就可以。例如，要配置nginx，要求先安装好nginx，在配置nginx之前先检查yum安装的状态。

- name: 'YUM - fire and forget task'
  yum: name=nginx state=installed
  async: 1000
  poll: 0
  register: yum_sleeper

- name: 'YUM - check on fire and forget task'
  async_status: jid={{ yum_sleeper.ansible_job_id }}
  register: job_result
  until: job_result.finished
  retries: 30

## 1.3 ansible的-t选项妙用
ansible的"-t"或"--tree"选项是将ansible的执行结果按主机名保存在指定目录下的文件中。

有些时候，ansible执行起来的速度会非常慢，这种慢体现在即使执行的是一个立即返回的简单命令(如ping模块)，也会耗时很久，且不是因为ssh连接慢导致的。如果使用-t选项，将第一次执行得到的结果按inventory中定义的主机名保存在文件中，下次执行到同一台主机时速度将会变快很多，即使之后不再加上-t选项，也可以在一定时间内保持迅速执行。即使执行速度正常（如执行一个Ping命令0.7秒左右），使用-t选项也可以在此基础上变得更快。

除了使用-t选项，使用重定向将结果重定向到某个文件中也是一样的效果。至于为何会如此，我也不知道，是在无意中测试出来的。有必要指出：我在CentOS 6.6上遇到过这样的问题，但并不是总会如此，且在CentOS 7上正常。因此，如果你也出现了这样的问题，可以参考这种偏方。

以CentOS 6.6安装的ansible 2.3为例，正常执行ansible会非常慢，使用-t可以解决这个问题。如下。

没有使用-t时：移除dos2unix包所需时间为13秒多。

time ansible centos -B200 -P 0 -m yum -a "name=dos2unix state=removed" -o -f 6
192.168.100.60 | SUCCESS => {"ansible_job_id": "987125400759.10653", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/987125400759.10653", "started": 1}
192.168.100.63 | SUCCESS => {"ansible_job_id": "735153954362.74074", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/735153954362.74074", "started": 1}
192.168.100.61 | SUCCESS => {"ansible_job_id": "192721090554.9813", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/192721090554.9813", "started": 1}
192.168.100.64 | SUCCESS => {"ansible_job_id": "494724112239.73269", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/494724112239.73269", "started": 1}
192.168.100.59 | SUCCESS => {"ansible_job_id": "2259915341.10078", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/2259915341.10078", "started": 1}
192.168.100.65 | SUCCESS => {"ansible_job_id": "755223232484.73025", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/755223232484.73025", "started": 1}

real    0m13.746s
user    0m1.288s
sys     0m1.417s
使用-t选项后：安装dos2unix只需1.9秒左右。

time ansible centos -B200 -P 0 -m yum -a "name=dos2unix state=installed" -o -f 6 -t /tmp/a 


real    0m1.933s
user    0m0.398s
sys     0m0.900s
之后即使不再使用-t选项，对同样的主机进行操作，速度也会变得非常快。

time ansible centos -B200 -P 0 -m yum -a "name=dos2unix state=removed" -o -f 6

real    0m1.730s
user    0m0.892s
sys     0m0.572s
至于保存的内容为何？实际上仅仅只是保存了普通的输出内容而已。

ll /tmp/a/
total 24
-rw-r--r-- 1 root root 145 May 28 15:54 192.168.100.59
-rw-r--r-- 1 root root 145 May 28 15:54 192.168.100.60
-rw-r--r-- 1 root root 143 May 28 15:54 192.168.100.61
-rw-r--r-- 1 root root 143 May 28 15:54 192.168.100.63
-rw-r--r-- 1 root root 145 May 28 15:54 192.168.100.64
-rw-r--r-- 1 root root 145 May 28 15:54 192.168.100.65

cat /tmp/a/192.168.100.59
{"ansible_job_id": "659824383578.10145", "changed": true, "finished": 0, "results_file": "/root/.ansible_async/659824383578.10145", "started": 1}

1.4 优化ansible速度
最初，ansible的执行效率和saltstack(基于zeromq消息队列的方式)相比要慢的多的多，特别是被控节点量很大的时候。但是ansible发展到现在，它的效率得到了极大的改善。在被控节点不太多的时候，默认的设置已经够快，即使被控节点数量巨大的时候，也可以通过一些优化，极大的提高其执行效率。

前面"-t"选项也算是一种提速方式，但算是"bug"式的问题，所以没有通用性。


### 1.4.1 设置ansible开启ssh长连接

ansible天然支持openssh，默认连接方式下，它对ssh的依赖性非常强。所以优化ssh连接，在一定程度上也在优化ansible。其中一点是开启ssh的长连接，即长时间保持连接状态。

要开启ssh长连接，要求ansible端的openssh版本高于或等于5.6。使用ssh -V可以查看版本号。然后设置ansible使用ssh连接被控端的连接参数，此处修改/etc/ansible/ansible.cfg，在此文件中启动下面的连接选项，其中ControlPersist=5d是控制ssh连接会话保持时长为5天。

ssh_args = -C -o ControlMaster=auto -o ControlPersist=5d
除此之外直接设置/etc/ssh/ssh_config(不是sshd_config，因为ssh命令是客户端命令)中对应的长连接项也是可以的。 开启长连接后，在会话过期前会一直建立连接，在netstat的结果中会看到ssh连接是一直established状态，且会在当前用户家目录的".ansible/cp"目录下生成一些socket文件，每个会话一个文件。 例如：执行一次ad-hoc操作。

ansible centos -m ping
查看netstat，发现ssh进程的会话一直是established状态。

shell> netstat -tnalp

Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address      State       PID/Program name    
tcp        0      0 0.0.0.0:22              0.0.0.0:*            LISTEN      1143/sshd           
tcp        0      0 127.0.0.1:25            0.0.0.0:*            LISTEN      2265/master         
tcp        0      0 192.168.100.62:58474    192.168.100.59:22    ESTABLISHED 31947/ssh: /root/.a 
tcp        0     96 192.168.100.62:22       192.168.100.1:8189   ESTABLISHED 29869/sshd: root@pt 
tcp        0      0 192.168.100.62:37718    192.168.100.64:22    ESTABLISHED 31961/ssh: /root/.a 
tcp        0      0 192.168.100.62:38894    192.168.100.60:22    ESTABLISHED 31952/ssh: /root/.a 
tcp        0      0 192.168.100.62:48659    192.168.100.61:22    ESTABLISHED 31949/ssh: /root/.a 
tcp        0      0 192.168.100.62:33546    192.168.100.65:22    ESTABLISHED 31992/ssh: /root/.a 
tcp        0      0 192.168.100.62:54824    192.168.100.63:22    ESTABLISHED 31958/ssh: /root/.a 
tcp6       0      0 :::22                   :::*                 LISTEN      1143/sshd           
tcp6       0      0 ::1:25                  :::*                 LISTEN      2265/master
且家目录下"~/.ansible/cp/"下会生成对应的socket文件。

ls -l ~/.ansible/cp/
total 0
srw------- 1 root root 0 Jun  3 18:26 5c4a6dce87
srw------- 1 root root 0 Jun  3 18:26 bca3850113
srw------- 1 root root 0 Jun  3 18:26 c89359d711
srw------- 1 root root 0 Jun  3 18:26 cd829456ec
srw------- 1 root root 0 Jun  3 18:26 edb7051c84
srw------- 1 root root 0 Jun  3 18:26 fe17ac7eed

### 1.4.2 开启pipelining

pipeline也是openssh的一个特性。在ansible执行每个任务的流程中，有一个过程是将临时任务文件put到一个ansible端的一个临时文件中，然后sftp传输到远端，然后通过ssh连接过去远程执行这个任务。如果开启了pipelining，一个任务的所有动作都在一个ssh会话中完成，也会省去sftp到远端的过程，它会直接将要执行的任务在ssh会话中进行。

开启pipelining的方式是配置文件(如ansible.cfg)中设置pipelining=true，默认是false。

shell> grep '^pipelining' /etc/ansible/ansible.cfg
pipelining = True
但是要注意，如果在ansible中使用sudo命令的话(ssh user@host sudo cmd)，需要在被控节点的/etc/sudoers中禁用"requiretty"。

之所以要设置/etc/sudoers中的requiretty，是因为ssh远程执行命令时，它的环境是非登录式非交互式shell，默认不会分配tty，没有tty，ssh的sudo就无法关闭密码回显(使用"-tt"选项强制SSH分配tty)。所以出于安全考虑，/etc/sudoers中默认是开启requiretty的，它要求只有拥有tty的用户才能使用sudo，也就是说ssh连接过去不允许执行sudo。可以通过visudo编辑配置文件，注释该选项来禁用它。

grep requiretty /etc/sudoers
# Defaults    requiretty
修改设置/etc/sudoers是在被控节点上进行的(或者ansible连接过去修改)，其实在ansible端也可以解决sudo的问题，只需在ansible的ssh参数上加上"-tt"选项即可。

ssh_args = -C -o ControlMaster=auto -o ControlPersist=5d -tt
以下是开启pipelining前ansible执行过程，其中将很多不必要的信息使用......来替代了。

######## 开启pipelining前，执行ping模块的过程 ########
Using /etc/ansible/ansible.cfg as config file
Loading callback plugin minimal of type stdout, v2.0 from /usr/lib/python2.7/site-packages/ansible/plugins/callback/__init__.pyc
META: ran handlers
Using module file /usr/lib/python2.7/site-packages/ansible/modules/system/ping.py

# 首先建立一次ssh连接，获取远端当前用户家目录，用于存放稍后的临时任务文件
<192.168.100.65> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.65> SSH: EXEC ssh -vvv -C ................ 192.168.100.65 '/bin/sh -c '"'"'echo ~ && sleep 0'"'"''
<192.168.100.65> (0, '/root\n', ................)

# 再次建立ssh连接，创建临时文件目录
<192.168.100.65> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.65> SSH: EXEC ssh -vvv -C ..................... 192.168.100.65 '/bin/sh -c '"'"'( umask 77 && mkdir -p "......." ) && sleep 0'"'"''
<192.168.100.65> (0, 'ansible-tmp-1496489511.13-10633592020239=/root/.ansible/tmp/ansible-tmp-1496489511.13-10633592020239\n', '.............')

# 将任务放入到本地临时文件中，然后使用sftp传输到远端
<192.168.100.65> PUT /tmp/tmp2_VKGo TO /root/.ansible/tmp/ansible-tmp-1496489511.13-10633592020239/ping.py
<192.168.100.65> SSH: EXEC sftp -b - -vvv -C ................. '[192.168.100.65]'
<192.168.100.65> (0, 'sftp> put /tmp/tmp2_VKGo /root/.ansible/tmp/ansible-tmp-1496489511.13-10633592020239/ping.py\n', '.....................')

# 又一次建立ssh连接，对任务文件进行授权
<192.168.100.65> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.65> SSH: EXEC ssh -vvv -C ............. 192.168.100.65 '/bin/sh -c '"'"'chmod u+x .......... /ping.py && sleep 0'"'"''
<192.168.100.65> (0, '', '........................')

# 最后执行任务，完成任务后删除任务文件，并返回ansible端信息，注意ssh -tt选项，它强制为ssh会话分配tty，这样可以执行sudo命令
<192.168.100.65> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.65> SSH: EXEC ssh -vvv -C .............. -tt 192.168.100.65 '/bin/sh -c '"'"'/usr/bin/python .........../ping.py; rm -rf ".........." > /dev/null 2>&1 && sleep 0'"'"''
<192.168.100.65> (0, '\r\n{"invocation": {"...............')
以下是开启pipelining后，ansible执行过程。
########### 开启pipelining后，执行ping模块的过程 ########
Using /etc/ansible/ansible.cfg as config file
Loading callback plugin minimal of type stdout, v2.0 from /usr/lib/python2.7/site-packages/ansible/plugins/callback/__init__.pyc
META: ran handlers
Using module file /usr/lib/python2.7/site-packages/ansible/modules/system/ping.py

# 只建立一次ssh连接，所有动作都在这一个ssh连接中完成，由于没有使用-tt选项，所以需要在被控主机上禁用requiretty选项
<192.168.100.65> ESTABLISH SSH CONNECTION FOR USER: None
<192.168.100.65> SSH: EXEC ssh -vvv -C ............ 192.168.100.65 '/bin/sh -c '"'"'/usr/bin/python && sleep 0'"'"''
<192.168.100.65> (0, '\n{".............')
从上面的过程对比中可以看到，开启pipelining后，每次执行任务时都大量减少了ssh连接次数(只需要一次ssh连接)，且省去了sftp传输任务文件的过程，因此在管理大量节点时能极大提升执行效率。


### 1.4.3 修改ansible执行策略

默认ansible在远程执行任务是按批并行执行的，一批控制多少台主机由命令行的"-f"或"--forks"选项控制。例如，默认的并行进程数是5，如果有20台被控主机，那么只有在每5台全部执行完一个任务才继续下一批的5台执行该任务，即使中间某台机器性能较好，完成速度较快，它也会空闲地等待在那，直到所有20台主机都执行完该任务才会以同样的方式继续下一个任务。如下所示：

h1 h2 h3 h4 h5(T1)-->h6 h7 h8 h9 h10(T1)...-->h16 h17 h18 h19 h20(T1)-->h1 h2 h3 h4 h5(T2)-->.....

在ansible 2.0中，添加了一个策略控制选项strategy，默认值为"linear"，即上面按批并行处理的方式。还可以设置strategy的值为"free"。 在free模式下，ansible会尽可能快的切入到下一个主机。同样是上面的例子，首先每5台并行执行一个任务，当其中某一台机器由于性能较好提前完成了该任务，它不会等待其他4台完成，而是会跳出该任务让ansible切入到下一台机器来执行该任务。也就是说，这种模式下，一台主机完成一个任务后，另一台主机会立即执行任务，它是"前赴后继"的方式。如下所示：

h1 h2 h3 h4 h5(T1)-->h1 h2 h3 h4 h6(T1)-->h1 h3 h4 h6 h7(T1)-->......-->h17 h18 h19 h20(T1) h1(T2)-->h18 h19 h20(T1) h1 h2(T2)-->...

设置的方式如下：

- hosts: all
  strategy: free
  tasks:
  ...

### 1.4.4 设置facts缓存

ansible或ansible-playbook默认总是先收集facts信息。在被控主机较少的情况下，收集信息还可以容忍，如果被控主机数量非常大，收集facts信息会消耗掉非常多时间。

可以设置"gather_facts: no"来禁止ansible收集facts信息，但是有时候又需要使用facts中的内容，这时候可以设置facts的缓存。例如，在空闲的时候收集facts，缓存下来，在需要的时候直接读取缓存进行引用。

ansible的配置文件中可以修改'gathering'的值为'smart'、'implicit'或者'explicit'。smart表示默认收集facts，但facts已有的情况下不会收集，即使用缓存facts；implicit表示默认收集facts，要禁止收集，必须使用gather_facts: False；explicit则表示默认不收集，要显式收集，必须使用gather_facts: Ture。

在使用facts缓存时(即设置为smart)，ansible支持两种facts缓存：redis和jsonfile。

例如，以下是`/etc/ansible/ansible.cfg`中jsonfile格式的缓存配置方法。

```conf
[defaults]
gathering = smart
fact_caching_timeout = 86400
fact_caching = jsonfile
fact_caching_connection = /path/to/cachedir
```
这里设置的缓存过期时间为86400秒，即`缓存一天`。
缓存的json文件放在/path/to/cachedir目录下，各主机的`缓存文件以主机名命名`。
缓存文件是一个json文件，要查看缓存文件，如/path/to/cachedir/192.168.100.59中的内容，使用如下语句即可。

cat /path/to/cachedir/192.168.100.59 | python -m json.tool
回到系列文章大纲：http://www.cnblogs.com/f-ck-need-u/p/7048359.html

转载请注明出处：http://www.cnblogs.com/f-ck-need-u/p/7580170.html
注：若您觉得这篇文章还不错请点击下右下角的推荐，有了您的支持才能激发作者更大的写作热情，非常感谢！