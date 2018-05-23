
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Java相对路径读取文件](#java相对路径读取文件)
	* [1、在Java开发工具的project中使用相对路径](#1-在java开发工具的project中使用相对路径)
	* [2、通过CLASSPATH读取包内文件](#2-通过classpath读取包内文件)
	* [3、看看完整的测试代码](#3-看看完整的测试代码)
	* [5、获取CLASSPATH下文件的绝对路径](#5-获取classpath下文件的绝对路径)
* [Java文件IO操作应该抛弃File拥抱Paths和Files](#java文件io操作应该抛弃file拥抱paths和files)

<!-- /code_chunk_output -->



# Java相对路径读取文件

* [Java相对路径读取文件 - 熔 岩 - 51CTO技术博客 ](http://lavasoft.blog.51cto.com/62575/265821/)

不管你是新手还是老鸟，在程序中读取资源文件总会遇到一些找不到文件的问题，这与Java底层的实现有关，不能算bug，只要方法得当，问题还是可以解决的。
 
项目的文件夹结构：
repathtest 
├─src 
│    └─com 
│            └─lavasoft 
│                    ├─test 
│                    └─res 
├─doc
 
 

 
## 1、在Java开发工具的project中使用相对路径
在project中，相对路径的根目录是project的根文件夹，在此就是repathtest文件夹了。
创建文件的写法是：

```java
File f = new File("src/com/lavasoft/res/a.txt");
File f = new File("doc/b.txt");
``` 

注意：
路径不以“/”开头；
脱离了IDE环境，这个写法就是错误的，也并非每个IDE都如此，但我见到的都是这样的。
 
## 2、通过CLASSPATH读取包内文件
读取包内文件，使用的路径一定是相对的classpath路径，比如a，位于包内，此时可以创建读取a的字节流：
InputStream in = ReadFile.class.getResourceAsStream("/com/lavasoft/res/a.txt");
有了字节流，就能读取到文件内容了。
 
注意：
这里必须以“/”开头；
 
## 3、看看完整的测试代码
```java
package com.lavasoft.test; 

import java.io.*; 

/** 
* Java读取相对路径的文件 
* 
* @author leizhimin 2010-1-15 10:59:43 
*/ 
public class ReadFile { 
        public static void main(String[] args) { 
                readTextA_ByClassPath(); 
                readTextA_ByProjectRelativePath(); 
                readTextB_ByProjectRelativePath(); 
        } 

        /** 
         * 通过工程相对路径读取（包内）文件，注意不以“/”开头 
         */ 
        public static void readTextA_ByProjectRelativePath() { 
                System.out.println("-----------------readTextA_ByProjectRelativePath---------------------"); 
                File f = new File("src/com/lavasoft/res/a.txt"); 
                String a = file2String(f, "GBK"); 
                System.out.println(a); 
        } 

        /** 
         * 通过工程相对路径读取（包外）文件，注意不以“/”开头 
         */ 
        public static void readTextB_ByProjectRelativePath() { 
                System.out.println("-----------------readTextB_ByProjectRelativePath---------------------"); 
                File f = new File("doc/b.txt"); 
                String b = file2String(f, "GBK"); 
                System.out.println(b); 
        } 


        /** 
         * 通过CLASSPATH读取包内文件，注意以“/”开头 
         */ 
        public static void readTextA_ByClassPath() { 
                System.out.println("-----------------readTextA_ByClassPath---------------------"); 
                InputStream in = ReadFile.class.getResourceAsStream("/com/lavasoft/res/a.txt"); 
                String a = stream2String(in, "GBK"); 
                System.out.println(a); 
        } 

        /** 
         * 文件转换为字符串 
         * 
         * @param f             文件 
         * @param charset 文件的字符集 
         * @return 文件内容 
         */ 
        public static String file2String(File f, String charset) { 
                String result = null; 
                try { 
                        result = stream2String(new FileInputStream(f), charset); 
                } catch (FileNotFoundException e) { 
                        e.printStackTrace(); 
                } 
                return result; 
        } 

        /** 
         * 文件转换为字符串 
         * 
         * @param in            字节流 
         * @param charset 文件的字符集 
         * @return 文件内容 
         */ 
        public static String stream2String(InputStream in, String charset) { 
                StringBuffer sb = new StringBuffer(); 
                try { 
                        Reader r = new InputStreamReader(in, charset); 
                        int length = 0; 
                        for (char[] c = new char[1024]; (length = r.read(c)) != -1;) { 
                                sb.append(c, 0, length); 
                        } 
                        r.close(); 
                } catch (UnsupportedEncodingException e) { 
                        e.printStackTrace(); 
                } catch (FileNotFoundException e) { 
                        e.printStackTrace(); 
                } catch (IOException e) { 
                        e.printStackTrace(); 
                } 
                return sb.toString(); 
        } 
}
(代码写得粗糙，异常没做认真处理）
 
运行结果：
-----------------readTextA_ByClassPath--------------------- 
aaaaaaaaa 
sssssssss 
-----------------readTextA_ByProjectRelativePath--------------------- 
aaaaaaaaa 
sssssssss 
-----------------readTextB_ByProjectRelativePath--------------------- 
bbbbbbbbbbb 

Process finished with exit code 0
```

这是通过IDEA开发工具运行的，结果没问题，如果换成控制台执行，那么使用了项目相对路径的读取方式会失败，原因是，此时已经脱离了项目的开发环境，-----这个问题常常困扰着一些菜鸟，代码在开发工具好好的，发布后执行就失败了！
下面我截个图：

 
## 5、获取CLASSPATH下文件的绝对路径
当使用相对路径写入文件时候，就需要用到绝对路径。下面是个例子：
package com.lavasoft; 

import java.io.File; 

/** 
* CLASSPATH文件的绝对路径获取测试 
* 
* @author leizhimin 2010-1-18 9:33:02 
*/ 
public class Test { 
        //classpath的文件路径 
        private static String cp = "/com/lavasoft/cfg/syscfg.properties"; 

        public static void main(String[] args) { 
                //当前类的绝对路径 
                System.out.println(Test.class.getResource("/").getFile()); 
                //指定CLASSPATH文件的绝对路径 
                System.out.println(Test.class.getResource(cp).getFile()); 
                //指定CLASSPATH文件的绝对路径 
                File f = new File(Test.class.getResource(cp).getFile()); 
                System.out.println(f.getPath()); 
        } 
}
 
 
输出：
/D:/projects/bbt/code/cdn/planrpt/out/production/planrpt/ 
/D:/projects/bbt/code/cdn/planrpt/out/production/planrpt/com/lavasoft/cfg/syscfg.properties 
D:\projects\bbt\code\cdn\planrpt\out\production\planrpt\com\lavasoft\cfg\syscfg.properties 

Process finished with exit code 0
 
总结
使用工程相对路径是靠不住的。
使用CLASSPATH路径是可靠的。
对于程序要读取的文件，尽可能放到CLASSPATH下，这样就能保证在开发和发布时候均正常读取。
 
-----------------------
推荐资源：
http://www.91ziyuan.com/Html/?904.html
http://shirlly.javaeye.com/blog/218499
本文出自 “熔 岩” 博客，请务必保留此出处http://lavasoft.blog.51cto.com/62575/265821

# Java文件IO操作应该抛弃File拥抱Paths和Files

* [Java文件IO操作应该抛弃File拥抱Paths和Files - digdeep - 博客园 ](http://www.cnblogs.com/digdeep/p/4478734.html)


Java7中文件IO发生了很大的变化，专门引入了很多新的类：

import java.nio.file.DirectoryStream;
import java.nio.file.FileSystem;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.attribute.FileAttribute;
import java.nio.file.attribute.PosixFilePermission;
import java.nio.file.attribute.PosixFilePermissions;

......等等，来取代原来的基于java.io.File的文件IO操作方式.

1. Path就是取代File的

A Path represents a path that is hierarchical and composed of a sequence of directory and file name elements separated by a special separator or delimiter.

Path用于来表示文件路径和文件。可以有多种方法来构造一个Path对象来表示一个文件路径，或者一个文件：

1）首先是final类Paths的两个static方法，如何从一个路径字符串来构造Path对象：

        Path path = Paths.get("C:/", "Xmp");
        Path path2 = Paths.get("C:/Xmp");
        
        URI u = URI.create("file:///C:/Xmp/dd");        
        Path p = Paths.get(u);
2）FileSystems构造：

Path path3 = FileSystems.getDefault().getPath("C:/", "access.log");
3）File和Path之间的转换，File和URI之间的转换：

        File file = new File("C:/my.ini");
        Path p1 = file.toPath();
        p1.toFile();
        file.toURI();
4）创建一个文件：

复制代码
        Path target2 = Paths.get("C:\\mystuff.txt");
//      Set<PosixFilePermission> perms = PosixFilePermissions.fromString("rw-rw-rw-");
//      FileAttribute<Set<PosixFilePermission>> attrs = PosixFilePermissions.asFileAttribute(perms);
        try {
            if(!Files.exists(target2))
                Files.createFile(target2);
        } catch (IOException e) {
            e.printStackTrace();
        }
复制代码
windows下不支持PosixFilePermission来指定rwx权限。

5）Files.newBufferedReader读取文件：

复制代码
        try {
//            Charset.forName("GBK")
            BufferedReader reader = Files.newBufferedReader(Paths.get("C:\\my.ini"), StandardCharsets.UTF_8);
            String str = null;
            while((str = reader.readLine()) != null){
                System.out.println(str);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
复制代码
可以看到使用 Files.newBufferedReader 远比原来的FileInputStream，然后BufferedReader包装，等操作简单的多了。

这里如果指定的字符编码不对，可能会抛出异常 MalformedInputException ，或者读取到了乱码：

复制代码
java.nio.charset.MalformedInputException: Input length = 1
    at java.nio.charset.CoderResult.throwException(CoderResult.java:281)
    at sun.nio.cs.StreamDecoder.implRead(StreamDecoder.java:339)
    at sun.nio.cs.StreamDecoder.read(StreamDecoder.java:178)
    at java.io.InputStreamReader.read(InputStreamReader.java:184)
    at java.io.BufferedReader.fill(BufferedReader.java:161)
    at java.io.BufferedReader.readLine(BufferedReader.java:324)
    at java.io.BufferedReader.readLine(BufferedReader.java:389)
    at com.coin.Test.main(Test.java:79)
复制代码
6）文件写操作：

复制代码
        try {
            BufferedWriter writer = Files.newBufferedWriter(Paths.get("C:\\my2.ini"), StandardCharsets.UTF_8);
            writer.write("测试文件写操作");
            writer.flush();
            writer.close();
        } catch (IOException e1) {
            e1.printStackTrace();
        }
复制代码
7）遍历一个文件夹：

复制代码
        Path dir = Paths.get("D:\\webworkspace");
        try(DirectoryStream<Path> stream = Files.newDirectoryStream(dir)){
            for(Path e : stream){
                System.out.println(e.getFileName());
            }
        }catch(IOException e){
            
        }
复制代码
复制代码
        try (Stream<Path> stream = Files.list(Paths.get("C:/"))){
            Iterator<Path> ite = stream.iterator();
            while(ite.hasNext()){
                Path pp = ite.next();
                System.out.println(pp.getFileName());
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
复制代码
上面是遍历单个目录，它不会遍历整个目录。遍历整个目录需要使用：Files.walkFileTree

8）遍历整个文件目录：

复制代码
    public static void main(String[] args) throws IOException{
        Path startingDir = Paths.get("C:\\apache-tomcat-8.0.21");
        List<Path> result = new LinkedList<Path>();
        Files.walkFileTree(startingDir, new FindJavaVisitor(result));
        System.out.println("result.size()=" + result.size());        
    }
    
    private static class FindJavaVisitor extends SimpleFileVisitor<Path>{
        private List<Path> result;
        public FindJavaVisitor(List<Path> result){
            this.result = result;
        }
        @Override
        public FileVisitResult visitFile(Path file, BasicFileAttributes attrs){
            if(file.toString().endsWith(".java")){
                result.add(file.getFileName());
            }
            return FileVisitResult.CONTINUE;
        }
    }
复制代码
来一个实际例子：

复制代码
    public static void main(String[] args) throws IOException {
        Path startingDir = Paths.get("F:\\upload\\images");    // F:\\upload\\images\\2\\20141206
        List<Path> result = new LinkedList<Path>();
        Files.walkFileTree(startingDir, new FindJavaVisitor(result));
        System.out.println("result.size()=" + result.size()); 
        
        System.out.println("done.");
    }
    
    private static class FindJavaVisitor extends SimpleFileVisitor<Path>{
        private List<Path> result;
        public FindJavaVisitor(List<Path> result){
            this.result = result;
        }
        
        @Override
        public FileVisitResult visitFile(Path file, BasicFileAttributes attrs){
            String filePath = file.toFile().getAbsolutePath();       
            if(filePath.matches(".*_[1|2]{1}\\.(?i)(jpg|jpeg|gif|bmp|png)")){
                try {
                    Files.deleteIfExists(file);
                } catch (IOException e) {
                    e.printStackTrace();
                }
              result.add(file.getFileName());
            } return FileVisitResult.CONTINUE;
        }
    }
复制代码
将目录下面所有符合条件的图片删除掉：filePath.matches(".*_[1|2]{1}\\.(?i)(jpg|jpeg|gif|bmp|png)")

 

复制代码
    public static void main(String[] args) throws IOException {
        Path startingDir = Paths.get("F:\\111111\\upload\\images");    // F:\111111\\upload\\images\\2\\20141206
        List<Path> result = new LinkedList<Path>();
        Files.walkFileTree(startingDir, new FindJavaVisitor(result));
        System.out.println("result.size()=" + result.size()); 
        
        System.out.println("done.");
    }
    
    private static class FindJavaVisitor extends SimpleFileVisitor<Path>{
        private List<Path> result;
        public FindJavaVisitor(List<Path> result){
            this.result = result;
        }
        
        @Override
        public FileVisitResult visitFile(Path file, BasicFileAttributes attrs){
            String filePath = file.toFile().getAbsolutePath();
            int width = 224;
            int height = 300;
            StringUtils.substringBeforeLast(filePath, ".");
            String newPath = StringUtils.substringBeforeLast(filePath, ".") + "_1." 
                                            + StringUtils.substringAfterLast(filePath, ".");
            try {
                ImageUtil.zoomImage(filePath, newPath, width, height);
            } catch (IOException e) {
                e.printStackTrace();
                return FileVisitResult.CONTINUE;
            }
            result.add(file.getFileName());
            return FileVisitResult.CONTINUE;
        }
    }
复制代码
 

为目录下的所有图片生成指定大小的缩略图。a.jpg 则生成 a_1.jpg

 

2. 强大的java.nio.file.Files

1）创建目录和文件：

复制代码
        try {
            Files.createDirectories(Paths.get("C://TEST"));
            if(!Files.exists(Paths.get("C://TEST")))
                    Files.createFile(Paths.get("C://TEST/test.txt"));
//            Files.createDirectories(Paths.get("C://TEST/test2.txt"));
        } catch (IOException e) {
            e.printStackTrace();
        }
复制代码
注意创建目录和文件Files.createDirectories 和 Files.createFile不能混用，必须先有目录，才能在目录中创建文件。

2）文件复制:

从文件复制到文件：Files.copy(Path source, Path target, CopyOption options);

从输入流复制到文件：Files.copy(InputStream in, Path target, CopyOption options);

从文件复制到输出流：Files.copy(Path source, OutputStream out);

复制代码
        try {
            Files.createDirectories(Paths.get("C://TEST"));
            if(!Files.exists(Paths.get("C://TEST")))
                    Files.createFile(Paths.get("C://TEST/test.txt"));
//          Files.createDirectories(Paths.get("C://TEST/test2.txt"));
            Files.copy(Paths.get("C://my.ini"), System.out);
            Files.copy(Paths.get("C://my.ini"), Paths.get("C://my2.ini"), StandardCopyOption.REPLACE_EXISTING);
            Files.copy(System.in, Paths.get("C://my3.ini"), StandardCopyOption.REPLACE_EXISTING);
        } catch (IOException e) {
            e.printStackTrace();
        }
复制代码
3）遍历一个目录和文件夹上面已经介绍了：Files.newDirectoryStream ， Files.walkFileTree

4）读取文件属性：

            Path zip = Paths.get(uri);
            System.out.println(Files.getLastModifiedTime(zip));
            System.out.println(Files.size(zip));
            System.out.println(Files.isSymbolicLink(zip));
            System.out.println(Files.isDirectory(zip));
            System.out.println(Files.readAttributes(zip, "*"));
5）读取和设置文件权限：

复制代码
            Path profile = Paths.get("/home/digdeep/.profile");
            PosixFileAttributes attrs = Files.readAttributes(profile, PosixFileAttributes.class);// 读取文件的权限
            Set<PosixFilePermission> posixPermissions = attrs.permissions();
            posixPermissions.clear();
            String owner = attrs.owner().getName();
            String perms = PosixFilePermissions.toString(posixPermissions);
            System.out.format("%s %s%n", owner, perms);
            
            posixPermissions.add(PosixFilePermission.OWNER_READ);
            posixPermissions.add(PosixFilePermission.GROUP_READ);
            posixPermissions.add(PosixFilePermission.OTHERS_READ);
            posixPermissions.add(PosixFilePermission.OWNER_WRITE);
            
            Files.setPosixFilePermissions(profile, posixPermissions);    // 设置文件的权限
复制代码
Files类简直强大的一塌糊涂，几乎所有文件和目录的相关属性，操作都有想要的api来支持。这里懒得再继续介绍了，详细参见 jdk8 的文档。

 

一个实际例子：

复制代码
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class StringTools {
    public static void main(String[] args) {
        try {
            BufferedReader reader = Files.newBufferedReader(Paths.get("C:\\Members.sql"), StandardCharsets.UTF_8);
            BufferedWriter writer = Files.newBufferedWriter(Paths.get("C:\\Members3.txt"), StandardCharsets.UTF_8);

            String str = null;
            while ((str = reader.readLine()) != null) {
                if (str != null && str.indexOf(", CAST(0x") != -1 && str.indexOf("AS DateTime)") != -1) {
                    String newStr = str.substring(0, str.indexOf(", CAST(0x")) + ")";
                    writer.write(newStr);
                    writer.newLine();
                }
            }
            writer.flush();
            writer.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
复制代码
场景是，sql server导出数据时，会将 datatime 导成16进制的binary格式，形如：, CAST(0x0000A2A500FC2E4F AS DateTime))

所以上面的程序是将最后一个 datatime 字段导出的 , CAST(0x0000A2A500FC2E4F AS DateTime) 删除掉，生成新的不含有datetime字段值的sql 脚本。用来导入到mysql中。

 

做到半途，其实有更好的方法，使用sql yog可以很灵活的将sql server中的表以及数据导入到mysql中。使用sql server自带的导出数据的功能，反而不好处理。

 

分类: Java-IO/NIO/network