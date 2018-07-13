java多线程之守护线程(daemon thread) - CSDN博客 https://blog.csdn.net/pony_maggie/article/details/42441895


转载请注明出处
http://blog.csdn.net/pony_maggie/article/details/42441895

作者:小马

daemon是相于user线程而言的，可以理解为一种运行在后台的服务线程，比如时钟处理线程、idle线程、垃圾回收线程等都是daemon线程。



daemon线程有个特点就是"比较次要"，程序中如果所有的user线程都结束了，那这个程序本身就结束了，管daemon是否结束。而user线程就不是这样，只要还有一个user线程存在，程序就不会退出。


用Thread中的setDaemon就可以把线程设置为Daemon,daemon线程创建的所有其它线程默认是daemon,看一个示例:

[java] view plain copy
class Daemon extends Thread  
{  
    private static final int SIZE = 10;  
    private Thread[] t = new Thread[SIZE];  
      
    public Daemon()  
    {  
        setDaemon(true);  
        start();  
    }  
      
    public void run()  
    {  
        for(int i = 0; i < SIZE;i++)  
        {  
            t[i] = new DaemonSpawn(i);  
        }  
          
        for(int i = 0; i < SIZE;i++)  
        {  
            System.out.println("t[" + i + "].isDaemon() = " + t[i].isDaemon());  
        }  
        while(true) yield();  
    }  
}  

造函数中直接把自己设置为daemon并启动，注意start一定要在setDaemon之后，否则设置不生效。


类DaemonSpawn实现如下:
[java] view plain copy
class DaemonSpawn extends Thread  
{  
    public DaemonSpawn(int i)  
    {  
        System.out.println("DaemonSpawn " + i + " started");  
        start();  
    }  
      
    public void run()  
    {  
        while(true)  
        {  
            yield();  
        }  
    }  
}  

它并没有显示设置setDaemon，但是因为在Daemons类中生成实例，所以已经是daemon属性了。

main函数如下:
[java] view plain copy
public static void main(String[] args) throws IOException  
    {  
        // TODO Auto-generated method stub  
        Thread threadIns = new Daemon();  
        System.out.println("d.isDaemon() = " + threadIns.isDaemon());  
        System.out.println("press any key");  
        System.in.read();  
  
    }  




输出结果:

[java] view plain copy
d.isDaemon() = true  
press any key  
DaemonSpawn 0 started  
DaemonSpawn 1 started  
DaemonSpawn 2 started  
DaemonSpawn 3 started  
DaemonSpawn 4 started  
DaemonSpawn 5 started  
DaemonSpawn 6 started  
DaemonSpawn 7 started  
DaemonSpawn 8 started  
DaemonSpawn 9 started  
t[0].isDaemon() = true  
t[1].isDaemon() = true  
t[2].isDaemon() = true  
t[3].isDaemon() = true  
t[4].isDaemon() = true  
t[5].isDaemon() = true  
t[6].isDaemon() = true  
t[7].isDaemon() = true  
t[8].isDaemon() = true  
t[9].isDaemon() = true  


程序中的yield()函数简单说几句，其实和sleep功能相似，都是把当前线程暂停，这样其它线程才能有机会执行。区别就是它没有参数，不能像sleep那样指定暂停的时间。

还有个区别很重要，yield只能让同级别优先级的线程得到执行机会。sleep不分优先级，只有当前线程sleep了，其它线程就有机会执行。否则没有sleep的话，只能等高优先级执行完毕，才能执行低优先级的线程。

说了这么多，似乎并没有说到daemon线程的优点，哪些情况要用到它呢？举个例子，比如垃圾回收线程，我们希望用户线程存在时，它也存在，但当所有的用户线程退出时，程序就要退出，垃圾回收线程不要影响退出。如果定义成了用户线程，那么只要垃圾回收线程不退出，用户线程就不会退出，与实际需求不相符。