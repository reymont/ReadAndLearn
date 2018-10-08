

[改善Java代码]不使用stop方法停止线程 - SummerChill - 博客园 https://www.cnblogs.com/DreamDrive/p/5623804.html


线程启动完毕后,在运行可能需要终止,Java提供的终止方法只有一个stop,但是不建议使用此方法,因为它有以下三个问题:

(1)stop方法是过时的
从Java编码规则来说,已经过时的方式不建议采用.
(2)stop方法会导致代码逻辑不完整
stop方法是一种"恶意" 的中断,一旦执行stop方法,即终止当前正在运行的线程,不管线程逻辑是否完整,这是非常危险的.
(3)stop方法会破坏原子逻辑

看如下代码:

```java
 1 public class Client {
 2     public static void main(String[] args) throws Exception {
 3         // 子线程
 4         Thread thread = new Thread() {
 5             @Override
 6             public void run() {
 7                 try {
 8                     // 该线程休眠1秒
 9                     Thread.sleep(1000);
10                 } catch (InterruptedException e) {
11                     //异常处理
12                 }
13                 System.out.println("此处代码不会执行");
14             }
15         };
16         // 启动线程
17         thread.start();
18         // 主线程休眠0.1秒
19         Thread.sleep(100);
20         // 子线程停止
21         thread.stop();
22 
23     }
24 }
```
 

这段代码的逻辑,子线程是一个匿名内部类,它的run方法在执行时会休眠1秒钟,然后再执行后续的逻辑,而主线程则是休眠0.1秒后终止子线程的运行,也就是说,JVM在执行thread.stop()时,子线程还在执行sleep(1000),此时stop方法会清除栈内信息,结束该线程,这也导致了run方法的逻辑不完整,输出语句println代表的是一段逻辑,可能非常重要,比如子线程的主逻辑,资源回收,情景初始化等等,但是因为stop线程了,这些就都不再执行了,于是就产生了业务逻辑不完整的情况.

这是极度危险的,因为我们不知道子线程会在什么时候停止,stop连基本的逻辑完整性都无法保证,而且此种操作也是非常隐蔽的,子线程执行到何处会被关闭很难定位,这为以后的维护带来了很多的麻烦. 

## (3)stop方法会破坏原子逻辑

多线程为了解决共享资源抢占的问题,使用了锁的概念,避免资源不同步,但是正是因为此原因,stop方法却会带来更大的麻烦,它会丢弃所有的锁,导致原子逻辑受损.例如 有这样一段程序:

```java
 1 public class Client {
 2     public static void main(String[] args) {
 3         MultiThread t = new MultiThread();
 4         Thread t1 = new Thread(t);
 5         // 启动t1线程
 6         t1.start();
 7         for (int i = 0; i < 5; i++) {
 8             new Thread(t).start();
 9         }
10         // 停止t1线程
11         t1.stop();
12     }
13 }
14 
15 class MultiThread implements Runnable {
16     int a = 0;
17 
18     @Override
19     public void run() {
20         // 同步代码块，保证原子操作
21         synchronized ("") {
22             // 自增
23             a++;
24             try {
25                 // 线程休眠0.1秒
26                 Thread.sleep(100);
27             } catch (InterruptedException e) {
28                 e.printStackTrace();
29             }
30             // 自减
31             a--;
32             String tn = Thread.currentThread().getName();
33             System.out.println(tn + ":a =" + a);
34         }
35     }
36 }
```
 

 MultiThread实现了Runnable接口,具备多线程的能力,run方法中加入了synchronized代码块,表示内部是原子逻辑,a的值会先增加后减少,按照synchronized的规则,无论启动多少个线程,打印出来的结果都应该是a=0,

但是如果有一个正在执行的线程被stop,就会破坏这种原子逻辑.(上面main方法中代码)
首先说明的是所有线程共享了 一个MultThread的实例变量t,其次由于在run方法中加入了同步代码块,所以只能有一个线程进入到synchronized块中.

此段代码的执行顺序如下:

1)线程t1启动,并执行run方法,由于没有其他线程同步代码块的锁,所以t1线程执行自加后执行到sleep方法开始休眠,此时a=1.

2)JVM又启动了5个线程,也同时运行run方法,由于synchronized关键字的阻塞作用,这5个线程不能执行自增和自减操作,等待t1线程释放线程锁.

3)主线程执行了t1.stop方法,终止了t1线程,注意由于a变量是线程共享的,所以其他5个线程获得的a变量也是1.

4)其他5个线程获得CPU的执行机会,打印出a的值.

结果是:

Thread-5:a =1
Thread-4:a =1
Thread-3:a =1
Thread-2:a =1
Thread-1:a =1
 

原本期望synchronized同步代码块中的逻辑都是原子逻辑,不受外界线程的干扰,但是结果却出现原子逻辑被破坏的情况,这也是stop方法被废弃的一个重要原因:破坏了原子逻辑.

既然终止一个线程不能用stop方法,那怎样才能终止一个正在运行的线程呢?

使用自定义的标志位决定线程的执行情况,代码如下:

复制代码
 1 import java.util.Timer;
 2 import java.util.TimerTask;
 3 
 4 public class Client {
 5     public static void main(String[] args) throws InterruptedException {
 6         final SafeStopThread sst = new SafeStopThread();
 7         sst.start();
 8         //0.5秒后线程停止执行
 9         new Timer(true).schedule(new TimerTask() {
10             public void run() {
11                 sst.terminate();
12             }
13         }, 500);
14     }
15 
16 }
17 
18 class SafeStopThread extends Thread {
19     //此变量必须加上volatile
20     private volatile boolean stop = false;
21     @Override
22     public void run() {
23         //判断线程体是否运行
24         while (stop) {
25             // Do Something
26             System.out.println("Stop");
27         }
28     }
29     //线程终止
30     public void terminate() {
31         stop = true;
32     }
33 }
复制代码
 

在线程主题中判断是否需要停止运行,即可保证线程体的逻辑完整性而且也不会破坏原值逻辑.

Thread还提供了一个interrupt中断线程的方法,这个不是过时的方法,是否可以使用这个中断线程?

很明确的说,interrupt不能终止一个正在执行着的线程,它只是修改中断标志位而已.例如:

复制代码
 1 public class Client {
 2     public static void main(String[] args) {
 3         Thread t1 = new Thread() {
 4             public void run() {
 5                 //线程一直运行
 6                 while (true) {
 7                     System.out.println("Running……");
 8                 }
 9             }
10         };
11         // 启动t1线程
12         t1.start();
13         System.out.println(t1.isInterrupted());//false
14         // 中断t1线程
15         t1.interrupt();
16         System.out.println(t1.isInterrupted());//true
17     }
18 }
复制代码
 

执行这段代码,会一直有Running在输出,永远不会停止,执行了interrupt没有任何的变化,那是因为interrupt方法不能终止一个线程状态,它只会改变中断标志位.

在t1.interrupt()前后加上了t1.isInterrupted()会发现分别输出的是false和true.

如果需要终止该线程,还需要执行进行判断,例如我们可以使用interrupt编写出更加简洁,安全的终止线程的代码:

复制代码
 1 import java.util.Timer;
 2 import java.util.TimerTask;
 3 
 4 public class Client {
 5     public static void main(String[] args) throws InterruptedException {
 6         final SafeStopThread sst = new SafeStopThread();
 7         sst.start();
 8         //0.5秒后线程停止执行
 9         new Timer(true).schedule(new TimerTask() {
10             public void run() {
11                 sst.interrupt();
12             }
13         }, 500);
14     }
15 
16 }
17 
18 class SafeStopThread extends Thread {
19     @Override
20     public void run() {
21         //判断线程体是否运行
22         while (!isInterrupted()) {
23             // Do Something
24         }
25     }    
26 }
复制代码
 

总之,如果期望终止一个正在运行的线程,则不能使用已经过时的stop方法,需要执行编码实现.这样保证原子逻辑不被破坏,代码逻辑不会出现异常.

当然还可以使用线程池,比如ThreadPoolExecutor类,那么可以通过shutdown方法逐步关闭线程池中的线程,它采用的是比较温和,安全的关闭线程方法,完全不会产生类似stop方法的弊端.

 

作者：SummerChill 
出处：http://www.cnblogs.com/DreamDrive/ 
本博客为自己总结亦或在网上发现的技术博文的转载。 如果文中有什么错误，欢迎指出。以免更多的人被误导。 
