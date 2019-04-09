Jenkins高级篇之Pipeline方法篇-Pipeline Basic Steps-4-方法readFile和retry,sleep - Anthony_tester的博客 - CSDN博客 https://blog.csdn.net/u011541946/article/details/84035614

继续来学习basic steps这个插件支持的方法。前面一篇重点介绍了pipeline代码如何发送邮件，以及在一个html格式的邮件的模块方法里，我用到了readFile这个方法。本篇来学习readFile方法和retry和sleep方法

1.方法readFile

先看看官网关于这个方法的介绍。



这个readFile的功能就是从当然Jenkins的WORKSPACE路径下读一个文件，返回这个文件的字符串。有两个参数，第一个是file的path，第二个是encoding，默认是根据你当前平台的编码去解析。一般来说这个方法是用来读取文本文件的，例如txt,log,json,properties,config,yaml都可以。但是你非得要拿来读一个图片或者音频视频文件，那么上面说了，读取二进制文件会采用Base64转码的字符串输出。前面文章，我介绍了另外一个插件，支持读取json的方法叫readJSON,还有读取yaml文件的readYaml方法。一般来说，除非你知道是具体的json或者yaml，否则你用readFile准没错。

下面我们用readFile来读取一下/testdata/test_json.json

我的pipeline stage 代码
```groovy
import hudson.model.*;
 
println env.JOB_NAME
println env.BUILD_NUMBER
 
pipeline{
	
	agent any
	stages{
		stage("init") {
			steps{
				script {
					json_file = "${env.WORKSPACE}/testdata/test_json.json"
					file_contents = readFile json_file
					println file_contents
				}
			}
		}
	}
}
```
日志输出

[Pipeline] // stage
[Pipeline] withEnv
[Pipeline] {
[Pipeline] stage
[Pipeline] { (init)
[Pipeline] script
[Pipeline] {
[Pipeline] readFile
[Pipeline] echo
{
"NAME":"Anthony",
"AGE":18,
"CITY":"Beijing",
"GENDER":"male"
}
 
[Pipeline] }
[Pipeline] // script
[Pipeline] }
[Pipeline] // stage
[Pipeline] }
[Pipeline] // withEnv
[Pipeline] }
[Pipeline] // node
[Pipeline] End of Pipeline
Finished: SUCCESS
2.方法retry和sleep

这两个比较简单，就放一起介绍。retry的写法是这样的retry(3) {...}，sleep的写法是这样 sleep 2

其中retry(3)这个3是一个整数，表示尝试的次数，sleep中的2表示2秒，注意这单位是秒。

使用retry(3)只能在出现异常的地方才能使用，否则只跑一遍就结束。例如，我写一个try catch语句块，在try里面需要写得到一个值，在得到这个值可能存在异常。为了不让第一次出现异常就中断执行，那么这里就可以使用retry方法，使用retry把整个得到值的代码包裹起来，出现异常。不会里面中断走一下一个stage，会再试几次，几次由你确定。休眠这个方法sleep以后经常会使用到，比使用retry场景多很多。一般sleep和循环结合使用，例如循环10次，每次循环里面设置等待6分钟，那么这个方法执行超过60分钟才报错。

下面给一个简单的例子，基本上能演示出这两个方法的特点。
```groovy
import hudson.model.*;
 
println env.JOB_NAME
println env.BUILD_NUMBER
 
pipeline{
	
	agent any
	stages{
		stage("init") {
			steps{
				script {
					json_file = "${env.WORKSPACE}/testdata/test_json.json"
					file_contents = readFile json_file
					println file_contents
				}
			}
		}
		stage("retry and sleep") {
			steps{
				script{
				
				    try {
				        retry(3) {
				            println "here we are test retry fuction"
				            sleep 5
				            println 10/0
				            
				        }
				    }catch (Exception e) {
				        println e
				    }
				}
			}
		}
	}
}
```
我的jenkins 测试job，注意看日志，执行了三次打印：http://65.49.216.200:8080/job/pipeline_basic_steps/54/console
