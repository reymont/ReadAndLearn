
# 第5章　ByteBuf

* 网络
  * 网络数据的基本单位总是字节
  * Java NIO提供ByteBuffer作为字节容器
  * Netty的代替品是ByteBuf

## 5.1  ByteBuf的API

* ByteBuf API优点
  * 被用户自定义的缓冲区类型扩展
  * 内置的复合缓冲区实现零拷贝
  * 容量按需增长
  * 读写模式切换不需要调用ByteBuffer.flip()
  * 读写使用不同索引
  * 支持链式方法调用
  * 支持引用计数
  * 支持池化

## 5.2  ByteBuf类——Netty的数据容器

* 网络通信涉及字节序列的移动

### 5.2.1  它是如何工作的

* 读写使用不同索引

### 5.2.2  ByteBuf的使用模式

* ByteBuf的使用模式
  * 堆缓冲区：支撑数组backing array，将数据存储在JVM的堆空间中
  * 直接缓冲区
    * 直接缓冲区的内容将驻留在常规的会被垃圾回收的堆之外
    * 相对于基于堆的缓冲区，直接缓冲区的分配和释放都比较昂贵
  * 复合缓冲区CompositeByteBuf
    * 将多个缓冲区表示为单个合并缓冲区的虚拟表示
    * 可能同时包含直接内存分配和非直接内存分配

## 5.3  字节级操作

* 随机访问索引
  * ByteBuf从零开始
  * capacity() - 1
* 顺序访问索引
  * ByteBuffer只有一个索引，需要调用flip()方法在读模式和写模式之间进行切换
  * ByteBuf被两个索引划分成3个区域
    * 已读可丢弃
    * 未读
    * 可写
* 可丢失字节
  * 丢弃字节的分段包含已读的字节
  * discardReadBytes()，可丢弃字节分段中的空间变为可写
  * 有可能导致内存复制
* 可读字节
  * 存储实际数据
* 可写字节
  * 拥有未定义内容的、写入就绪的内存区域
* 索引管理
  * mark()将当前位置标记为指定的值
  * reset()将流重置到该位置
  * clear()将读写索引都设置为0
* 查找操作
  * indexOf()
  * ByteBufProcessor
  * ByteProcessor
* 派生缓冲区
  * 修改内容，将同时修改其他对应的源实例
  * copy()真实副本
* 读写操作
  * get()/set()，从给定的索引开始，保持索引不变
  * read()/write()，从给定的缩影开始，根据已访问的字节数对索引调整
* 更多操作

## 5.4  ByteBufHolder接口

* ByteBufHolder
  * 提供缓冲区池化

## 5.5  ByteBuf分配

* ByteBufAllocator
  * 池化ByteBuf
  * 按需分配
  * 两种实现
    * PooledByteBufAllocator提高性能并最大限度减少内存碎片
    * UnpooledByteBufAllocator不池化ByteBuf实例，每次调用后都返回一个新的实例
* Unpooled缓冲区
  * 提供静态的辅助方法来创建未池化的ByteBuf实例
* ByteBufUtil
  * hexdump()：以十六进制的表示形式打印ByteBuf的内容
  * equals()

## 5.6  引用计数

* 引用计数
  * 某个对象所持有的资源不再被其他对象引用时释放该对象所持有的资源
  * ReferenceCounted
  * 堆池化实现来说至关重要