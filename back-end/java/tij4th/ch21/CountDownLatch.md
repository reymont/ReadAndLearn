
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Java CountDownLatch应用](#java-countdownlatch应用)
* [什么时候使用CountDownLatch](#什么时候使用countdownlatch)
* [CountDownLatch和CyclicBarrier的区别](#countdownlatch和cyclicbarrier的区别)
* [Java并发编程：CountDownLatch、CyclicBarrier和Semaphore](#java并发编程countdownlatch-cyclicbarrier和semaphore)

<!-- /code_chunk_output -->




# Java CountDownLatch应用

*   [Java CountDownLatch应用 - zapldy - ITeye博客](http://zapldy.iteye.com/blog/746458)


Java的concurrent包里面的CountDownLatch其实可以把它看作一个计数器，只不过这个计数器的操作是原子操作，同时只能有一个线程去操作这个计数器，也就是同时**只能有一个线程去减这个计数器里面的值**。

你可以向CountDownLatch对象设置一个初始的数字作为计数值，**任何调用这个对象上的await()方法都会阻塞，直到这个计数器的计数值被其他的线程减为0为止**。

CountDownLatch的一个非常典型的应用场景是：**有一个任务想要往下执行，但必须要等到其他的任务执行完毕后才可以继续往下执行**。假如我们这个想要继续往下执行的任务调用一个CountDownLatch对象的await()方法，其他的任务执行完自己的任务后调用同一个CountDownLatch对象上的countDown()方法，这个**调用await()方法的任务将一直阻塞等待，直到这个CountDownLatch对象的计数值减到0为止**。

> 举个例子，有三个工人在为老板干活，这个老板有一个习惯，就是当三个工人把一天的活都干完了的时候，他就来检查所有工人所干的活。记住这个条件：三个工人先全部干完活，老板才检查。所以在这里用Java代码设计两个类，Worker代表工人，Boss代表老板，具体的代码实现如下：


```java
package org.zapldy.concurrent;  
  
import java.util.Random;  
import java.util.concurrent.CountDownLatch;  
import java.util.concurrent.TimeUnit;  
  
public class Worker implements Runnable{  
      
    private CountDownLatch downLatch;  
    private String name;  
      
    public Worker(CountDownLatch downLatch, String name){  
        this.downLatch = downLatch;  
        this.name = name;  
    }  
      
    public void run() {  
        this.doWork();  
        try{  
            TimeUnit.SECONDS.sleep(new Random().nextInt(10));  
        }catch(InterruptedException ie){  
        }  
        System.out.println(this.name + "活干完了！");  
        this.downLatch.countDown();  
          
    }  
      
    private void doWork(){  
        System.out.println(this.name + "正在干活!");  
    }  
      
}  
 
package org.zapldy.concurrent;  
  
import java.util.concurrent.CountDownLatch;  
  
public class Boss implements Runnable {  
  
    private CountDownLatch downLatch;  
      
    public Boss(CountDownLatch downLatch){  
        this.downLatch = downLatch;  
    }  
      
    public void run() {  
        System.out.println("老板正在等所有的工人干完活......");  
        try {  
            this.downLatch.await();  
        } catch (InterruptedException e) {  
        }  
        System.out.println("工人活都干完了，老板开始检查了！");  
    }  
  
}  
 

package org.zapldy.concurrent;  
  
import java.util.concurrent.CountDownLatch;  
import java.util.concurrent.ExecutorService;  
import java.util.concurrent.Executors;  
  
public class CountDownLatchDemo {  
  
    public static void main(String[] args) {  
        ExecutorService executor = Executors.newCachedThreadPool();  
          
        CountDownLatch latch = new CountDownLatch(3);  
          
        Worker w1 = new Worker(latch,"张三");  
        Worker w2 = new Worker(latch,"李四");  
        Worker w3 = new Worker(latch,"王二");  
          
        Boss boss = new Boss(latch);  
          
        executor.execute(w3);  
        executor.execute(w2);  
        executor.execute(w1);  
        executor.execute(boss);  
          
        executor.shutdown();  
    }  
  
}  
```
       当你运行CountDownLatchDemo这个对象的时候，你会发现是等所有的工人都干完了活，老板才来检查，下面是我本地机器上运行的一次结果，可以肯定的每次运行的结果可能与下面不一样，但老板检查永远是在后面的。
```
王二正在干活!  
李四正在干活!  
老板正在等所有的工人干完活......  
张三正在干活!  
张三活干完了！  
王二活干完了！  
李四活干完了！  
工人活都干完了，老板开始检查了！  
```
    好了，就写到这里，睡觉去了！

# 什么时候使用CountDownLatch

*   [什么时候使用CountDownLatch - ImportNew](http://www.importnew.com/15731.html)

# CountDownLatch和CyclicBarrier的区别

*   [CountDownLatch和CyclicBarrier的区别 - - ITeye博客](http://scau-fly.iteye.com/blog/1955165)

# Java并发编程：CountDownLatch、CyclicBarrier和Semaphore

*   [Java并发编程：CountDownLatch、CyclicBarrier和Semaphore - 海 子 - 博客园](http://www.cnblogs.com/dolphin0520/p/3920397.html)