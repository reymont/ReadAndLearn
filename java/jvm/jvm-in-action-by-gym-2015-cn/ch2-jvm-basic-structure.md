
<!-- @import "[TOC]" {cmd:"toc", depthFrom:1, depthTo:6, orderedList:false} -->
<!-- code_chunk_output -->

* [架构](#架构)
	* [pc寄存器](#pc寄存器)
* [JVM的参数](#jvm的参数)
* [堆](#堆)
* [栈](#栈)
	* [局部变量表](#局部变量表)

<!-- /code_chunk_output -->


# 架构

![jvm-structure.png](img/jvm-structure.png)

1. 类加载子系统将Class信息保存在方法区，方法区还存放运行时常量池信息。
2. 堆保存几乎所有的对象实例。堆是线程共享的。
3. Java NIO库可以访问Java堆外的直接内存。
4. 垃圾回收器对方法区、堆和直接内存进行回收。
5. 每个线程都有一个私有的栈。保存局部变量、方法参数。
6. JVM允许Java直接调用本地方法（通常是C）
7. 执行引擎执行虚拟机的字节码。

## pc寄存器

* [2.5.1　pc寄存器 - 51CTO.COM ](http://book.51cto.com/art/201312/421913.htm)

Java虚拟机可以支持多条线程同时执行，每一条Java虚拟机线程都有自己的pc（program counter）寄存器。在任意时刻，一条Java虚拟机线程只会执行一个方法的代码，这个正在被线程执行的方法称为该线程的当前方法（current method）。如果这个方法不是native的，那pc寄存器就保存Java虚拟机正在执行的字节码指令的地址，如果该方法是native的，那pc寄存器的值是undefined

# JVM的参数

```java
package geym.zbase.ch2;

public class SimpleArgs {
	public static void main(String[] args) {
		for(int i=0;i<args.length;i++){
			System.out.println("参数"+(i+1)+":"+args[i]);
		}
		System.out.println("-Xmx"+Runtime.getRuntime().maxMemory()/1000/1000+"M");
	}
}

```

* [java编译UTF-8文件乱码的问题 - 不落魄的书生的记事簿 - CSDN博客 ](http://blog.csdn.net/yaosongyuan/article/details/9120013)

```bash
#java编译UTF-8
javac -encoding UTF-8 geym\zbase\ch2\SimpleArgs.java
java geym.zbase.ch2.SimpleArgs
#设置最大堆
java -Xmx32m geym.zbase.ch2.SimpleArgs a
```

# 堆

几乎所有的对象都存放在堆中。通过垃圾回收机制，垃圾对象会被自动清理。

```json
[
    "老年代",
    "新生代"
    [
        "eden",
        "s0",
        "s1",
    ]
]
```

1. 大部分情况，对象首先分配在eden区
2. 第一次新生代回收，对象存活，进入s0或s1

```java
package geym.zbase.ch2.heap;

public class SimpleHeap {
    private int id;
    public SimpleHeap(int id){
        this.id=id;
    }
    public void show(){
        System.out.println("My ID is "+id);
    }
    public static void main(String[] args) {
        SimpleHeap s1=new SimpleHeap(1);
        SimpleHeap s2=new SimpleHeap(2);
        s1.show();
        s2.show();
    }
}
```

![heap-method-stack](img/heap-method-stack.png)

* 实例分配在堆中
* 描述类的信息放在方法区
* 局部变量存放在栈

# 栈

1. 栈是线程私有的内存空间。堆与程序数据相关，栈与线程相关。
2. 栈是先进后出的数据结构，出栈和入栈两种操作。函数调用压入栈帧；函数返回弹出栈帧。
3. 栈帧包含了局部变量表、操作数栈和帧数据。
4. 请求超过最大可用栈深度时，抛出StackOverflowError栈溢出错误。
5. 栈的大小决定了函数嵌套调用的层次。

```bash
#java编译UTF-8
javac -encoding UTF-8 geym\zbase\ch2\xss\TestStackDeep.java
java -Xss128K geym.zbase.ch2.xss.TestStackDeep
java -Xss256K geym.zbase.ch2.xss.TestStackDeep
```

```java
package geym.zbase.ch2.xss;

/**
 * -Xss1m
 * @author Administrator
 *
 */
public class TestStackDeep {
	private static int count=0;
	public static void recursion(long a,long b,long c){
		long e=1,f=2,g=3,h=4,i=5,k=6,q=7,x=8,y=9,z=10;
		count++;
		recursion(a,b,c);
	}
	public static void recursion(){
		count++;
		recursion();
	}
	public static void main(String args[]){
		try{
//			recursion(0L,0L,0L);
			recursion();
		}catch(Throwable e){
			System.out.println("deep of calling = "+count);
			e.printStackTrace();
		}
	}
}
```

## 局部变量表

局部变量表用于保存函数的参数以及局部变量。变量只在当前函数调用有效。