
# 第11章 Spring的事务管理

* 事务管理
  * 提供和底层事务源无关的事务抽象
  * 提供声明性事务的功能

## 11.1 数据库事务基础知识

### 11.1.1 何为数据库事务

* 数据库事务4个特性ACID
  * 原子性Atomic：一个事务的多个数据库操作是一个不可分割的原子单元
  * 一致性Consistency：数据不会被破坏
  * 隔离性Isolation：不同事务操作不会互相干扰
  * 持久性Durability：
* 数据“一致性”是最终目标
* 重执行日志保证原子性、一致性和持久性
* 采用数据库锁机制保证事务的隔离性

### 11.1.2 数据并发的问题

* 5类问题
* 3类数据读问题
  * 脏读：读到其他尚未提交的更改数据
  * 不可重复读：读到其他已提交的事务新增数据
  * 幻读：读到其他已提交的事务更新数据。一般发生在统计数据的事务中
* 2类数据更新问题
  * 第一类丢失更新：覆盖其他已提交的更新事务
  * 第二类丢失更新：覆盖其他已提交的更新事务

### 11.1.3 数据库锁机制

* 锁定对象不同
  * 表锁定：整张表进行锁定
  * 行锁定：表中特定行进行锁定
* 并发事务锁定的关系
  * 共享锁定：防止独占，允许其他共享
  * 独占锁定：防止独占，防止其他共享
* 更改行施加行独占锁定
* Oracle中5种锁定
  * 行共享锁定：防止其他会话独占锁定
  * 行独占锁定
  * 表共享锁定
  * 表共享行独占锁定
  * 表独占锁定

### 11.1.4 事务隔离级别

* 4个等级的事务隔离级别
  * 读未提交READ UNCOMMITED：一个事务可以读取另一个未提交事务的数据
    * 脏读：一个事务处理读取另一个未提交的事务中的数据。
  * 读提交READ COMMITTED：一个事务要等另一个事务提交后才能读取数据
    * 不可重复读：一个事务范围内两个相同的查询却返回了不同数据
  * 重复读REPEATABLE READ：在开始读取数据（事务开启）时，不再允许修改操作
    * 幻读问题对应的是插入INSERT操作，而不是UPDATE操作
    * 幻读和不可重复读都是读取了另一条已经提交的事务
    * 不可重复读查询的都是同一个数据项，而幻读针对的是一批数据整体
  * 串行化SERIALIZABLE:事务串行化顺序执行
  
### 11.1.5 JDBC对事务的支持

* Connection
  * getMetaData()获取DatabaseMetaData对象
  * setAutoCommit(false)阻止Connection自动提交
  * setTransactionIsolation()设置事务的隔离级别
  * rollback()回滚事务
* DatabaseMetaData
  * supportsTransactions()事务
  * supportsTransactionIsolationLevel()
  * supportsSavePoints()是否支持保存点
* 事务操作
  * 提交
  * 回滚
  * 保存点：允许用户将事务分割为多个阶段，用户可以指定回滚到事务的特定保存点

## 11.2 ThreadLocal基础知识

* 模板类
  * 线程安全的
  * 未采用线程同步机制
  * ThreadLocal

### 11.2.1 ThreadLocal是什么

* ThreadLocal
  * 线程局部变量
  * 不是一个线程，保存线程本地化对象的容器
  * 线程分配一个独立的变量副本，线程专有的本地变量

### 11.2.2 ThreadLocal的接口方法

* ThreadLocal
  * set()设置当前线程的线程局部变量的值
  * get()返回当前线程所对应的线程局部变量
  * remove()将当前线程局部变量的值删除
  * initialValue()返回线程局部变量的初始值
* 设计
  * Map存储每个线程的变量副本
  * Map键为线程对象
  * 值为对应线程的变量副本

### 11.2.3 一个TheadLocal实例

### 11.2.4 与Thread同步机制的比较

* ThreadLocal vs 线程同步机制
  * 对象锁机制保证同一时间只有一个线程访问变量，该变量是多个线程共享的
  * ThreadLocal为每个线程提供一个变量副本，隔离多线程的数据冲突
  * 同步机制采用`以时间换空间`，访问串行化、对象共享化
  * ThreadLocal采用`以空间换时间`，访问并行化、对象独享化

### 11.2.5 Spring使用ThreadLocal解决线程安全问题

## 11.3 Spring对事务管理的支持

* Spring事务管理
  * Spring让用户以统一的编程模型进行事务管理

### 11.3.1 事务管理关键抽象

* Spring事务管理SPI（Service Provider Interface）3个接口
  * PlatformTransactionManager：创建事务
  * TransactionDefinition：描述事务的隔离级别、超时时间
  * TransactionStatus：激活事务的状态
* TransactionDefinition
  * 事务隔离：当前事务和其他事务的隔离程度
  * 事务传播
  * 事务超时：超时回滚
  * 只读状态：不修改任何数据，针对可读事务应用的优化措施
* 通过XML或注解元数据的方式配置事务属性
* TransactionStatus
  * SavepointManager
    * 基于JDBC 3.0保存点的分段事务控制能力提供嵌套事务的机制
    * createSaveponit()创建
    * rollbackToSavepoint()回滚到特定的保存点，被回滚的保存点将自动释放
    * releaseSavepoint()释放保存点。事务提交后，所有的保存点会自动释放
  * 扩展SavepointManager
    * hasSavepoint()：当前事务是否在内部创建了保存点
    * isNewTransaction()：当前操作是否运行在事务环境中
    * isCompleted()：判断当前事务是否已结束
    * isRollbackOnly()
    * setRollbackOnly()：通知当前事务回滚
* PlatformTransactionManager
  * 事务管理器

### 11.3.2 Spring的事务管理器实现类

* 事务管理器
  * Spring将事务管理委托给底层具体的持久化实现框架来完成
* Spring JDBC和MyBatis
  * 基于数据源，使用DataSourceTransactionManager
* JPA
  * DataSource
  * EntityManagerFactory
  * JpaTransactionManager
* Hibernate
  * HibernateTransactionManager
* JTA
  * JNDI
  * JtaTransactionManger
  * 引用容器提供的全局事务管理

### 11.3.3 事务同步管理器

* 事务同步管理器
  * TransactionSynchronizationManager
  * 使用ThreadLocal为不同事务线程提供独立的资源副本
  * 维护事务配置的属性和运行状态信息
  * 将DAO、Service类中影响线程安全的所有`状态`统一抽取到该类中，并用ThreadLocal进行替换

### 11.3.4 事务传播行为

* 事务传播
  * 控制当前的事务如何传播到被嵌套调用的目标服务接口方法中
  * 事务方法和事务方法发生嵌套时事务如何进行传播
* 7种事务传播
  * PROPAGATION_REQUIRED
    * 当前无事务，则新建一个事务
    * 当前有事务，加入到这个事务
  * PROPAGATION_REQUIRES_NEW
    * 新建事务
    * 当前有事务，则挂起当前事务
  * PROPAGATION_SUPPORTS
    * 支持当前事务
    * 当前无事务，则以非事务方式执行
  * PROPAGATION_NOT_SUPPORTED
    * 以非事务方式执行
    * 当前有事务，则挂起当前事务
  * PROPAGATION_MANDATORY
    * 使用当前事务
    * 当前无事务，则抛出异常
  * PROPAGATION_NEVER
    * 以非事务方式执行
    * 当前有事务，则抛出异常
  * PROPAGATION_NESTED
    * 当前有事务，则嵌套事务内执行
    * 当前无事务，则新建一个事务

## 11.4 编程式的事务管理

## 11.5 使用XML配置声明式事务

* XML声明式事务
  * 通过Spring AOP实现

### 11.5.1 一个将被实施事务增强的服务接口

### 11.5.2 使用原始的TransactionProxyFactoryBean

* 代理类声明式事务
  * TransactionProxyFactoryBean
  * 事务管理器DataSourceTransactionManager
  * 统配符get*，通过键值配置业务方法的事务属性信息
* 异常回滚/提交规则
  * PROPAGATION, ISOLATION, readOnly, -Exception, +Exception
         ^           ^          ^          ^           ^
      传播行为     隔离级别    只读事务    异常回滚     异常提交
  * 传播行为是唯一必须提供的配置项
  * 隔离级别配置项是可选的
  * 异常
    * 默认异常的事务回滚规则：运行期异常回滚、检查型异常不回滚
    * 抛出负号型异常，触发事务回滚
    * 抛出正号型异常，事务提交
* 缺点
  * 需要对每个需要事务支持的业务类进行单独的配置
  * 指定事务方法时，只能通过方法名进行定义
  * 事务属性的配置串统一由逗号分隔的字符串来描述，容易出错
  * 

### 11.5.3 基于aop/tx命名空间的配置
  