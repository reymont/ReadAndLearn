
# 第7章　EventLoop和线程模型

* 线程模型指定了操作系统、编程语言、框架或者应用程序的上下文中的线程管理的关键方面

## 7.1  线程模型概述

* 线程模型
  * 线程模型确定了代码的执行方式
* 基本的线程池化模式
  * 从池的空闲线程列表中选择一个Thread去运行一个已提交的任务
  * 当任务完成时，将该Thread返回给该列表，使其可被重用

## 7.2  EventLoop接口

* EventLoop
  * 事件循环
  * 采用两个基本的API：并发和网络编程
  * 一个EventLoop将由一个永远都不会改变的Thread驱动
  * EventLoop继承自ScheduledExecutorService
  * 事件和任务是以先进先出FIFO的顺序执行

### 7.2.1  Netty 4中的I/O和事件处理

### 7.2.2  Netty 3中的I/O操作

## 7.3  任务调度

### 7.3.1  JDK的任务调度API

* 任务调度
  * Timer
  * ScheduledExecutorService

### 7.3.2  使用EventLoop调度任务

* 作为线程池管理的一部分，将会有额外的线程创建

## 7.4  实现细节

### 7.4.1  线程管理

* 线程管理
  * 确定线程是否分配给当前Channel以及EventLoop
  * 每个EventLoop都有自己的任务队列，独立于任何其他的EventLoop
  * 如果当前线程是EventLoop线程，提交的代码将会直接执行
  * 否则，EventLoop将其放入内部队列，进行任务调度
  * 不要将一个长时间运行的任务放入到执行对了中，将会阻塞其他任务

### 7.4.2  EventLoop/线程的分配

* 异步传输
  * 使用少量的EventLoop，可能被多个Channel所共享
  * 一个EventLoop中相关联的Channel，ThreadLocal都是一样的
* 阻塞传输
  * 用于阻塞IO

## 7.5  小结

* Brian Goetz《Java并发编程实战》