https://blog.csdn.net/fdipzone/article/details/23000201

ssh命令格式如下：

usage: ssh [-1246AaCfgKkMNnqsTtVvXxYy] [-b bind_address] [-c cipher_spec]
           [-D [bind_address:]port] [-e escape_char] [-F configfile]
           [-I pkcs11] [-i identity_file]
           [-L [bind_address:]port:host:hostport]
           [-l login_name] [-m mac_spec] [-O ctl_cmd] [-o option] [-p port]
           [-R [bind_address:]port:host:hostport] [-S ctl_path]
           [-W host:port] [-w local_tun[:remote_tun]]
           [user@]hostname [command]

主要参数说明：
-l 指定登入用户

-p 设置端口号

-f 后台运行，并推荐加上 -n 参数

-n 将标准输入重定向到 /dev/null，防止读取标准输入

-N 不执行远程命令，只做端口转发

-q 安静模式，忽略一切对话和错误提示

-T 禁用伪终端配置



ssh 执行远程命令格式：

ssh [options][remote host][command]

假设远程服务器IP是192.168.110.34

例：查看远程服务器的cpu信息

ssh -l www-online 192.168.110.34 "cat /proc/cpuinfo"

www-online@onlinedev01:~$ ssh -l www-online 192.168.110.34 "cat /proc/cpuinfo"
www-online@192.168.110.34's password:
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 26
model name      : Intel(R) Xeon(R) CPU           E5506  @ 2.13GHz
stepping        : 5
cpu MHz         : 2128.000
cache size      : 4096 KB
fpu             : yes
fpu_exception   : yes
cpuid level     : 11
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology tsc_reliable nonstop_tsc aperfmperf pni ssse3 cx16 sse4_1 sse4_2 popcnt hypervisor lahf_lm
bogomips        : 4256.00
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:
 
processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 26
model name      : Intel(R) Xeon(R) CPU           E5506  @ 2.13GHz
stepping        : 5
cpu MHz         : 2128.000
cache size      : 4096 KB
fpu             : yes
fpu_exception   : yes
cpuid level     : 11
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology tsc_reliable nonstop_tsc aperfmperf pni ssse3 cx16 sse4_1 sse4_2 popcnt hypervisor lahf_lm
bogomips        : 4260.80
clflush size    : 64
cache_alignment : 64
address sizes   : 40 bits physical, 48 bits virtual
power management:

例：执行远程服务器的sh文件
首先在远程服务器的/home/www-online/下创建一个uptimelog.sh脚本

#!/bin/bash
uptime >> 'uptime.log'
 
exit 0
使用chmod增加可执行权限
chmod u+x uptimelog.sh
在本地调用远程的uptimelog.sh
ssh -l www-online 192.168.110.34 "/home/www-online/uptimelog.sh"
执行完成后,在远程服务器的/home/www-online/中会看到uptime.log文件，显示uptime内容
www-online@nmgwww34:~$ tail -f uptime.log
21:07:34 up 288 days,  8:07,  1 user,  load average: 0.05, 0.19, 0.31

例：执行远程后台运行sh
首先把uptimelog.sh修改一下,修改成循环执行的命令。作用是每一秒把uptime写入uptime.log

#!/bin/bash
while :
do
  uptime >> 'uptime.log'
  sleep 1
done
 
exit 0
我们需要这个sh在远程服务器以后台方式运行，命令如下：
ssh -l www-online 192.168.110.34 "/home/www-online/uptimelog.sh &"

www-online@onlinedev01:~$ ssh -l www-online 192.168.110.34 "/home/www-online/uptimelog.sh &"
www-online@192.168.110.34's password:
 
输入密码后，发现一直停住了，而在远程服务器可以看到，程序已经以后台方式运行了。
www-online@nmgwww34:~$ ps aux|grep uptimelog.sh
1007     20791  0.0  0.0  10720  1432 ?        S    21:25   0:00 /bin/bash /home/www-online/uptimelog.sh
原因是因为uptimelog.sh一直在运行，并没有任何返回，因此调用方一直处于等待状态。
我们先kill掉远程服务器的uptimelog.sh进程，然后对应此问题进行解决。



ssh 调用远程命令后不能自动退出解决方法

可以将标准输出与标准错误输出重定向到/dev/null，这样就不会一直处于等待状态。

ssh -l www-online 192.168.110.34 "/home/www-online/uptimelog.sh > /dev/null 2>&1 &"

www-online@onlinedev01:~$ ssh -l www-online 192.168.110.34 "/home/www-online/uptimelog.sh > /dev/null 2>&1 &"
www-online@192.168.110.34's password:
www-online@onlinedev01:~$
但这个ssh进程会一直运行在后台，浪费资源，因此我们需要自动清理这些进程。



实际上，想ssh退出，我们可以在ssh执行完成后kill掉ssh这个进程来实现。

首先，创建一个sh执行ssh的命令,这里需要用到ssh的 -f 与 -n 参数，因为我们需要ssh也以后台方式运行，这样才可以获取到进程号进行kill操作。

创建ssh_uptimelog.sh，脚本如下

#!/bin/bash
ssh -f -n -l www-online 192.168.110.34 "/home/www-online/uptimelog.sh &" # 后台运行ssh
 
pid=$(ps aux | grep "ssh -f -n -l www-online 192.168.110.34 /home/www-online/uptimelog.sh" | awk '{print $2}' | sort -n | head -n 1) # 获取进程号
 
echo "ssh command is running, pid:${pid}"
 
sleep 3 && kill ${pid} && echo "ssh command is complete" # 延迟3秒后执行kill命令，关闭ssh进程，延迟时间可以根据调用的命令不同调整
 
exit 0
可以看到，3秒后会自动退出
www-online@onlinedev01:~$ ./ssh_uptimelog.sh
www-online@192.168.110.34's password:
ssh command is running, pid:10141
ssh command is complete
www-online@onlinedev01:~$
然后查看远程服务器，可以见到uptimelog.sh 在后台正常执行。
www-online@nmgwww34:~$ ps aux|grep uptime
1007     28061  0.1  0.0  10720  1432 ?        S    22:05   0:00 /bin/bash /home/www-online/uptimelog.sh
查看uptime.log，每秒都有uptime数据写入。
www-online@nmgwww34:~$ tail -f uptime.log
22:05:44 up 288 days,  9:05,  1 user,  load average: 0.01, 0.03, 0.08
22:05:45 up 288 days,  9:05,  1 user,  load average: 0.01, 0.03, 0.08
22:05:46 up 288 days,  9:05,  1 user,  load average: 0.01, 0.03, 0.08
22:05:47 up 288 days,  9:05,  1 user,  load average: 0.01, 0.03, 0.08
22:05:48 up 288 days,  9:05,  1 user,  load average: 0.01, 0.03, 0.08