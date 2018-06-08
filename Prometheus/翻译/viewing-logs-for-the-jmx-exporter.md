
查看JMX Exporter中的日志

原文：[Viewing Logs for the JMX Exporter | Robust Perception ](https://www.robustperception.io/viewing-logs-for-the-jmx-exporter/)


Brian Brazil August 19, 2015

有时从[JMX](https://en.wikipedia.org/wiki/Java_Management_Extensions) exporter拉取[mBeans](https://en.wikipedia.org/wiki/Java_Management_Extensions#Managed_beans)中的数据会产生一些错误。能够查看详细的日志能帮助你定位出错的mBean，还有为什么会出错。

创建一个名为logging.properties的文件:

```properties
handlers=java.util.logging.ConsoleHandler
java.util.logging.ConsoleHandler.level=ALL
io.prometheus.jmx.level=ALL
io.prometheus.jmx.shaded.io.prometheus.jmx.level=ALL
```

在java启动参数中，添加以下参数：

```bash
-Djava.util.logging.config.file=/path/to/logging.properties
```
如果运行应用程序，现在将看到标准错误日志。.

如果你已经有一个日志处理程序，比如logback，log4j或者是slf4j，你应该调整配置以适应启动JMX exporter。