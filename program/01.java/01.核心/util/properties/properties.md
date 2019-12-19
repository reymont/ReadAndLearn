

java Properties配置文件写入与读取 - 幻影寒狼 https://blog.csdn.net/huanyinghanlang/article/details/78607665

一、Properties

1.作用：读写资源配置文件；

2.键与值只能为字符串；

3.方法：

setProperty(String key,String value)

getProperty(String key)

getProperty(String key,defaultValue)



后缀：.Properties

store(OutputStream out,String comments)

store(Wirter wirter,String comments)

.xml

storeToXML(OutputStream os,String comment);

storeToXML(OutputStream os,String comment,String encoding);

存储例子：

package com.uwo9.test05;
 
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Properties;
 
public class Test01 {
	public static void main(String[] args) throws FileNotFoundException, IOException {
		Properties pro = new Properties();
		// 存储
		pro.setProperty("driver", "oracle.jdbc.dirver.OracleDriver");
		pro.setProperty("url", "jdbc:oracle：thin：@localhost:1521:orcl");
		pro.setProperty("user", "scott");
		pro.setProperty("pwd", "tiger");
		// 获取
		// String url1=pro.getProperty("url1", "test");//存在获取给定值，不存在获取默认值
		// System.out.println(url1);
 
		// 存储到e:others绝对路径 盘符：
		// pro.store(new FileOutputStream("e:/others/db.properties"), "db配置");
		// pro.storeToXML(new FileOutputStream("e:/others/db.xml"), "db配置");
		// 使用相对路径 当前工程
		pro.store(new FileOutputStream("db.properties"), "db配置");
	}
}

读取例子：
package com.uwo9.test05;
 
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.Properties;
 
public class Test01 {
	public static void main(String[] args) throws FileNotFoundException, IOException {
		Properties pro = new Properties();
		// 读取绝对路径
		// pro.load(new FileReader("e:/others/db.properties"));
		// 读取相对路径
		//pro.load(new FileReader("src/com/uwo9/others/pro/db.properties"));
		// 类相对路径 /bin    bin目录下读取
		//pro.load(Test01.class.getResourceAsStream("/com/uwo9/others/pro/db.properties"));
		// "" bin
		//pro.load(Test01.class.getClassLoader().getResourceAsStream("com/uwo9/others/pro/db.properties"));
		pro.load(Thread.currentThread().getContextClassLoader()
				.getResourceAsStream("com/uwo9/others/pro/db.properties"));
		
 
		System.out.println(pro.setProperty("user", "test"));
 
	}
}
————————————————
版权声明：本文为CSDN博主「幻影寒狼」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/huanyinghanlang/article/details/78607665


使用java.util.Properties实现配置文件的读取和写入 学习笔记 - yxl_1207的博客 https://blog.csdn.net/yxl_1207/article/details/81113675

java.util.Properties是对properties这类配置文件的映射。支持key-value类型和xml类型两种

首先，新建一个文件，如图：



然后再Java代码段输入如下代码：

import java.io.FileInputStream;
import java.io.InputStream;
import java.util.Properties;
 
public class Main {
 
    public static void main(String[] args) throws Exception {
	// write your code here
        Properties prop=new Properties();
        //创建输入流，用来读取文件
        InputStream is=new FileInputStream("test.properties");
        prop.load(is);//将流载入到Prop中，这时候文件里面的键值对已经读取到内存中了
        /*
        这句话是用来指定将内存中的键值对输出到控制台
        当然也可以指定到其他的路径，比如文件中
         */
        prop.list(System.out);
 
    }
}
运行，我们就能够在控制台看到文件中的那些键值对了：



当然，我们只要改变System.out就能更换储存的路径，我们还可以将Properties保存到file文件中，如下：

FileOutputStream oFile = new FileOutputStream(file, "a.properties");
pro.store(oFile, "Comment");
oFile.close();
如果comments不为空，保存后的属性文件第一行会是#comments,表示注释信息；如果为空则没有注释信息。

　　注释信息后面是属性文件的当前保存时间信息。
————————————————
版权声明：本文为CSDN博主「小仰」的原创文章，遵循 CC 4.0 BY-SA 版权协议，转载请附上原文出处链接及本声明。
原文链接：https://blog.csdn.net/yxl_1207/article/details/81113675

方便好使的java.util.Properties类 - HuSam - 博客园 https://www.cnblogs.com/husam/p/9997564.html

今天偶然碰到这个类，发现jdk中这些平时不大用到的类还挺好玩儿的，用起来也特别实在方便，随便写点记录下。

java.util.Properties是对properties这类配置文件的映射。支持key-value类型和xml类型两种。

key-value类型的配置文件大略长这样:

复制代码
复制代码
#测试环境配置：平台路径配置

jstrd_home=D:/TMS2006/webapp/tms2006/WEB-INF/

dbPort = localhost

databaseName = myd

dbUserName = root
复制代码
复制代码
#打头的是注释行，Properties会忽略注释。允许只有key没有value。

例如这样：

复制代码
复制代码
#测试环境配置：平台路径配置

jstrd_home=D:/TMS2006/webapp/tms2006/WEB-INF/

dbPort = 
databaseName
复制代码
复制代码
这种情况下，value会被set成null。

properties类实现了Map接口，所以很明显，他是用map来存储key-value数据，所以也注定存入数据是无序的，这个点需要注意。只能通过key的方式来get对应value。

针对key-value这种配置文件，是用load方法就能直接映射成map，非常简单好用。这种配置文件也是我们最重要碰到的配置文件，利用properties读取这类文件到内存一行代码就欧科，比自己解析强大多了，这点很赞。

读取配置文件的大略代码如下：

复制代码
复制代码
 1 public class LoadSample {  
 2     public static void main(String args[]) throws Exception {  
 3       Properties prop = new Properties();  
 4       FileInputStream fis =   
 5         new FileInputStream("sample.properties");  
 6       prop.load(fis);  
 7       prop.list(System.out);  
 8       System.out.println("\nThe foo property: " +  
 9           prop.getProperty("foo"));  
10     }  
11 }  
复制代码
复制代码
第六行的load方法直接生产一个内存map，第九行就能get到对应的value了，简单快捷。

这里的第七行list方法是一个输出方法，这边是输出到console，也可以输出到文件等，就能实现内存写入配置文件了。

比如这样：

复制代码
复制代码
 1 //通过list 方法将Properties写入Properties文件
 2 import java.io.IOException;
 3 import java.io.File;
 4 import java.io.FileInputStream;
 5 import java.io.PrintStream;
 6 import java.util.Properties;
 7 
 8 public class Test {
 9     public static void main(String[] args) {
10 
11         Properties p = new Properties();
12         p.setProperty("id","dean");
13         p.setProperty("password","123456");
14 
15         try{
16             PrintStream fW = new PrintStream(new File("e:\\test1.properties"));
17         　　p.list(fW );} catch (IOException e) {
18         　　e.printStackTrace();
19 
20         }
21     }
22 }        
复制代码
复制代码
这样就能把内存中的properties对象写入到文件中了。

 

另外一种配置形式是xml形式的，这种配置相对上面一种就少见一点。

 

xml形式的配置文件格式大略是这样：

复制代码
复制代码
<?xml version="1.0" encoding="UTF-8"?>  
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">  
<properties>  
<comment>Hi</comment>  
<entry key="foo">bar</entry>  
<entry key="fu">baz</entry>  
</properties>  
复制代码
复制代码
读取xml配置跟读取kv配置没差别，就是把load换成xml对应的loadFromXML方法，代码大略是这样：

复制代码
复制代码
 1 public class LoadSampleXML {  
 2     public static void main(String args[]) throws Exception {  
 3       Properties prop = new Properties();  
 4       FileInputStream fis =  
 5         new FileInputStream("sampleprops.xml");  
 6       prop.loadFromXML(fis);  
 7       prop.list(System.out);  
 8       System.out.println("\nThe foo property: " +  
 9           prop.getProperty("foo"));  
10     }  
11 }  
复制代码
复制代码
把内存中的properties对象写入到xml文件中也和上面差不多，就是把list方法改成xml对应的storeToXML方法。

代码大略是这样：

复制代码
复制代码
 1 import java.io.IOException;
 2 import java.io.File;
 3 import java.io.FileInputStream;
 4 import java.io.PrintStream;
 5 import java.util.Properties;
 6 
 7 public class Test {
 8     public static void main(String[] args) {
 9         Properties p = new Properties();
10         p.setProperty("id","dean");
11         p.setProperty("password","123456");
12 
13         try{
14             PrintStream fW = new PrintStream(new File("e:\\test1.xml"));
15             p.storeToXML(fW,"test");
16         } catch (IOException e) {
17             e.printStackTrace();
18         }
19     }
20 }
21                 
复制代码
复制代码
 

总的来说，虽然jdk中存在date类这种特别奇葩的类，但是这些不常用的工具类还是很方便使用的，要能用起来，在用得到的时候还是很能提高效率的。比自己写解析方便快捷多了。