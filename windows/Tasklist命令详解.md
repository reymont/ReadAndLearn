Tasklist命令详解_喜戈戈_新浪博客 http://blog.sina.com.cn/s/blog_4adc0d850100y9dh.html

“Tasklist”命令是一个用来显示运行在本地或远程计算机上的所有进程的命令行工具，带有多个执行参数。

作用:
结束一个或多个任务或进程。可以根据进程 ID 或图像名来结束进程。

语法格式：
TASKLIST [/S system [/U username [/P [password]]]]
          [/M [module] | /SVC | /V] [/FI filter] [/FO format] [/NH]

参数列表:
/S      system            指定连接到的远程系统。
/U      [domain\]user     指定使用哪个用户执行这个命令。
/P      [password]        为指定的用户指定密码。
/M      [module]          列出调用指定的 DLL 模块的所有进程。
                          如果没有指定模块名，显示每个进程加载的所有模块。
/SVC                     显示每个进程中的服务。
/V                       指定要显示详述信息。
/FI     filter            显示一系列符合筛选器指定的进程。

Tasklist命令详解
-eq, -ne: equal, not equal. 
-gt, -lt: greater, less than. 
-ge, -le: greater or equal, less than or equal. 
/FO     format            指定输出格式，有效值: "TABLE"、"LIST"、"CSV"。
/NH                      指定栏标头不应该在输出中显示。
                            只对 "TABLE" 和 "CSV" 格式有效。
－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－－
Tasklist实战:

1.查看本机进程(在一些特殊情况,比如任务管理器被禁用的时候,特别有效)
运行“cmd”，在提示符窗口中输入：“tasklist”命令，这样就显示本机的所有进程。本机的显示结果由五部分组成：图像名（进程名）、PID、会话名、会话＃、内存使用。
Tasklist命令详解
2.查看系统进程提供的服务
tasklist命令不但可以查看系统进程，而且还可以查看每个进程提供的服务。
在命令提示符下输入："tasklist   /svc",这样就列出了每个进程所调用的服务,怎么样,每个svchost.exe进程还正常

Tasklist命令详解
3.查看调用DLL模块文件的进程列表
例如，我们要查看本地系统中哪些进程调用了“shell32.dll” DLL模块文件。
   tasklist   /m   shell32.dll
这时系统将显示调用了shell32.dll文件的所有进程列表。

Tasklist命令详解
4.使用筛选器查找指定的进程
命令提示符下输入：TASKLIST    /FI     "USERNAME ne NT AUTHORITY\SYSTEM"      /FI "STATUS eq running"
这样就列出了系统中正在运行的非“SYSTEM“状态的所有进程。

Tasklist命令详解
更多................
tasklist /v /fi "PID gt 1000" /fo csv
tasklist /fi "USERNAME ne NT AUTHORITY\SYSTEM" /fi "STATUS eq running"
tasklist /v /fi "STATUS eq running"
tasklist /s srvmain /nh tasklist /s srvmain /svc /fi "Modules eq ntdll*"
tasklist /s srvmain /u maindom\hiropln /p p@ssW23 /nh