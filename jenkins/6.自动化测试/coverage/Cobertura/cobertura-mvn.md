

* [Mojo's Maven plugin for Cobertura – Introduction ](http://www.mojohaus.org/cobertura-maven-plugin/)
* [Mojo – Plugins ](http://www.mojohaus.org/plugins.html)
* [Maven + Cobertura code coverage example ](http://www.mkyong.com/qa/maven-cobertura-code-coverage-example/)

```sh
mvn cobertura:help          查看cobertura插件的帮助  
mvn cobertura:clean         清空cobertura插件运行结果  
mvn cobertura:check         运行cobertura的检查任务  
mvn cobertura:cobertura     运行cobertura的检查任务并生成报表，报表生成在target/site/cobertura目录下  
cobertura:dump-datafile     Cobertura Datafile Dump Mojo  
mvn cobertura:instrument    Instrument the compiled classes  
```