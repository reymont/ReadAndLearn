Java多线程系列——过期的suspend()挂起、resume()继续执行线程 - 郑州的文武 - 博客园 https://www.cnblogs.com/zhengbin/p/6505971.html


阅读目录
简述
实例
参考资料
简述
这两个操作就好比播放器的暂停和恢复。

但这两个 API 是过期的，也就是不建议使用的。

不推荐使用 suspend() 去挂起线程的原因，是因为 suspend() 在导致线程暂停的同时，并不会去释放任何锁资源。其他线程都无法访问被它占用的锁。直到对应的线程执行 resume() 方法后，被挂起的线程才能继续，从而其它被阻塞在这个锁的线程才可以继续执行。

但是，如果 resume() 操作出现在 suspend() 之前执行，那么线程将一直处于挂起状态，同时一直占用锁，这就产生了死锁。而且，对于被挂起的线程，它的线程状态居然还是 Runnable。

实例
复制代码+ View code
 1 import java.util.concurrent.locks.LockSupport;
 2 /**
 3  * Created by zhengbinMac on 2017/3/3.
 4  */
 5 public class SuspendResumeTest {
 6     public static Object object = new Object();
 7     static TestThread t1 = new TestThread("线程1");
 8     static TestThread t2 = new TestThread("线程2");
 9     public static class TestThread extends Thread{
10         public TestThread(String name) {
11             super.setName(name);
12         }
13         @Override
14         public void run() {
15             synchronized (object) {
16                 System.out.println(getName()+" 占用。。");
17                 Thread.currentThread().suspend();
18 //                LockSupport.park();
19             }
20         }
21     }
22     public static void main(String[] args) throws InterruptedException {
23         t1.start();
24         Thread.sleep(200);
25         t2.start();
26         t1.resume();
27 //        LockSupport.unpark(t1);
28 //        LockSupport.unpark(t2);
29         t2.resume();
30         t1.join();
31         t2.join();
32     }
33 }
复制代码
运行多次，可能出现下图结果：



代码执行流程，如下图所示：



此时，通过 jps 和 jstack 命令，来观察线程状态，如下图所示：



从输出结果来看，线程 t2 其实是被挂起的，但是从上图来看，它的线程状态却是 RUNNABLE，这会使我们误判当前系统状态。

参考资料
[1] 实战Java高并发程序设计, 2.2.5 - 挂起（suspend）和继续执行（resume）线程

[2] Java并发编程的艺术, 4.2.4 - 过期的suspend()、resume() 和 stop()