

# 实战JAVA虚拟机.JVM故障诊断与性能优化.葛一鸣.2015

代码

 https://github.com/reymont/szjvm.git

```bash
#java
javac -encoding UTF-8 geym\zbase\ch2\localvar\LocalVarGC.java
java -XX:+PrintGC geym.zbase.ch2.localvar.LocalVarGC
#cmd
mvn exec:java -Dexec.mainClass="com.gmail.mosoft521.ch02.SimpleArgs"
#powershell
mvn exec:java "-Dexec.mainClass=com.gmail.mosoft521.ch02.SimpleArgs"
 ```