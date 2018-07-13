
* [Jenkins 命令行操作说明文档_小马哥淡定_新浪博客 ](http://blog.sina.com.cn/s/blog_5c9288aa0102v1zc.html)

假设Jenkins的URL为http://22.11.140.38:9080/jenkins/
 
基本的格式为
java -jar jenkins-cli.jar [-s JENKINS_URL] command [options][args]
 
下面具体介绍各个命令的作用及基本使用方法
 
1.       help 查看所有内嵌命令的基本功能  无参数
Eg.
java -jar jenkins-cli.jar -s http://22.11.140.38:9080/jenkins/  help
 
2.       build                       执行一次构建
参数说明：
JOB                 : Name of the job to build 要构建的job名称
 -c                  : Check for SCM changes before starting the build, and if
                       there's no change, exit without doing a build
 -p                  : Specify the build parameters in the key=value format.
 -r VAL              : Number of times to retry reading of the output log if it
                       does not exists on first attempt. Defaults to 0. Use
                       with -v.
 -s                  : Wait until the completion/abortion of the command
 -v                  : Prints out the console output of the build. Use with -s
 -w                  : Wait until the start of the command
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
3.       cancel-quiet-down: Cancel the effect of the "quiet-down" command.
4.       clear-queue: Clears the build queue
5.       connect-node: Reconnect to a node
6.       console: Retrieves console output of a build 显示某job某次构建的的控制台输出
参数说明：
JOB                 : Name of the job
 BUILD               : Build number or permalink to point to the build.
                       Defaults to the last build
 -f                  : If the build is in progress, stay around and append
                       console output as it comes, like 'tail -f'
 -n N                : Display the last N lines
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
    --password-file VAL : File that contains the password
 
7.       copy-job: Copies a job
参数说明：
 SRC                 : Name of the job to copy
 DST                 : Name of the new job to be created.
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
8.       create-job: Creates a new job by reading stdin as a configuration XML file.
从一个XML文档中创建一个job
Eg.
   java -jar /home/jboss/.jenkins/jenkins-cli.jar -s http://22.11.140.61:9080/jenkins/ create-job testttt
 
9.       create-node: Creates a new node by reading stdin as a XML configuration.
10.   delete-builds: Deletes build record(s)
参数说明：
JOB                 : Name of the job to build
RANGE              : Range of the build records to delete. 'N-M', 'N,M', or
                       'N'
--username VAL      : User name to authenticate yourself to Jenkins
--password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
--password-file VAL : File that contains the password
Eg.
java -jar /home/jboss/.jenkins/jenkins-cli.jar -s http://22.11.140.61:9080/jenkins/  delete-builds 3-5
 
11.   delete-job
参数说明：
NAME                : Job name
--username VAL      : User name to authenticate yourself to Jenkins
--password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
    --password-file VAL : File that contains the password
 
12.   delete-node  Deletes a node
13.   disable-job    Disables a job 相当于“停止构建”
参数说明：
NAME                : Job name
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
14.   disconnect-node       Disconnects from a node
15.   enable-job               Enables a job 相当于恢复可构建状态
参数说明：
NAME                : Job name
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
16.   get-job    Dumps the job definition XML to stdout 得到job定义的XML文档
参数说明：
JOB                 : Name of the job
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
17.   get-node      Dumps the node definition XML to stdout
18.   groovy        Executes the specified Groovy script.
19.   groovysh     Runs an interactive groovy shell.
20.   help                        Lists all the available commands. 无参数
21.   install-plugin           Installs a plugin either from a file, an URL, or from update center. 安装插件
22.   install-tool   Performs automatic tool installation, and print its location to stdout. Can be only called from inside a build.
23.   keep-build               Mark the build to keep the build forever.
24.   list-changes  Dumps the changelog for the specified build(s).输出某一次或几次构建的变更记录
参数说明：
JOB                         : Name of the job to build
 RANGE                       : Range of the build records to delete. 'N-M',
                               'N,M', or 'N'
 -format [XML | CSV | PLAIN] : Controls how the output from this command is
                               printed.
 --username VAL              : User name to authenticate yourself to Jenkins
 --password VAL              : Password for authentication. Note that passing a
                               password in arguments is insecure.
 --password-file VAL         : File that contains the password
 
25.   list-jobs       Lists all jobs in a specific view or item group.列出所有的jobs名称，其后可以接视图名称，默认显示全部
Eg.
   java -jar /home/jboss/.jenkins/jenkins-cli.jar -s http://22.11.140.61:9080/jenkins/  list-jobs viewname
 
26.   list-plugins  Outputs a list of installed plugins. 列出安装的所有插件
27.   login                       Saves the current credential to allow future commands to run without explicit credential information.保存登录状态
参数说明：
--username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
28.   logout         Deletes the credential stored with the login command. 注销
29.   mail            Reads stdin and sends that out as an e-mail.
30.   offline-node             Stop using a node for performing builds temporarily, until the next "online-node" command.
31.   online-node Resume using a node for performing builds, to cancel out the earlier "offline-node" command.
32.   quiet-down  Quiet down Jenkins, in preparation for a restart. Don?. start any builds.
33.   reload-configuration             Discard all the loaded data in memory and reload everything from file system. Useful when you modified config files directly on disk.重新加载配置文件无参数
34.   restart         Restart Jenkins 重启Jenkins
35.   safe-restart   Safely restart Jenkins 安全重启Jenkins，即等待已有的构建完成再重启
36.   safe-shutdown                      Puts Jenkins into the quiet mode, wait for existing builds to be completed, and then shut down Jenkins.安全关闭Jenkins
37.   session-id                Outputs the session ID, which changes every time Jenkins restarts
38.   set-build-description             Sets the description of a build.为已有构建添加描述
参数说明：
JOB                 : Name of the job to build
 BUILD#              : Number of the build
 DESCRIPTION         : Description to be set. '=' to read from stdin.
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
39.   set-build-display-name          Sets the displayName of a build重命名默认的构建编号
参数说明：
JOB                 : Name of the job to build
 BUILD#              : Number of the build
 DISPLAYNAME         : DisplayName to be set. '-' to read from stdin.
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
40.   set-build-parameter   Update/set the build parameter of the current build in progress
参数说明：
NAME                : Name of the build variable
 VALUE               : Value of the build variable
 --username VAL      : User name to authenticate yourself to Jenkins
 --password VAL      : Password for authentication. Note that passing a
                       password in arguments is insecure.
     --password-file VAL : File that contains the password
 
41.   set-build-result         Sets the result of the current build. Works only if invoked from within a build.
42.   shutdown     Immediately shuts down Jenkins server 立即关闭jenkins
43.   update-job   Updates the job definition XML from stdin. The opposite of the get-job command
44.   update-node             Updates the node definition XML from stdin. The opposite of the get-node command
45.   version        Outputs the current version. 查看当前版本
46.   wait-node-offline      Wait for a node to become offline
47.   wait-node-online      Wait for a node to become online
48.   who-am-i    Reports your credential and permissions 查看当前登录用户
 
Tips:为了操作方便，建议先通过login命令保存登录状态，这样就不需要每次执行操作都加上用户名密码参数了；缺点是安全性不好，记得操作结束之后logout