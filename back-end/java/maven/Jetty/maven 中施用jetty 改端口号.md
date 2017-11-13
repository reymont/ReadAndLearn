

maven 中施用jetty 改端口号

maven 中使用jetty 改端口号
jetty 使用时，如果出现 address already in use , 可以换个端口再启用。用下面的命令： 

mvn -Djetty.port=8000 clean jetty:run

 

Cutoms->Goal
jpda.listen=maven
jetty:port=8000
 

