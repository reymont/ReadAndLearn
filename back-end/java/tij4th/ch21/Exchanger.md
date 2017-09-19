
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [Java：多线程，Exchanger同步器](#java多线程exchanger同步器)
	* [1. 背景](#1-背景)
	* [2. 示范代码](#2-示范代码)
* [java.util.concurrent包(7)-Exchanger使用](#javautilconcurrent包7-exchanger使用)
	* [示例1](#示例1)
	* [示例2](#示例2)

<!-- /code_chunk_output -->



# Java：多线程，Exchanger同步器

* [Java：多线程，Exchanger同步器 - 那些年的事儿 - 博客园 ](http://www.cnblogs.com/nayitian/archive/2013/09/12/3317384.html)

## 1. 背景
类java.util.concurrent.Exchanger提供了一个同步点，在这个同步点，一对线程可以交换数据。每个线程通过exchange()方法的入口提供数据给他的伙伴线程，并接收他的伙伴线程提供的数据，并返回。

当在运行不对称的活动时很有用。比如说，一个线程向buffer中填充数据，另一个线程从buffer中消费数据；这些线程可以用Exchange来交换数据。这个交换对于两个线程来说都是安全的。

## 2. 示范代码
```java
package com.clzhang.sample.thread;

import java.util.*;
import java.util.concurrent.Exchanger;

public class SyncExchanger {
    private static final Exchanger exchanger = new Exchanger();

    class DataProducer implements Runnable {
        private List list = new ArrayList();

        @Override
        public void run() {
            for (int i = 0; i < 5; i++) {
                System.out.println("生产了一个数据，耗时1秒");
                list.add(new Date());
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            }

            try {
                list = (List) exchanger.exchange(list);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            for (Iterator iterator = list.iterator(); iterator.hasNext();) {
                System.out.println("Producer " + iterator.next());
            }
        }
    }

    class DataConsumer implements Runnable {
        private List list = new ArrayList();

        @Override
        public void run() {
            for (int i = 0; i < 5; i++) {
                list.add("这是一个收条。");
            }

            try {
                list = (List) exchanger.exchange(list);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            for (Iterator iterator = list.iterator(); iterator.hasNext();) {
                Date d = (Date) iterator.next();
                System.out.println("Consumer: " + d);
            }
        }
    }

    public static void main(String[] args) {
        SyncExchanger ins = new SyncExchanger();
        new Thread(ins.new DataProducer()).start();
        new Thread(ins.new DataConsumer()).start();
    }
}
```
输出
生产了一个数据，耗时1秒
生产了一个数据，耗时1秒
生产了一个数据，耗时1秒
生产了一个数据，耗时1秒
生产了一个数据，耗时1秒
Producer 这是一个收条。
Producer 这是一个收条。
Producer 这是一个收条。
Producer 这是一个收条。
Producer 这是一个收条。
Consumer: Thu Sep 12 17:21:39 CST 2013
Consumer: Thu Sep 12 17:21:40 CST 2013
Consumer: Thu Sep 12 17:21:41 CST 2013
Consumer: Thu Sep 12 17:21:42 CST 2013
Consumer: Thu Sep 12 17:21:43 CST 2013

# java.util.concurrent包(7)-Exchanger使用

* [java.util.concurrent包(7)-Exchanger使用 - IT徐胖子的专栏 - CSDN博客 ](http://blog.csdn.net/woshixuye/article/details/35181223)

Java 并发 API 提供了一种允许2个并发任务间相互交换数据的同步应用。更具体的说，Exchanger类允许在2个线程间定义同步点，当2个线程到达这个点，他们相互交换数据类型，使用第一个线程的数据类型变成第二个的，然后第二个线程的数据类型变成第一个的。

## 示例1
一个人有零食，另一个人有钱，他们两个想等价交换，对好口号在某个地方相见，一个人先到了之后，必须等另一个人带着需要的东西来了之后，才能开始交换。
```java
public class ExchangerTest  
{  
    public static void main(String[] args)  
    {  
        ExecutorService service = Executors.newCachedThreadPool();  
        final Exchanger<String> exchanger = new Exchanger<String>();  
        service.execute(new Runnable()  
        {  
            public void run()  
            {  
                try  
                {  
                    String data1 = "零食";  
                    System.out.println("线程" + Thread.currentThread().getName() + "正在把数据" + data1 + "换出去");  
                    Thread.sleep((long) (Math.random() * 1000));  
                    String data2 = exchanger.exchange(data1);  
                    System.out.println("线程" + Thread.currentThread().getName() + "换回的数据为" + data2);  
                }  
                catch (Exception e)  
                {  
                }  
            }  
        });  
  
        service.execute(new Runnable()  
        {  
            public void run()  
            {  
                try  
                {  
                    String data1 = "钱";  
                    System.out.println("线程" + Thread.currentThread().getName() + "正在把数据" + data1 + "换出去");  
                    Thread.sleep((long) (Math.random() * 1000));  
                    String data2 = exchanger.exchange(data1);  
                    System.out.println("线程" + Thread.currentThread().getName() + "换回的数据为" + data2);  
                }  
                catch (Exception e)  
                {  
                }  
            }  
        });  
    }  
}  
```
线程pool-1-thread-1正在把数据零食换出去
线程pool-1-thread-2正在把数据钱换出去
线程pool-1-thread-2换回的数据为零食
线程pool-1-thread-1换回的数据为钱


## 示例2
这个类在遇到类似生产者和消费者问题时，是非常有用的。来一个非常经典的并发问题：你有相同的数据buffer，一个或多个数据生产者，和一个或多个数据消费者。只是Exchange类只能同步2个线程，所以你只能在你的生产者和消费者问题中只有一个生产者和一个消费者时使用这个类。
```java
public class Producer implements Runnable  
{  
  
    // 要被相互交换的数据类型。  
    private List<String> buffer;  
  
    // 用来同步 producer和consumer  
    private final Exchanger<List<String>> exchanger;  
  
    public Producer(List<String> buffer, Exchanger<List<String>> exchanger)  
    {  
        this.buffer = buffer;  
        this.exchanger = exchanger;  
    }  
  
    public void run()  
    {  
        // 实现10次交换  
        for (int i = 0; i < 10; i++)  
        {  
            buffer.add("第" + i + "次生产者的数据" + i);  
            try  
            {  
                // 调用exchange方法来与consumer交换数据  
                System.out.println("第" + i + "次生产者在等待.....");  
                buffer = exchanger.exchange(buffer);  
                System.out.println("第" + i + "次生产者交换后的数据：" + buffer.get(i));  
            }  
            catch (InterruptedException e)  
            {  
                e.printStackTrace();  
            }  
        }  
    }  
}  
  
  
public class Consumer implements Runnable  
{  
    // 用来相互交换  
    private List<String> buffer;  
  
    // 用来同步 producer和consumer  
    private final Exchanger<List<String>> exchanger;  
  
    public Consumer(List<String> buffer, Exchanger<List<String>> exchanger)  
    {  
        this.buffer = buffer;  
        this.exchanger = exchanger;  
    }  
  
    public void run()  
    {  
        // 实现10次交换  
        for (int i = 0; i < 10; i++)  
        {  
            buffer.add("第" + i + "次消费者的数据" + i);  
            try  
            {  
                // 调用exchange方法来与consumer交换数据  
                System.out.println("第" + i + "次消费者在等待.....");  
                buffer = exchanger.exchange(buffer);  
                System.out.println("第" + i + "次消费者交换后的数据：" + buffer.get(i));  
            }  
            catch (InterruptedException e)  
            {  
                e.printStackTrace();  
            }  
        }  
    }  
}  
  
public class Core  
{  
    public static void main(String[] args)  
    {  
        // 创建2个buffers，分别给producer和consumer使用  
        List<String> buffer1 = new ArrayList<String>();  
        List<String> buffer2 = new ArrayList<String>();  
  
        // 创建Exchanger对象，用来同步producer和consumer  
        Exchanger<List<String>> exchanger = new Exchanger<List<String>>();  
  
        // 创建Producer对象和Consumer对象  
        Producer producer = new Producer(buffer1, exchanger);  
        Consumer consumer = new Consumer(buffer2, exchanger);  
  
        // 创建线程来执行producer和consumer并开始线程  
        Thread threadProducer = new Thread(producer);  
        Thread threadConsumer = new Thread(consumer);  
        threadProducer.start();  
        threadConsumer.start();  
    }  
}  
```
Exchanger 类有另外一个版本的exchange方法
exchange(V data, long time, TimeUnit unit)
V是声明参数种类，例子中是List
此线程会休眠直到另一个线程到达并中断它，或者特定的时间过去了
TimeUnit类有多种常量，DAYS、HOURS、MICROSECONDS、MILLISECONDS、MINUTES、NANOSECONDS和SECONDS

原帖地址：
http://blog.csdn.net/howlaa/article/details/19853447
http://ifeve.com/thread-synchronization-utilities-8/