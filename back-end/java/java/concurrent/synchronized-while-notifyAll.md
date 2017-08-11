

# Java synchronized 中的 while 和 notifyAll

[Java synchronized 中的 while 和 notifyAll ](http://mp.weixin.qq.com/s/kFruZ6YkrJCJm2nSWAXqAQ)

问题1 为什么是while 而不是if

大多数人都知道常见的使用synchronized代码:
```java
synchronized (obj) {
     while (check pass) {
        wait();
    }
    // do your business
}
```
那么问题是为啥这里是while而不是if呢?

这个问题 我最开始也想了很久, 按理来说 已经在synchronized块里面了嘛 就不需要了. 这个也是我前面一直是这么认为的, 直到最近看了一个Stackoverflow上的问题, 才对这个问题有了比较深入的理解.

实现一个有界队列

试想我们要试想一个有界的队列. 那么常见的代码可以是这样:
```java
static class Buf {
    private final int MAX = 5;
    private final ArrayList<Integer> list = new ArrayList<>();
    synchronized void put(int v) throws InterruptedException {
        if (list.size() == MAX) {
            wait();
        }
        list.add(v);
        notifyAll();
    }
 
    synchronized int get() throws InterruptedException {
        // line 0 
        if (list.size() == 0) {  // line 1
            wait();  // line2
            // line 3
        }
        int v = list.remove(0);  // line 4
        notifyAll(); // line 5
        return v;
    }
 
    synchronized int size() {
        return list.size();
    }
}
```

注意到这里用的if, 那么我们来看看它会报什么错呢?
下面的代码用了1个线程来put ; 10个线程来get:

```java
final Buf buf = new Buf();
ExecutorService es = Executors.newFixedThreadPool(11);
for (int i = 0; i < 1; i++)
es.execute(new Runnable() {
 
    @Override
    public void run() {
        while (true ) {
            try {
                buf.put(1);
                Thread.sleep(20);
            }
            catch (InterruptedException e) {
                e.printStackTrace();
                break;
            }
        }
    }
});
for (int i = 0; i < 10; i++) {
    es.execute(new Runnable() {
 
        @Override
        public void run() {
            while (true ) {
                try {
                    buf.get();
                    Thread.sleep(10);
                }
                catch (InterruptedException e) {
                    e.printStackTrace();
                    break;
                }
            }
        }
    });
}
 
es.shutdown();
es.awaitTermination(1, TimeUnit.DAYS);
```
这段代码很快或者说一开始就会报错
```java
Java.lang.IndexOutOfBoundsException: Index: 0, Size: 0
at java.util.ArrayList.rangeCheck(ArrayList.java:653) 
at java.util.ArrayList.remove(ArrayList.java:492) 
at TestWhileWaitBuf.get(TestWhileWait.java:80)atTestWhileWait2.run(TestWhileWait.java:47) 
at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142) 
at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617) 
at java.lang.Thread.run(Thread.java:745)
```
很明显,在remove’的时候报错了.
那么我们来分析下:

假设现在有A, B两个线程来执行get 操作, 我们假设如下的步骤发生了:

1. A 拿到了锁 line 0
2. A 发现size==0, (line 1), 然后进入等待,并释放锁 (line 2)
3. 此时B拿到了锁, line0, 发现size==0, (line 1), 然后进入等待,并释放锁 (line 2)
4. 这个时候有个线程C往里面加了个数据1, 那么 notifyAll 所有的等待的线程都被唤醒了.
5. AB 重新获取锁, 假设 又是A拿到了. 然后 他就走到line 3, 移除了一个数据, (line4) 没有问题.
6. A 移除数据后 想通知别人, 此时list的大小有了变化, 于是调用了notifyAll (line5), 这个时候就把B给唤醒了, 那么B接着往下走.
7. 这时候B就出问题了, 因为 其实 此时的竞态条件已经不满足了 (size==0). B以为还可以删除就尝试去删除, 结果就跑了异常了.

那么fix很简单, 在get的时候加上while就好了:
```java
synchronized int get() throws InterruptedException {
      while (list.size() == 0) {
          wait();
      }
      int v = list.remove(0);
      notifyAll();
      return v;
  }
```
同样的, 我们可以尝试修改put的线程数 和 get的线程数来 发现如果put里面不是while的话 也是不行的:

我们可以用一个外部周期性任务来打印当前list的大小, 你会发现大小并不是固定的最大5:
```java
final Buf buf = new Buf();
ExecutorService es = Executors.newFixedThreadPool(11);
ScheduledExecutorService printer = Executors.newScheduledThreadPool(1);
printer.scheduleAtFixedRate(new Runnable() {
    @Override
    public void run() {
        System.out.println(buf.size());
    }
}, 0, 1, TimeUnit.SECONDS);
for (int i = 0; i < 10; i++)
es.execute(new Runnable() {
 
    @Override
    public void run() {
        while (true ) {
            try {
                buf.put(1);
                Thread.sleep(200);
            }
            catch (InterruptedException e) {
                 e.printStackTrace();
                break;
            }
        }
    }
});
for (int i = 0; i < 1; i++) {
    es.execute(new Runnable() {
 
        @Override
        public void run() {
            while (true ) {
                try {
                    buf.get();
                    Thread.sleep(100);
                }
                catch (InterruptedException e) {
                    e.printStackTrace();
                    break;
                }
            }
        }
    });
}
 
es.shutdown();
es.awaitTermination(1, TimeUnit.DAYS);

20170508202625330
```
这里 我想应该说清楚了为啥必须是while 还是if了

问题2:什么时候用notifyAll或者notify

大多数人都会这么告诉你:

当你想要通知所有人的时候就用notifyAll, 当你只想通知一个人的时候就用notify.
但是我们都知道notify实际上我们是没法决定到底通知谁的(都是从等待集合里面选一个). 那这个还有什么存在的意义呢?

在上面的例子中,我们用到了notifyAll, 那么下面我们来看下用notify是否可以工作呢?
那么代码变成下面的样子:
```java
synchronized void put(int v) throws InterruptedException {
       if (list.size() == MAX) {
           wait();
       }
       list.add(v);
       notify();
   }
 
   synchronized int get() throws InterruptedException {
       while (list.size() == 0) {
           wait();
       }
       int v = list.remove(0);
       notify();
       return v;
   }
```
下面的几点是jvm告诉我们的:

任何时候,被唤醒的来执行的线程是不可预知. 比如有5个线程都在一个对象上, 实际上我不知道 下一个哪个线程会被执行.
synchronized语义实现了有且只有一个线程可以执行同步块里面的代码.

那么我们假设下面的场景就会导致死锁:

P – 生产者 调用put
C – 消费者 调用get

P1 放了一个数字1
P2 想来放,发现满了,在wait里面等了
P3 想来放,发现满了,在wait里面等了
C1想来拿, C2, C3 就在get里面等着
C1开始执行, 获取1, 然后调用notify 然后退出
如果C1把C2唤醒了, 所以P2 (其他的都得等.)只能在put方法上等着. (等待获取synchoronized (this) 这个monitor)
C2 检查while循环 发现此时队列是空的, 所以就在wait里面等着
C3 也比P2先执行, 那么发现也是空的, 只能等着了.
这时候我们发现P2 , C2, C3 都在等着锁. 最终P2 拿到了锁, 放一个1, notify,然后退出.
P2 这个时候唤醒了P3, P3发现队列是满的,没办法,只能等它变为空.
这时候, 没有别的调用了, 那么现在这三个线程(P3, C2,C3)就全部变成suspend了.也就是死锁了.

Reference:

http://stackoverflow.com/questions/37026/java-notify-vs-notifyall-all-over-again