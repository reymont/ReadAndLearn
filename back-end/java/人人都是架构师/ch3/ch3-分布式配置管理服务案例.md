

# 第3章 分布式配置管理服务案例

* 配置形式
  * 本地配置
  * 大规模分布式场景的集中式资源配置
  * ZooKeeper分布式配置管理平台
* 本地配置
  * 将配置信息耦合在业务代码中
  * 将配置信息配置在配置文件中
* 耦合在业务代码
  * 不利于项目后期维护
  * 不同环境只能修改业务代码进行适应
* 配置在配置文件  
  * 将可变的配置信息与业务代码进行解耦
  * 定义不同环境所需的配置信息
  * 分布式场景下，希望配置运行时变更，不重启获取配置信息

### 3.2 集中式资源配置需求

* 好处
  * 配置信息统一管理
  * 动态获取/更新配置信息
  * 降低运维人员的维护成本
  * 降低配置出错率
* 分布式配置管理
  * 分布式配置管理服务的本质就是典型的发布/订阅（Publish/Subscribe）模式
  * 订阅方获取配置信息
  * 推送方发布配置信息

### 3.2.1 分布式一致性协调服务ZooKeeper简介

* ZooKeeper
  * 配置管理（数据发布/订阅）
  * 分布式协调/通知
  * 分布式锁
  * 统一命名
* 组成
  * 子节点称为Znode，有全局唯一的路径
  * Znode的类型：持久节点和瞬时节点
  * Znode维护一个版本号，随着数据的变更自动递增

### 3.2.2 ZooKeeper的下载与集群安装

* zoo.cfg
  * dataDir数据存放目录：目录中创建myid文件，与节点编号对应
  * dataLogDir日志存放目录
  * clientPort客户端通信连接端口2181
  * maxClientCnxns最大通信连接端口
  * 集群节点相关信息
* server.1=ip1:2888:3888
  * 1为节点编号
  * ip1为节点IP
  * 2888节点与leader信息交换端口
  * 3888节点选举leader端口

### 3.2.3 ZooKeeper的基本使用技巧

每个Znode节点维护着一个版本号（dataVersion），版本号随着每次数据的变更自动递增

* zkCli
  * create /zkTest testData
  * get /zkTest
  * set /zkTest testData2
  * delete /zkTest

### 3.2.4 基于ZooKeeper实现分布式配置管理平台方案

* 基于ZooKeeper实现分布式配置管理平台
  * 信息配置管理界面
  * 订阅Znode中的配置信息
  * 容灾机制
* new ZooKeeper("127.0.0.1:2181", 5000, new Watcher(){...})
  * connectString通信地址
  * sessionTimeout等待客户端通信的最长时间
  * Watcher设置接收ZooKeeper的会话事件，监听Znode的节点变更
* 会话监听**事件状态**
  * SyncConnected会话连接成功
  * Disconnected会话中断并迁移
  * Expired会话连接超时尝试重新连接
* 数据监听**事件类型**
  * NodeDataChanged目标Znode上的数据已发生变更

### 3.2.5 从配置中心获取Spring的Bean定义实现Bean动态注册

* Spring Bean
  * 下载配置文件，加载到FileSystemResource
  * new XmlBeanDefineitionReader().loaderDefinitions(resource)动态注册和销毁bean
  * beanFactory.getbean(beanName)实例化未实例化的的Bean
* 注意
  * Bean属性**destroy-method**设置为"close"，销毁后释放底层连接资源
  * BeanFactory采用懒加载模式，用到Bean时才会实例化
  * 不能通过Spring的注解装配得到相关的Bean实例，避免配置变更后使用的还是之前的对象引用

### 3.2.6 容灾方案

* 冗余存储机制
  * 配置信息可以固化到客户端本地的容灾目录
  * 配置变更后需要覆盖容灾目录中的缓存文件
  * 因网络问题，客户端能离线启动，直接读取本地的缓存数据

### 3.2.7 使用淘宝Diamond实现分布式配置管理服务

* Diamond
  * 淘宝的分布式配置管理平台
* 架构
  * Diamond-Server：配置信息的发布和管理
  * Diamond-Client：配置信息的订阅
  * Key-Value结构，通过Key(dataId和group)订阅信息
* 容灾机制
  * 持久化到数据库
  * 服务端本地缓存
  * 客户端本地缓存
  * 主从架构
  * 复制“镜像”到容灾目录继续使用
* DefaultDiamondManager
  * group和dataId组成唯一Key订阅配置信息 
  * 重写ManagerListener.receiverConfigInfo()监听数据变更
  * getDiamondConfigure()获取DiamondConfigure实例，设置域名列表、端口号及客户端轮询时间间隔
  * 当某个节点的配置信息发生变更后，DiamondServer会通知其他节点更新本地的配置信息

### 3.2.8 Diamond与ZooKeeper的细节差异

* Diamond与ZooKeeper差异
  * 数据存储方案不同；
  * 监听数据变更的机制不同；
  * 容灾机制不同；
  * Znode不适合存储大数据；
* 存储  
  * Diamond主要通过MySQL数据库来管理和存储数据
  * ZooKeeper采用的是类似于UNIX的文件系统目录
  * ZooKeeper数据全量缓存在内存。不支持数据追加，只支持替换操作。
* 监听机制
  * Diamond客户端15秒轮询
  * ZooKeeper长连接监听，实时性高

### 3.2.9 使用百度Disconf实现分布式配置管理服务

* Disconf
  * Disconf-Core客户端和服务端都必须依赖它
  * Disconf-Client客户端模块
  * Disconf-Tools工具模块
  * Disconf-Web服务端模块
  
