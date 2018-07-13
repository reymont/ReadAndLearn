

Java线程中yield与join方法的区别 - ImportNew http://www.importnew.com/14958.html


本文由 ImportNew - Calarence 翻译自 How To Do In Java。欢迎加入翻译小组。转载请见文末要求。
长期以来，多线程问题颇为受到面试官的青睐。虽然我个人认为我们当中很少有人能真正获得机会开发复杂的多线程应用(在过去的七年中，我得到了一个机会)，但是理解多线程对增加你的信心很有用。之前，我讨论了一个wait()和sleep()方法区别的问题，这一次，我将会讨论join()和yield()方法的区别。坦白的说，实际上我并没有用过其中任何一个方法，所以，如果你感觉有不恰当的地方，请提出讨论。

Java线程调度的一点背景

在各种各样的线程中，Java虚拟机必须实现一个有优先权的、基于优先级的调度程序。这意味着Java程序中的每一个线程被分配到一定的优先权，使用定义好的范围内的一个正整数表示。优先级可以被开发者改变。即使线程已经运行了一定时间，Java虚拟机也不会改变其优先级

优先级的值很重要，因为Java虚拟机和下层的操作系统之间的约定是操作系统必须选择有最高优先权的Java线程运行。所以我们说Java实现了一个基于优先权的调度程序。该调度程序使用一种有优先权的方式实现，这意味着当一个有更高优先权的线程到来时，无论低优先级的线程是否在运行，都会中断(抢占)它。这个约定对于操作系统来说并不总是这样，这意味着操作系统有时可能会选择运行一个更低优先级的线程。(我憎恨多线程的这一点，因为这不能保证任何事情)

注意Java并不限定线程是以时间片运行，但是大多数操作系统却有这样的要求。在术语中经常引起混淆：抢占经常与时间片混淆。事实上，抢占意味着只有拥有高优先级的线程可以优先于低优先级的线程执行，但是当线程拥有相同优先级的时候，他们不能相互抢占。它们通常受时间片管制，但这并不是Java的要求。

理解线程的优先权

接下来，理解线程优先级是多线程学习很重要的一步，尤其是了解yield()函数的工作过程。

记住当线程的优先级没有指定时，所有线程都携带普通优先级。
优先级可以用从1到10的范围指定。10表示最高优先级，1表示最低优先级，5是普通优先级。
记住优先级最高的线程在执行时被给予优先。但是不能保证线程在启动时就进入运行状态。
与在线程池中等待运行机会的线程相比，当前正在运行的线程可能总是拥有更高的优先级。
由调度程序决定哪一个线程被执行。
t.setPriority()用来设定线程的优先级。
记住在线程开始方法被调用之前，线程的优先级应该被设定。
你可以使用常量，如MIN_PRIORITY,MAX_PRIORITY，NORM_PRIORITY来设定优先级
现在，当我们对线程调度和线程优先级有一定理解后，让我们进入主题。

yield()方法

理论上，yield意味着放手，放弃，投降。一个调用yield()方法的线程告诉虚拟机它乐意让其他线程占用自己的位置。这表明该线程没有在做一些紧急的事情。注意，这仅是一个暗示，并不能保证不会产生任何影响。

在Thread.java中yield()定义如下：

1
2
3
4
5
6
7
/**
  * A hint to the scheduler that the current thread is willing to yield its current use of a processor. The scheduler is free to ignore
  * this hint. Yield is a heuristic attempt to improve relative progression between threads that would otherwise over-utilize a CPU.
  * Its use should be combined with detailed profiling and benchmarking to ensure that it actually has the desired effect.
  */
 
public static native void yield();
让我们列举一下关于以上定义重要的几点：

Yield是一个静态的原生(native)方法
Yield告诉当前正在执行的线程把运行机会交给线程池中拥有相同优先级的线程。
Yield不能保证使得当前正在运行的线程迅速转换到可运行的状态
它仅能使一个线程从运行状态转到可运行状态，而不是等待或阻塞状态
yield()方法使用示例

在下面的示例程序中，我随意的创建了名为生产者和消费者的两个线程。生产者设定为最小优先级，消费者设定为最高优先级。在Thread.yield()注释和非注释的情况下我将分别运行该程序。没有调用yield()方法时，虽然输出有时改变，但是通常消费者行先打印出来，然后事生产者。

调用yield()方法时，两个线程依次打印，然后将执行机会交给对方，一直这样进行下去。

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
package test.core.threads;
 
public class YieldExample
{
   public static void main(String[] args)
   {
      Thread producer = new Producer();
      Thread consumer = new Consumer();
 
      producer.setPriority(Thread.MIN_PRIORITY); //Min Priority
      consumer.setPriority(Thread.MAX_PRIORITY); //Max Priority
 
      producer.start();
      consumer.start();
   }
}
 
class Producer extends Thread
{
   public void run()
   {
      for (int i = 0; i < 5; i++)
      {
         System.out.println("I am Producer : Produced Item " + i);
         Thread.yield();
      }
   }
}
 
class Consumer extends Thread
{
   public void run()
   {
      for (int i = 0; i < 5; i++)
      {
         System.out.println("I am Consumer : Consumed Item " + i);
         Thread.yield();
      }
   }
}
上述程序在没有调用yield()方法情况下的输出：
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
I am Consumer : Consumed Item 0
 I am Consumer : Consumed Item 1
 I am Consumer : Consumed Item 2
 I am Consumer : Consumed Item 3
 I am Consumer : Consumed Item 4
 I am Producer : Produced Item 0
 I am Producer : Produced Item 1
 I am Producer : Produced Item 2
 I am Producer : Produced Item 3
 I am Producer : Produced Item 4
上述程序在调用yield()方法情况下的输出：
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
I am Producer : Produced Item 0
 I am Consumer : Consumed Item 0
 I am Producer : Produced Item 1
 I am Consumer : Consumed Item 1
 I am Producer : Produced Item 2
 I am Consumer : Consumed Item 2
 I am Producer : Produced Item 3
 I am Consumer : Consumed Item 3
 I am Producer : Produced Item 4
 I am Consumer : Consumed Item 4
join()方法

线程实例的方法join()方法可以使得一个线程在另一个线程结束后再执行。如果join()方法在一个线程实例上调用，当前运行着的线程将阻塞直到这个线程实例完成了执行。

1
2
3
//Waits for this thread to die.
 
public final void join() throws InterruptedException
在join()方法内设定超时，使得join()方法的影响在特定超时后无效。当超时时，主方法和任务线程申请运行的时候是平等的。然而，当涉及sleep时，join()方法依靠操作系统计时，所以你不应该假定join()方法将会等待你指定的时间。

像sleep,join通过抛出InterruptedException对中断做出回应。

join()方法使用示例

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
package test.core.threads;
 
public class JoinExample
{
   public static void main(String[] args) throws InterruptedException
   {
      Thread t = new Thread(new Runnable()
         {
            public void run()
            {
               System.out.println("First task started");
               System.out.println("Sleeping for 2 seconds");
               try
               {
                  Thread.sleep(2000);
               } catch (InterruptedException e)
               {
                  e.printStackTrace();
               }
               System.out.println("First task completed");
            }
         });
      Thread t1 = new Thread(new Runnable()
         {
            public void run()
            {
               System.out.println("Second task completed");
            }
         });
      t.start(); // Line 15
      t.join(); // Line 16
      t1.start();
   }
}
 
Output:
 
First task started
Sleeping for 2 seconds
First task completed
Second task completed
这是一些很小却很重要的概念。在评论部分让我知道你的想法。

原文链接： How To Do In Java 翻译： ImportNew.com - Calarence
译文链接： http://www.importnew.com/14958.html
[ 转载请保留原文出处、译者和译文链接。]