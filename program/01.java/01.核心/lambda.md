

* [【J2SE】IntelliJ IDEA中Lambda表达式警告:Can be replaced with method reference less - R3lish的专栏 - CSDN博客 ](http://blog.csdn.net/r3lish/article/details/51814580)


```java
 strings.forEach((String str)-> System.out.println(str));
 strings.forEach(System.out:prrintln);
```