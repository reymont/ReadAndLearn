

* [Java获取自身PID方法搜集 - CSDN博客 ](http://blog.csdn.net/jsutluo/article/details/6860855)

```java
RuntimeMXBean runtime = ManagementFactory.getRuntimeMXBean();
String name = runtime.getName(); // format: "pid@hostname"
```

Using shell script in addition to Java propertiesStart your app with a shellscript like this:
`exec java -Dpid=$$ -jar /Applications/bsh-2.0b4.jar`
then in java code call:
`System.getProperty("pid");`