


https://github.com/eclipse/jetty.project/blob/jetty-9.2.x/jetty-io/src/main/java/org/eclipse/jetty/io/ArrayByteBufferPool.java


```java

    // http://leibinhui.iteye.com/blog/1949041

    @Override
    // 请求使用某个size容量的ByteBuffer
    public ByteBuffer acquire(int size, boolean direct)
    {
        // 根据给定的容量大小size和direct的值去定位对应的桶（Bucket）
        Bucket bucket = bucketFor(size,direct);
        // 如果bucket不为null，则返回ConcurrentLinkedQueue队列_queue的元素
        ByteBuffer buffer = bucket==null?null:bucket._queue.poll();

        // 如果不能从ConcurrentLinkedQueue队列_queue获取buffer，则重新申请
        if (buffer == null)
        {
            int capacity = bucket==null?size:bucket._size;
            // allocate 当Java程序接收到外部传来的数据时，首先是被系统内存所获取，然后在由系统内存复制复制到JVM内存中供Java程序使用
            // allocateDirect 直接使用系统内存
            buffer = direct ? BufferUtil.allocateDirect(capacity) : BufferUtil.allocate(capacity);
        }

        return buffer;
    }

    @Override
    public void release(ByteBuffer buffer)
    {
        if (buffer!=null)
        {    
            Bucket bucket = bucketFor(buffer.capacity(),buffer.isDirect());
            if (bucket!=null)
            {
                // 清空buffer，将buffer插入ConcurrentLinkedQueue队列 _queue
                BufferUtil.clear(buffer);
                bucket._queue.offer(buffer);
            }
        }
    }

    // 两个Bucket 桶分别用来存放直接缓冲区的大小和堆缓冲区的大小
    private final Bucket[] _direct;
    private final Bucket[] _indirect;
    
    public ArrayByteBufferPool()
    {
        this(0,1024,64*1024);
    }

    public ArrayByteBufferPool(int minSize, int increment, int maxSize)
    {
        if (minSize>=increment)
            throw new IllegalArgumentException("minSize >= increment");
        if ((maxSize%increment)!=0 || increment>=maxSize)
            throw new IllegalArgumentException("increment must be a divisor of maxSize");
        _min=minSize;
        _inc=increment;

        // 创建64个_direct和64个_indirect
        _direct=new Bucket[maxSize/increment];
        _indirect=new Bucket[maxSize/increment];

        int size=0;
        for (int i=0;i<_direct.length;i++)
        {
            // Bucket的大小线性增长，1024，2*1024，3*1024，4*1024 ...
            size+=_inc;
            _direct[i]=new Bucket(size);
            _indirect[i]=new Bucket(size);
        }
    }

    private Bucket bucketFor(int size,boolean direct)
    {
        if (size<=_min)
            return null;
        int b=(size-1)/_inc;
        if (b>=_direct.length)
            return null;
        Bucket bucket = direct?_direct[b]:_indirect[b];
                
        return bucket;
    }
```