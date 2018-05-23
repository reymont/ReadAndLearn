Java中synchronized的用法 - ImportNew http://www.importnew.com/21866.html

原文出处： luoweifu
《编程思想之多线程与多进程(1)》一文详细讲述了线程、进程的关系及在操作系统中的表现，这是多线程学习必须了解的基础。本文将接着讲一下Java线程同步中的一个重要的概念synchronized.

synchronized是Java中的关键字，是一种同步锁。它修饰的对象有以下几种：
1. 修饰一个代码块，被修饰的代码块称为同步语句块，其作用的范围是大括号{}括起来的代码，作用的对象是调用这个代码块的对象；
2. 修饰一个方法，被修饰的方法称为同步方法，其作用的范围是整个方法，作用的对象是调用这个方法的对象；
3. 修改一个静态的方法，其作用的范围是整个静态方法，作用的对象是这个类的所有对象；
4. 修改一个类，其作用的范围是synchronized后面括号括起来的部分，作用主的对象是这个类的所有对象。

修饰一个代码块

一个线程访问一个对象中的synchronized(this)同步代码块时，其他试图访问该对象的线程将被阻塞。我们看下面一个例子：
【Demo1】：synchronized的用法

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
/**
 * 同步线程
 */
class SyncThread implements Runnable {
   private static int count;
 
   public SyncThread() {
      count = 0;
   }
 
   public  void run() {
      synchronized(this) {
         for (int i = 0; i < 5; i++) {
            try {
               System.out.println(Thread.currentThread().getName() + ":" + (count++));
               Thread.sleep(100);
            } catch (InterruptedException e) {
               e.printStackTrace();
            }
         }
      }
   }
 
   public int getCount() {
      return count;
   }
}
SyncThread的调用：

1
2
3
4
5
SyncThread syncThread = new SyncThread();
Thread thread1 = new Thread(syncThread, "SyncThread1");
Thread thread2 = new Thread(syncThread, "SyncThread2");
thread1.start();
thread2.start();
结果如下：

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
SyncThread1:0
SyncThread1:1
SyncThread1:2
SyncThread1:3
SyncThread1:4
SyncThread2:5
SyncThread2:6
SyncThread2:7
SyncThread2:8
SyncThread2:9*
当两个并发线程(thread1和thread2)访问同一个对象(syncThread)中的synchronized代码块时，在同一时刻只能有一个线程得到执行，另一个线程受阻塞，必须等待当前线程执行完这个代码块以后才能执行该代码块。Thread1和thread2是互斥的，因为在执行synchronized代码块时会锁定当前的对象，只有执行完该代码块才能释放该对象锁，下一个线程才能执行并锁定该对象。
我们再把SyncThread的调用稍微改一下：

1
2
3
4
Thread thread1 = new Thread(new SyncThread(), "SyncThread1");
Thread thread2 = new Thread(new SyncThread(), "SyncThread2");
thread1.start();
thread2.start();
结果如下：

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
SyncThread1:0
SyncThread2:1
SyncThread1:2
SyncThread2:3
SyncThread1:4
SyncThread2:5
SyncThread2:6
SyncThread1:7
SyncThread1:8
SyncThread2:9
不是说一个线程执行synchronized代码块时其它的线程受阻塞吗？为什么上面的例子中thread1和thread2同时在执行。这是因为synchronized只锁定对象，每个对象只有一个锁（lock）与之相关联，而上面的代码等同于下面这段代码：

1
2
3
4
5
6
SyncThread syncThread1 = new SyncThread();
SyncThread syncThread2 = new SyncThread();
Thread thread1 = new Thread(syncThread1, "SyncThread1");
Thread thread2 = new Thread(syncThread2, "SyncThread2");
thread1.start();
thread2.start();
这时创建了两个SyncThread的对象syncThread1和syncThread2，线程thread1执行的是syncThread1对象中的synchronized代码(run)，而线程thread2执行的是syncThread2对象中的synchronized代码(run)；我们知道synchronized锁定的是对象，这时会有两把锁分别锁定syncThread1对象和syncThread2对象，而这两把锁是互不干扰的，不形成互斥，所以两个线程可以同时执行。

2.当一个线程访问对象的一个synchronized(this)同步代码块时，另一个线程仍然可以访问该对象中的非synchronized(this)同步代码块。
【Demo2】：多个线程访问synchronized和非synchronized代码块

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
31
32
33
34
35
36
37
38
39
40
41
class Counter implements Runnable{
   private int count;
 
   public Counter() {
      count = 0;
   }
 
   public void countAdd() {
      synchronized(this) {
         for (int i = 0; i < 5; i ++) {
            try {
               System.out.println(Thread.currentThread().getName() + ":" + (count++));
               Thread.sleep(100);
            } catch (InterruptedException e) {
               e.printStackTrace();
            }
         }
      }
   }
 
   //非synchronized代码块，未对count进行读写操作，所以可以不用synchronized
   public void printCount() {
      for (int i = 0; i < 5; i ++) {
         try {
            System.out.println(Thread.currentThread().getName() + " count:" + count);
            Thread.sleep(100);
         } catch (InterruptedException e) {
            e.printStackTrace();
         }
      }
   }
 
   public void run() {
      String threadName = Thread.currentThread().getName();
      if (threadName.equals("A")) {
         countAdd();
      } else if (threadName.equals("B")) {
         printCount();
      }
   }
}
调用代码:

1
2
3
4
5
Counter counter = new Counter();
Thread thread1 = new Thread(counter, "A");
Thread thread2 = new Thread(counter, "B");
thread1.start();
thread2.start();
结果如下：

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
A:0
B count:1
A:1
B count:2
A:2
B count:3
A:3
B count:4
A:4
B count:5
上面代码中countAdd是一个synchronized的，printCount是非synchronized的。从上面的结果中可以看出一个线程访问一个对象的synchronized代码块时，别的线程可以访问该对象的非synchronized代码块而不受阻塞。

指定要给某个对象加锁
【Demo3】:指定要给某个对象加锁

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
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
/**
 * 银行账户类
 */
class Account {
   String name;
   float amount;
 
   public Account(String name, float amount) {
      this.name = name;
      this.amount = amount;
   }
   //存钱
   public  void deposit(float amt) {
      amount += amt;
      try {
         Thread.sleep(100);
      } catch (InterruptedException e) {
         e.printStackTrace();
      }
   }
   //取钱
   public  void withdraw(float amt) {
      amount -= amt;
      try {
         Thread.sleep(100);
      } catch (InterruptedException e) {
         e.printStackTrace();
      }
   }
 
   public float getBalance() {
      return amount;
   }
}
 
/**
 * 账户操作类
 */
class AccountOperator implements Runnable{
   private Account account;
   public AccountOperator(Account account) {
      this.account = account;
   }
 
   public void run() {
      synchronized (account) {
         account.deposit(500);
         account.withdraw(500);
         System.out.println(Thread.currentThread().getName() + ":" + account.getBalance());
      }
   }
}
调用代码:

1
2
3
4
5
6
7
8
9
Account account = new Account("zhang san", 10000.0f);
AccountOperator accountOperator = new AccountOperator(account);
 
final int THREAD_NUM = 5;
Thread threads[] = new Thread[THREAD_NUM];
for (int i = 0; i < THREAD_NUM; i ++) {
   threads[i] = new Thread(accountOperator, "Thread" + i);
   threads[i].start();
}
结果如下：

1
2
3
4
5
Thread3:10000.0
Thread2:10000.0
Thread1:10000.0
Thread4:10000.0
Thread0:10000.0
在AccountOperator 类中的run方法里，我们用synchronized 给account对象加了锁。这时，当一个线程访问account对象时，其他试图访问account对象的线程将会阻塞，直到该线程访问account对象结束。也就是说谁拿到那个锁谁就可以运行它所控制的那段代码。
当有一个明确的对象作为锁时，就可以用类似下面这样的方式写程序。

1
2
3
4
5
6
7
8
public void method3(SomeObject obj)
{
   //obj 锁定的对象
   synchronized(obj)
   {
      // todo
   }
}
当没有明确的对象作为锁，只是想让一段代码同步时，可以创建一个特殊的对象来充当锁：

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
class Test implements Runnable
{
   private byte[] lock = new byte[0];  // 特殊的instance变量
   public void method()
   {
      synchronized(lock) {
         // todo 同步代码块
      }
   }
 
   public void run() {
 
   }
}
说明：零长度的byte数组对象创建起来将比任何对象都经济――查看编译后的字节码：生成零长度的byte[]对象只需3条操作码，而Object lock = new Object()则需要7行操作码。

修饰一个方法

Synchronized修饰一个方法很简单，就是在方法的前面加synchronized，public synchronized void method(){//todo}; synchronized修饰方法和修饰一个代码块类似，只是作用范围不一样，修饰代码块是大括号括起来的范围，而修饰方法范围是整个函数。如将【Demo1】中的run方法改成如下的方式，实现的效果一样。

*【Demo4】：synchronized修饰一个方法

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
public synchronized void run() {
   for (int i = 0; i < 5; i ++) {
      try {
         System.out.println(Thread.currentThread().getName() + ":" + (count++));
         Thread.sleep(100);
      } catch (InterruptedException e) {
         e.printStackTrace();
      }
   }
}
Synchronized作用于整个方法的写法。
写法一：

1
2
3
4
public synchronized void method()
{
   // todo
}
写法二：

1
2
3
4
5
6
public void method()
{
   synchronized(this) {
      // todo
   }
}
写法一修饰的是一个方法，写法二修饰的是一个代码块，但写法一与写法二是等价的，都是锁定了整个方法时的内容。

在用synchronized修饰方法时要注意以下几点：
1. synchronized关键字不能继承。
虽然可以使用synchronized来定义方法，但synchronized并不属于方法定义的一部分，因此，synchronized关键字不能被继承。如果在父类中的某个方法使用了synchronized关键字，而在子类中覆盖了这个方法，在子类中的这个方法默认情况下并不是同步的，而必须显式地在子类的这个方法中加上synchronized关键字才可以。当然，还可以在子类方法中调用父类中相应的方法，这样虽然子类中的方法不是同步的，但子类调用了父类的同步方法，因此，子类的方法也就相当于同步了。这两种方式的例子代码如下：
在子类方法中加上synchronized关键字

1
2
3
4
5
6
class Parent {
   public synchronized void method() { }
}
class Child extends Parent {
   public synchronized void method() { }
}
在子类方法中调用父类的同步方法

1
2
3
4
5
6
class Parent {
   public synchronized void method() {   }
}
class Child extends Parent {
   public void method() { super.method();   }
}
在定义接口方法时不能使用synchronized关键字。
构造方法不能使用synchronized关键字，但可以使用synchronized代码块来进行同步。
修饰一个静态的方法

Synchronized也可修饰一个静态方法，用法如下：

1
2
3
public synchronized static void method() {
   // todo
}
我们知道静态方法是属于类的而不属于对象的。同样的，synchronized修饰的静态方法锁定的是这个类的所有对象。我们对Demo1进行一些修改如下：

【Demo5】：synchronized修饰静态方法

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
/**
 * 同步线程
 */
class SyncThread implements Runnable {
   private static int count;
 
   public SyncThread() {
      count = 0;
   }
 
   public synchronized static void method() {
      for (int i = 0; i < 5; i ++) {
         try {
            System.out.println(Thread.currentThread().getName() + ":" + (count++));
            Thread.sleep(100);
         } catch (InterruptedException e) {
            e.printStackTrace();
         }
      }
   }
 
   public synchronized void run() {
      method();
   }
}
调用代码:

1
2
3
4
5
6
SyncThread syncThread1 = new SyncThread();
SyncThread syncThread2 = new SyncThread();
Thread thread1 = new Thread(syncThread1, "SyncThread1");
Thread thread2 = new Thread(syncThread2, "SyncThread2");
thread1.start();
thread2.start();
结果如下：

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
SyncThread1:0
SyncThread1:1
SyncThread1:2
SyncThread1:3
SyncThread1:4
SyncThread2:5
SyncThread2:6
SyncThread2:7
SyncThread2:8
SyncThread2:9
syncThread1和syncThread2是SyncThread的两个对象，但在thread1和thread2并发执行时却保持了线程同步。这是因为run中调用了静态方法method，而静态方法是属于类的，所以syncThread1和syncThread2相当于用了同一把锁。这与Demo1是不同的。

修饰一个类

Synchronized还可作用于一个类，用法如下：

1
2
3
4
5
6
7
class ClassName {
   public void method() {
      synchronized(ClassName.class) {
         // todo
      }
   }
}
我们把Demo5再作一些修改。
【Demo6】:修饰一个类

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
/**
 * 同步线程
 */
class SyncThread implements Runnable {
   private static int count;
 
   public SyncThread() {
      count = 0;
   }
 
   public static void method() {
      synchronized(SyncThread.class) {
         for (int i = 0; i < 5; i ++) {
            try {
               System.out.println(Thread.currentThread().getName() + ":" + (count++));
               Thread.sleep(100);
            } catch (InterruptedException e) {
               e.printStackTrace();
            }
         }
      }
   }
 
   public synchronized void run() {
      method();
   }
}
其效果和【Demo5】是一样的，synchronized作用于一个类T时，是给这个类T加锁，T的所有对象用的是同一把锁。

总结：

A. 无论synchronized关键字加在方法上还是对象上，如果它作用的对象是非静态的，则它取得的锁是对象；如果synchronized作用的对象是一个静态方法或一个类，则它取得的锁是对类，该类所有的对象同一把锁。
B. 每个对象只有一个锁（lock）与之相关联，谁拿到这个锁谁就可以运行它所控制的那段代码。
C. 实现同步是要很大的系统开销作为代价的，甚至可能造成死锁，所以尽量避免无谓的同步控制。

参考资料：
http://blog.csdn.net/chenguang79/article/details/677720
http://developer.51cto.com/art/200906/132354.htm

