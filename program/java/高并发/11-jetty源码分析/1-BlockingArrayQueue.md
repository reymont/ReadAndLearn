
## poll offer

```java

    // https://blog.csdn.net/javazejian/article/details/77410889
    // https://www.cnblogs.com/yangming1996/p/6973849.html
    // http://ifeve.com/falsesharing/

    /**
     * The head offset in the {@link #_indexes} array, displaced by 15 slots to avoid false sharing with the array length (stored before the first element of
     * the array itself).
     */
    private static final int HEAD_OFFSET = MemoryUtils.getIntegersPerCacheLine() - 1;
    /**
     * The tail offset in the {@link #_indexes} array, displaced by 16 slots from the head to avoid false sharing with it.
     */
    private static final int TAIL_OFFSET = HEAD_OFFSET + MemoryUtils.getIntegersPerCacheLine();

    /**
     * Array that holds the head and tail indexes, separated by a cache line to avoid false sharing
     */
    // 记录头部（head）和尾部（tail）的下一次操作数据索引index
    // 缓存系统中是以缓存行（cache line）为单位存储的。最常见的缓存行大小是64个字节。
    // 当多线程修改互相独立的变量时，如果这些变量共享同一个缓存行，就会无意中影响彼此的性能
    private final int[] _indexes = new int[TAIL_OFFSET + 1];
    // 使用2个锁来分开处理头部（head）和尾部（tail）
    private final Lock _tailLock = new ReentrantLock();
    private final Lock _headLock = new ReentrantLock();
    /** 当前阻塞队列中的元素个数 */
    private final AtomicInteger _size = new AtomicInteger();

    /** _notEmpty条件对象，当队列没有数据时用于挂起执行删除的线程 */
    private final Condition _notEmpty = _headLock.newCondition();

    public BlockingArrayQueue()
    {
        // 指定队列初始值，默认值为128
        _elements = new Object[DEFAULT_CAPACITY];
        _growCapacity = DEFAULT_GROWTH;
        // 容量大小，其默认值将是Integer.MAX_VALUE
        _maxCapacity = Integer.MAX_VALUE;
    }

    // 头部操作，获取并移除此队列的头元素，若队列为空，则返回 null
    public E poll()
    {
        // 队列个数为0时，返回null
        if (_size.get() == 0)
            return null;

        E e = null;

        _headLock.lock(); // Size cannot shrink
        try
        {
            if (_size.get() > 0)
            {
                // 获取要删除的对象
                final int head = _indexes[HEAD_OFFSET];
                e = (E)_elements[head];
                // 将队头设置为null
                _elements[head] = null;
                _indexes[HEAD_OFFSET] = (head + 1) % _elements.length;
                // 删除了元素说明队列有空位，唤醒_notEmpty条件
                if (_size.decrementAndGet() > 0)
                    _notEmpty.signal();
            }
        }
        finally
        {
            _headLock.unlock();
        }
        return e;
    }

    // 尾部操作，插入元素，成功返回 true，如果此队列已满，则返回 false
    public boolean offer(E e)
    {
        //添加元素为null直接抛出异常
        Objects.requireNonNull(e);

        boolean notEmpty = false;
        _tailLock.lock(); // Size cannot grow... only shrink
        try
        {
            //获取队列的个数
            int size = _size.get();
            //判断队列是否超过队列最大值，
            if (size >= _maxCapacity)
                return false;

            // 判断队列是否等于初始值
            // 如果等于_elements.length，且小于_maxCapacity，则动态扩展队列大小
            // Should we expand array?
            if (size == _elements.length)
            {
                _headLock.lock();
                try
                {
                    // 默认增加DEFAULT_GROWTH，即64
                    if (!grow())
                        return false;
                }
                finally
                {
                    _headLock.unlock();
                }
            }

            // 重新读下队列，将元素e添加到队尾
            // Re-read head and tail after a possible grow
            int tail = _indexes[TAIL_OFFSET];
            _elements[tail] = e;
            _indexes[TAIL_OFFSET] = (tail + 1) % _elements.length;
            notEmpty = _size.getAndIncrement() == 0;
        }
        finally
        {
            _tailLock.unlock();
        }

        if (notEmpty)
        {
            _headLock.lock();
            try
            {
                _notEmpty.signal();
            }
            finally
            {
                _headLock.unlock();
            }
        }

        return true;
    }

```


## Cache Line

1 关于CPU Cache和Cache Line - CSDN博客 https://blog.csdn.net/midion9/article/details/49487919


Cache Line可以简单的理解为CPU Cache中的最小缓存单位。目前主流的CPU Cache的Cache Line大小都是64Bytes。假设我们有一个512字节的一级缓存，那么按照64B的缓存单位大小来算，这个一级缓存所能存放的缓存个数就是512/64 = 8个

## 伪共享

伪共享(False Sharing) | 并发编程网 – ifeve.com http://ifeve.com/falsesharing/

在核心1上运行的线程想更新变量X，同时核心2上的线程想要更新变量Y。不幸的是，这两个变量在同一个缓存行中。每个线程都要去竞争缓存行的所有权来更新变量。如果核心1获得了所有权，缓存子系统将会使核心2中对应的缓存行失效。当核心2获得了所有权然后执行更新操作，核心1就要使自己对应的缓存行失效。这会来来回回的经过L3缓存，大大影响了性能。如果互相竞争的核心位于不同的插槽，就要额外横跨插槽连接，问题可能更加严重