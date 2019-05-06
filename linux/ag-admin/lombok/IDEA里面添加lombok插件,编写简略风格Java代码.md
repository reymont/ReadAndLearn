IDEA里面添加lombok插件,编写简略风格Java代码 - CSDN博客 
http://blog.csdn.net/hinstenyhisoka/article/details/50468271

在 java平台上，lombok 提供了简单的注解的形式来帮助我们消除一些必须有但看起来很臃肿的代码, 比如属性的get/set，及对象的toString等方法，特别是相对于 POJO;

关于lombok的相关信息，lombok

下面开始在IDEA里面为我们的项目配置lombok编写支持咯，

1 . 首先在IDEA里面安装使用lombok编写简略风格代码的插件，

打开IDEA的Settings面板，并选择Plugins选项，然后点击 “Browse repositories..” 
这里写图片描述

在输入框输入”lombok”，得到搜索结果，选择第二个，点击安装，然后安装提示重启IDEA，安装成功; 
这里写图片描述

2 . 在自己的项目里添加lombok的编译支持(此处本人所操作的项目为maven项目),在pom文件里面添加如下indenpence

    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.16.6</version>
    </dependency>
1
2
3
4
5
3 . 然后就可以尽情在自己项目里面编写简略风格的Java代码咯

    package com.lombok;

    import lombok.Data;
    import lombok.EqualsAndHashCode;

    import java.util.List;

    /**
     * Created by Hinsteny on 2016/1/3.
     */
    @Data
    @EqualsAndHashCode(callSuper = false)
    public class Student {

        String name;
        int sex;
        Integer age;
        String address;

        List<String> books;


    }

    //使用Student类对象
    Student student = new Student();
    student.setName(name);
    student.setAge(age);
    student.setAddress(address);
    student.setBooks(Arrays.asList(books));
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
关于lombok的更多语法特性请参考: features