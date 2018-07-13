

# ScheduledExecutorService定时周期执行指定的任务

* [ScheduledExecutorService定时周期执行指定的任务 - 不积跬步无以至千里，不积小流无以成江海。 - CSDN博客 ]http://blog.csdn.net/tsyj810883979/article/details/8481621


# java定时任务接口ScheduledExecutorService

* [java定时任务接口ScheduledExecutorService - 坚守一辈子的幸福 - 博客园 ](http://www.cnblogs.com/chenmo-xpw/p/5555931.html)

一、ScheduledExecutorService 设计思想

ScheduledExecutorService,是基于线程池设计的定时任务类,每个调度任务都会分配到线程池中的一个线程去执行,也就是说,任务是并发执行,互不影响。

需要注意,只有当调度任务来的时候,ScheduledExecutorService才会真正启动一个线程,其余时间ScheduledExecutorService都是出于轮询任务的状态。

1、线程任务

```java
class MyScheduledExecutor implements Runnable {
    
    private String jobName;
    
    MyScheduledExecutor() {
        
    }
    
    MyScheduledExecutor(String jobName) {
        this.jobName = jobName;
    }

    @Override
    public void run() {
        
        System.out.println(jobName + " is running");
    }
}
```
2、定时任务

```java
public static void main(String[] args) {
        ScheduledExecutorService service = Executors.newScheduledThreadPool(10);
        
        long initialDelay = 1;
        long period = 1;
        // 从现在开始1秒钟之后，每隔1秒钟执行一次job1
        service.scheduleAtFixedRate(new MyScheduledExecutor("job1"), initialDelay, period, TimeUnit.SECONDS);
        
        // 从现在开始2秒钟之后，每隔2秒钟执行一次job2
        service.scheduleWithFixedDelay(new MyScheduledExecutor("job2"), initialDelay, period, TimeUnit.SECONDS);
    }
```
ScheduledExecutorService 中两种最常用的调度方法 ScheduleAtFixedRate 和 ScheduleWithFixedDelay。ScheduleAtFixedRate 每次执行时间为上一次任务开始起向后推一个时间间隔，即每次执行时间为 :initialDelay, initialDelay+period, initialDelay+2*period, …；ScheduleWithFixedDelay 每次执行时间为上一次任务结束起向后推一个时间间隔，即每次执行时间为：initialDelay, initialDelay+executeTime+delay, initialDelay+2*executeTime+2*delay。由此可见，ScheduleAtFixedRate 是基于固定时间间隔进行任务调度，ScheduleWithFixedDelay 取决于每次任务执行的时间长短，是基于不固定时间间隔进行任务调度。

参考文献 ：

http://www.ibm.com/developerworks/cn/java/j-lo-taskschedule/