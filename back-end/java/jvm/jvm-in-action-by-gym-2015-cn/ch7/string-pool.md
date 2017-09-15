

<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Java字符串常量池](#java字符串常量池)
	* [概念](#概念)
		* [1. 常量池表（constant_pool table）](#1-常量池表constant_pool-table)
		* [2. 运行时常量池（Runtime Constant Pool）](#2-运行时常量池runtime-constant-pool)
		* [3. 字符串常量池（String Pool）](#3-字符串常量池string-pool)
	* [享元模式](#享元模式)
	* [1. 描述](#1-描述)
	* [2. 例子](#2-例子)
		* [1. String s = new String(“abc”) 创建了几个对象？](#1-string-s-new-stringabc-创建了几个对象)
		* [2. 下面程序的输出？](#2-下面程序的输出)
	* [参考文献：](#参考文献)

<!-- /code_chunk_output -->


# Java字符串常量池


* [Java字符串常量池 - 有且仅有的路 - CSDN博客 ](http://blog.csdn.net/u010297957/article/details/50995869)

开篇

同学们面试的时候总会被问到字符串常量池的问题吧？如果你是死记硬背的答案，那么我想看了我这篇文章，你应该以后能胸有成竹了

跟着Alan，走起！

## 概念

### 1. 常量池表（constant_pool table）

Class文件中存储所有常量（包括字符串）的table
这是Class文件中的内容，还不是运行时的内容，不要理解它是个池子，其实就是Class文件中的字节码指令

### 2. 运行时常量池（Runtime Constant Pool）

JVM内存中方法区的一部分，这是运行时的内容
这部分内容（绝大部分）是随着JVM运行时候，从常量池转化而来，每个Class对应一个运行时常量池
2中说绝大部分是因为：除了 Class中常量池内容，还可能包括动态生成并加入这里的内容

### 3. 字符串常量池（String Pool）

这部分也在方法区中，但与Runtime Constant Pool不是一个概念，String Pool是JVM实例全局共享的，全局只有一个
JVM规范要求进入这里的String实例叫“被驻留的interned string”，各个JVM可以有不同的实现，HotSpot是设置了一个哈希表StringTable来引用堆中的字符串实例，被引用就是被驻留

## 享元模式

其实字符串常量池这个问题涉及到一个设计模式，叫“享元模式”，顾名思义 - - - > 共享元素模式

也就是说：一个系统中如果有多处用到了相同的一个元素，那么我们应该只存储一份此元素，而让所有地方都引用这一个元素

Java中String部分就是根据享元模式设计的，而那个存储元素的地方就叫做“字符串常量池 - String Pool”

为了描述准确，下面我用上面说的的3个英文来描述了：constant_pool table、Runtime Constant Pool、String Pool

## 1. 描述

我觉的好像前面1和2随便说了点概念，就好像快说完了……

那么，来个Example吧！在*.java文件中有如下代码：

int a = 1;
String b = "asd";
首先，1和"asd"会在经过javac（或者其他编译器）编译过后变为Class文件中constant_pool table的内容

当我们的程序运行时，也就是说JVM运行时，每个Classconstant_pool table中的内容会被加载到JVM内存中的方法区中各自Class的Runtime Constant Pool

一个没有被String Pool包含的Runtime Constant Pool中的字符串（这里是"asd"）会被加入到String Pool中（HosSpot使用hashtable引用方式），步骤如下：

在Java Heap中根据"asd"字面量create一个字符串对象
将字面量"asd"与字符串对象的引用在hashtable中关联起来，键 - 值 形式是："asd" = 对象的引用地址
另外来说，当一个新的字符串出现在Runtime Constant Pool中时怎么判断需不需要在Java Heap中创建新对象呢？

策略是这样：会先去根据equals来比较Runtime Constant Pool中的这个字符串是否和String Pool中某一个是相等的（也就是找是否已经存在），如果有那么就不创建，直接使用其引用；反之，如上3

如此，就实现了享元模式，提高的内存利用效率

## 2. 例子

上面的描述其实对于能看到这篇文章的程序员们来说很好懂，下面我们来找一些面试题练练手吧

### 1. String s = new String(“abc”) 创建了几个对象？

答：

2个

解析：

首先，出现了字面量"abc"，那么去String Pool中查找是否有相同字符串存在，因为程序就这一行代码所以肯定没有，那么就在Java Heap中用字面量"abc"首先创建1个String对象

接着，new String("abc")，关键字new又在Java Heap中创建了1个对象，然后调用接收String参数的构造器进行了初始化。最终s的引用是这个String对象

如上：2个

### 2. 下面程序的输出？

```java
public static void main(String[] args) {
    String s1 = "abc";
    String s2 = new String("abc");
    String s3 = "a" + "bc";
    System.out.println(s1 == s2);
    System.out.println(s1 == s3);
    System.out.println(s1 == s1.intern());
}

答：

System.out.println(s1 == s2);//flase
System.out.println(s1 == s3);//true
System.out.println(s1 == s1.intern());//true
```

解析

首先，根据题1所述，这里同理，s1和s2肯定不是一个引用；

其次String s3 = "a" + "bc";这行代码最终是"abc"，根据s1，它已经在String pool中了，所以s3和s1是引用的同一个对象；

最后，s1.intern()方法：**将某个String对象在运行期动态的加入String pool**（如果pool中已经有一个了就不加）并返回String pool中保证唯一的一个字符串对象的引用。 
所以，还是会返回和s1同一个对象的引用，所以true；


## 参考文献：

[ 1 ] 周志明．深入理解Java虚拟机[M]．第2版．北京：机械工业出版社，2015.8. 
[ 2 ] Tim Lindholm,Frank Yellin,Gilad Bracha,Alex Buckley.The Java® Virtual Machine Specification . Java SE 8 Edition . 英文版[EB/OL].2015-02-13. 
[ 3 ] James Gosling,Bill Joy,Guy Steele,Gilad Bracha,Alex Buckley.The Java® Language Specification . Java SE 8 Edition . 英文版[EB/OL].2015-02-13.

下面是我追踪OpenJDK关于String pool实现方式的相关记录，很遗憾还没有追到底

String的native String intern()方法源码 
openjdk\jdk\src\share\native\java\lang\String.c

```c
#include "jvm.h"


#include "java_lang_String.h"


JNIEXPORT jobject JNICALL
Java_java_lang_String_intern(JNIEnv *env, jobject this)
{
 return JVM_InternString(env, this);
}
```
在jvm头文件中 
openjdk\jdk\src\share\javavm\export\jvm.h

```c
/*
* java.lang.String
*/
JNIEXPORT jstring JNICALL
JVM_InternString(JNIEnv *env, jstring str);

在jvm.cpp文件中 
openjdk\hotspot\src\share\vm\prims\jvm.cpp

// String support ///////////////////////////////////////////////////////////////////////////

JVM_ENTRY(jstring, JVM_InternString(JNIEnv *env, jstring str))
JVMWrapper("JVM_InternString");
JvmtiVMObjectAllocEventCollector oam;
if (str == NULL) return NULL;
oop string = JNIHandles::resolve_non_null(str);
oop result = StringTable::intern(string, CHECK_NULL);
return (jstring) JNIHandles::make_local(env, result);
JVM_END
```