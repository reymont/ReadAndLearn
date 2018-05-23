

理解java线程的中断(interrupt) - CSDN博客 https://blog.csdn.net/canot/article/details/51087772

一个线程在未正常结束之前, 被强制终止是很危险的事情. 因为它可能带来完全预料不到的严重后果比如会带着自己所持有的锁而永远的休眠，迟迟不归还锁等。 所以你看到Thread.suspend, Thread.stop等方法都被Deprecated了

那么不能直接把一个线程搞挂掉, 但有时候又有必要让一个线程死掉, 或者让它结束某种等待的状态 该怎么办呢?一个比较优雅而安全的做法是:使用等待/通知机制或者给那个线程一个中断信号, 让它自己决定该怎么办。

等待/通过机制在另一篇博客中详细的介绍了。这里我们理解线程中断的使用场景和使用时的注意事项,最后使用Demo来理解。

中断线程的使用场景:

在某个子线程中为了等待一些特定条件的到来, 你调用了Thread.sleep(10000), 预期线程睡10秒之后自己醒来, 但是如果这个特定条件提前到来的话, 来通知一个处于Sleep的线程。又比如说.线程通过调用子线程的join方法阻塞自己以等待子线程结束, 但是子线程运行过程中发现自己没办法在短时间内结束, 于是它需要想办法告诉主线程别等我了. 这些情况下, 就需要中断.

断是通过调用Thread.interrupt()方法来做的. 这个方法通过修改了被调用线程的中断状态来告知那个线程, 说它被中断了. 对于非阻塞中的线程, 只是改变了中断状态, 即Thread.isInterrupted()将返回true; 对于可取消的阻塞状态中的线程, 比如等待在这些函数上的线程, Thread.sleep(), Object.wait(), Thread.join(), 这个线程收到中断信号后, 会抛出InterruptedException, 同时会把中断状态置回为true.但调用Thread.interrupted()会对中断状态进行复位。

对非阻塞中的线程中断的Demo:
```java
public class Thread3 extends Thread{
    public void run(){  
        while(true){  
            if(Thread.currentThread().isInterrupted()){  
                System.out.println("Someone interrupted me.");  
            }  
            else{  
                System.out.println("Thread is Going...");  
            }
        }  
    }  

    public static void main(String[] args) throws InterruptedException {  
        Thread3 t = new Thread3();  
        t.start();  
        Thread.sleep(3000);  
        t.interrupt();  
    }  
}  
```
分析如上程序的结果: 
在main线程sleep的过程中由于t线程中isInterrupted()为false所以不断的输出”Thread is going”。当调用t线程的interrupt()后t线程中isInterrupted()为true。此时会输出Someone interrupted me.而且线程并不会因为中断信号而停止运行。因为它只是被修改一个中断信号而已。

首先我们看看interrupt究竟在干什么。 
当我们调用t.interrput()的时候，线程t的中断状态(interrupted status) 会被置位。我们可以通过Thread.currentThread().isInterrupted() 来检查这个布尔型的中断状态。

在Core Java中有这样一句话：”没有任何语言方面的需求要求一个被中断的程序应该终止。中断一个线程只是为了引起该线程的注意，被中断线程可以决定如何应对中断 “。好好体会这句话的含义，看看下面的代码：

```java
    //Interrupted的经典使用代码    
    public void run(){    
            try{    
                 ....    
                 while(!Thread.currentThread().isInterrupted()&& more work to do){    
                        // do more work;    
                 }    
            }catch(InterruptedException e){    
                        // thread was interrupted during sleep or wait    
            }    
            finally{    
                       // cleanup, if required    
            }    
    }    
```
很显然，在上面代码中，while循环有一个决定因素就是需要不停的检查自己的中断状态。当外部线程调用该线程的interrupt 时，使得中断状态置位即变为true。这是该线程将终止循环，不在执行循环中的do more work了。

这说明: interrupt中断的是线程的某一部分业务逻辑，前提是线程需要检查自己的中断状态(isInterrupted())。

但是当线程被阻塞的时候，比如被Object.wait, Thread.join和Thread.sleep三种方法之一阻塞时。调用它的interrput()方法。可想而知，没有占用CPU运行的线程是不可能给自己的中断状态置位的。这就会产生一个InterruptedException异常。

    /*  
    * 如果线程被阻塞，它便不能核查共享变量，也就不能停止。这在许多情况下会发生，例如调用 
    * Object.wait()、ServerSocket.accept()和DatagramSocket.receive()时，他们都可能永 
    * 久的阻塞线程。即使发生超时，在超时期满之前持续等待也是不可行和不适当的，所以，要使 
    * 用某种机制使得线程更早地退出被阻塞的状态。很不幸运，不存在这样一种机制对所有的情况 
    * 都适用，但是，根据情况不同却可以使用特定的技术。使用Thread.interrupt()中断线程正 
    * 如Example1中所描述的，Thread.interrupt()方法不会中断一个正在运行的线程。这一方法 
    * 实际上完成的是，在线程受到阻塞时抛出一个中断信号，这样线程就得以退出阻塞的状态。更 
    * 确切的说，如果线程被Object.wait, Thread.join和Thread.sleep三种方法之一阻塞，那么， 
    * 它将接收到一个中断异常（InterruptedException），从而提早地终结被阻塞状态。因此， 
    * 如果线程被上述几种方法阻塞，正确的停止线程方式是设置共享变量，并调用interrupt()（注 
    * 意变量应该先设置）。如果线程没有被阻塞，这时调用interrupt()将不起作用；否则，线程就 
    * 将得到异常（该线程必须事先预备好处理此状况），接着逃离阻塞状态。在任何一种情况中，最 
    * 后线程都将检查共享变量然后再停止。下面示例描述了该技术。 
    * */  
    package Concurrency.Interrupt;  

    class Example3 extends Thread {  

    volatile boolean stop = false;  

    public static void main(String args[]) throws Exception {  
    Example3 thread = new Example3();  

    System.out.println("Starting thread...");  
    thread.start();  

    Thread.sleep(3000);  

    System.out.println("Asking thread to stop...");  

    /* 
    * 如果线程阻塞，将不会检查此变量,调用interrupt之后，线程就可以尽早的终结被阻  
    * 塞状 态，能够检查这一变量。 
    * */  
    thread.stop = true;  

    /* 
    * 这一方法实际上完成的是，在线程受到阻塞时抛出一个中断信号，这样线程就得以退 
    * 出阻 塞的状态 
    * */  
    thread.interrupt();  

    Thread.sleep(3000);  
    System.out.println("Stopping application...");  
    System.exit(0);  
    }  

    public void run() {  
    while (!stop) {  
    System.out.println("Thread running...");  
    try {  
    Thread.sleep(2000);  
    } catch (InterruptedException e) {  
    // 接收到一个中断异常（InterruptedException），从而提早地终结被阻塞状态  
    System.out.println("Thread interrupted...");  
    }  
    }  

    System.out.println("Thread exiting under request...");  
    }  
    }  
    /* 
    * 把握几个重点：stop变量、run方法中的sleep()、interrupt()、InterruptedException。串接起 
    * 来就是这个意思：当我们在run方法中调用sleep（或其他阻塞线程的方法）时，如果线程阻塞的 
    * 时间过长，比如10s，那在这10s内，线程阻塞，run方法不被执行，但是如果在这10s内，stop被 
    * 设置成true，表明要终止这个线程，但是，现在线程是阻塞的，它的run方法不能执行，自然也就 
    * 不能检查stop，所 以线程不能终止，这个时候，我们就可以用interrupt()方法了：我们在 
    * thread.stop = true;语句后调用thread.interrupt()方法， 该方法将在线程阻塞时抛出一个中断 
    * 信号，该信号将被catch语句捕获到，一旦捕获到这个信号，线程就提前终结自己的阻塞状态，这 
    * 样，它就能够 再次运行run 方法了，然后检查到stop = true，while循环就不会再被执行，在执 
    * 行了while后面的清理工作之后，run方法执行完 毕，线程终止。 
    * */  

当代码调用中须要抛出一个InterruptedException, 你可以选择把中断状态复位, 也可以选择向外抛出InterruptedException, 由外层的调用者来决定. 
不是所有的阻塞方法收到中断后都可以取消阻塞状态, 输入和输出流类会阻塞等待 I/O 完成，但是它们不抛出 InterruptedException，而且在被中断的情况下也不会退出阻塞状态. 
尝试获取一个内部锁的操作（进入一个 synchronized 块）是不能被中断的，但是 ReentrantLock 支持可中断的获取模式即 tryLock(long time, TimeUnit unit)。