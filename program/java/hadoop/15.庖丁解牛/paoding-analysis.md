

## maven install

```sh
mvn install:install-file -Dfile=paoding-analysis.jar -DgroupId=net.paoding -DartifactId=paoding-analysis -Dversion=2.0.4 -Dpackaging=jar -DgeneratePom=true -DcreateChecksum=true
```

## 配置

修改paoding-analysis.jar中配置文件paoding-dic-home.properties的属性paoding.dic.home=classpath:dic，
将dic文件夹复制到项目的src文件夹中，并刷新项目至出现dic，dic.division,dic.locale目录。

1，把paoding-analysis-2.0.4-beta解压缩，给项目中加入paoding-analysis.jar。
2，把dic文件夹放到项目的根目录中。dic文件夹里是paoding的词库。
3，配置paoding的词库：把paoding-analysis-2.0.4-beta\src里面的paoding-dic-home.properties拷贝到项目的根目录下。编辑如下：

```conf
#values are "system-env" or "this";   
#if value is "this" , using the paoding.dic.home as dicHome if configed!   
#paoding.dic.home.config-fisrt=system-env   
paoding.dic.home.config-fisrt=this  
#dictionary home (directory)   
#"classpath:xxx" means dictionary home is in classpath.   
#e.g "classpath:dic" means dictionaries are in "classes/dic" directory or any other classpath directory   
#paoding.dic.home=dic   
paoding.dic.home=classpath:dic   
#seconds for dic modification detection   
#paoding.dic.detector.interval=60  
```
修改paoding .dic .home .config-fisrt=this ,使得程序知道该配置文件
修改paoding .dic .home =classpath:dic ，指定字典的所在路径。绝对路径也可以，但是不好。

## 参考

1. http://f.dataguru.cn/thread-518518-1-1.html
2. https://www.cnblogs.com/tjsquall/archive/2009/06/30/1514077.html