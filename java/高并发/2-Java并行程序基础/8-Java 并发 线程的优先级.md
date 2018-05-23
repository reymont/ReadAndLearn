Java 并发 线程的优先级 - ixenos - 博客园 https://www.cnblogs.com/ixenos/p/6216301.html


低优先级线程的执行时刻
 

1.在任意时刻，当有多个线程处于可运行状态时，运行系统总是挑选一个优先级最高的线程执行，只有当线程停止、退出或者由于某些原因不执行的时候，低优先级的线程才可能被执行

2.两个优先级相同的线程同时等待执行时，那么运行系统会以round-robin的方式选择一个线程执行（即轮询调度，以该算法所定的）（Java的优先级策略是抢占式调度！）

3.被选中的线程可因为一下原因退出，而给其他线程执行的机会：

　　1) 一个更高优先级的线程处于可运行状态（Runnable）

　　2）线程主动退出（yield），或它的run方法结束

　　3）在支持分时方式的系统上，分配给该线程的时间片结束

4.Java运行系统的线程调度算法是抢占式（preemptive）的，当更高优先级的线程出现并处于Runnable状态时，运行系统将选择高优先级的线程执行

5.例外地，当高优先级的线程处于阻塞状态且CPU处于空闲时，低优先级的线程也会被调度执行

复制代码
 1 public class PriorityExample{
 2     public static void main(Strinig[] args){
 3         Thread a = new PThread("A");
 4         Thread b = new PThread("B");
 5         a.setPriority(7); //设置优先级
 6         a.setPriority(1);
 7     }
 8 }
 9 
10 class PThread extends Thread{
11     public PThread(String n){
12         super(n);
13     }
14 
15     public void run(){
16         for(int i=0; i<5000000; i++){
17             if(i%5000000 == 0){
18                 System.out.print(getName());
19             }
20         }
21     }
22 }
复制代码
 

输出 AAAAAAAAABBBBBBBBB

 

 

利己线程
 

1.一般地，在线程中可以调用sleep方法，放弃当前线程对处理器的使用，从而使各个线程均有机会得到执行，但有时候线程可能不遵循这个规则！

复制代码
1 public void run(){
2     for(int i=0; i<5000000; i++){
3         if(i%5000000 == 0){
4             System.out.print(getName());
5         }
6     }
7 }
复制代码
 

2.for循环是一个紧密循环，一旦运行系统选择了有for循环体的线程执行，该线程就不会放弃对处理器的使用权，除非for循环自然终止或者该线程被一个有更高优先级的线程抢占，这样的线程称为利己线程

3.利己线程一般不引起问题，但有时会让其他的线程得到处理器使用权之前等待一段很长的时间

 

 

分时方式
 

1.为解决利己线程可能长时间占据CPU的问题，有些系统通过分时方式来限制利己线程的执行，如Windows2000或WindowsNT系统

2.在分时方式中，处理器的分配按照时间片来划分，对于那些具有相同最高优先级的多个线程，分时技术会交替地分配CPU时间片给他们执行，当时间片结束，即使该线程没有运行结束，也会让出CPU使用权

3.注释掉优先级设置后，输出变成了AAAAABBBBBAAABBB或者AABBAAAABBBBAABBA

复制代码
 1 public class PriorityExample{
 2     public static void main(Strinig[] args){
 3         Thread a = new PThread("A");
 4         Thread b = new PThread("B");
 5         //a.setPriority(7); //设置优先级
 6         //a.setPriority(1);
 7     }
 8 }
 9 
10 class PThread extends Thread{
11     public PThread(String n){
12         super(n);
13     }
14 
15     public void run(){
16         for(int i=0; i<5000000; i++){
17             if(i%5000000 == 0){
18                 System.out.print(getName());
19             }
20         }
21     }
22 } 
复制代码
 

而如果在另一个不支持分时技术的平台上运行程序，得到的输出结果可能是确定的！ AAAAAAAAABBBBBBBBB

 

4.Java运行系统不实现分时，分时是和平台相关的，而有的平台不支持分时，在编写Java多线程程序的时候，不能过分依赖分时技术来保证各个线程都有公平的执行机会！通常应编写那种可以主动放弃处理器使用权的程序，同时一个线程也可以调用yield方法主动放弃对处理器的使用权

　　注意：使用yield只能给同优先级的线程提供执行机会，如果没有同优先级的线程处于可运行状态，yield方法将被忽略！

 