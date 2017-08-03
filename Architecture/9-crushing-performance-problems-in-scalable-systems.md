

[9 crushing performance problems in scalable systems | InfoWorld ](http://www.infoworld.com/article/3211526/database/9-crushing-performance-problems-in-scalable-systems.html)
[可扩展系统的9个性能问题 ](http://geek.csdn.net/news/detail/229260)

If you have deployed a few systems of scale, you know that some design problems are worse than others. It’s one thing to write tight code, and another thing to avoid introducing performance-crushing design flaws into the system.

Here are nine common problems – poor design choices, really – that will cause your system to spin its wheels, or even turn against itself. Unlike many bad decisions, these can be reversed.

[ Database slow? Improve the speed and scalability of your RDBMS with these 21 rules for faster SQL queries. | Keep up with the hottest topics in programming with InfoWorld’s App Dev Report newsletter. ]
1. N+1 queries

If you select all of a customer’s orders in one query then loop through selecting each order’s line items in a query per order, that’s n trips to the database plus one. One big query with an outer join would be more efficient. If you need to pull back fewer at a time you can use a form of paging. Developers using caches that fill themselves often write n+1 problems by accident. You can find these situations with database monitoring tools such as Oracle Enterprise Monitor (OEM) or APM tools such as Wily Introscope or just plain query logging. There are worse versions of this problem such as people who try and crawl a tree stored in flat tables instead of using CTEs. There are also equivalent versions of these problems in NoSQL databases, so no one is safe.

2. Page or record locking

Man, I used to loathe DB2 and SQL Server. I still loathe their default locking model. Depending on platform, DB2 locks a “page” of records for updates. You end up locking records that aren’t even related to what you’re doing just by happenstance. Row locks are more common. A longer-running transaction makes a minor update to a row that doesn’t really affect anything else. All other queries block. Meanwhile those transactions hold any locks they have longer, creating a cascading performance problem. If you’re on either of those databases, turn on and design for snapshot isolation. Oracle uses a form of snapshot isolation by default. There are NoSQL databases that can be configured for paranoid levels of consistency. Understand its locking model before you hurt yourself.

3. Thread synchronization

This problem comes in many forms. Sometimes it’s hidden in a library. Years ago XML parsers used to validate the MIME type using a Java library called the Bean Activation Framework that used the old Java “Hashtable” collection that synchronized every method. That meant all threads doing XML parsing eventually queued in the same place, creating a massive concurrency bottleneck. You can find this problem by reading thread dumps. A lot of modern developers have gotten used to tools that handle most threading for them. This is fine until something doesn’t work properly. Everyone needs to understand concurrency.

4. Database sequences

If you just need a unique ID, don’t use a sequence. Only use a sequence if you legitimately need each ID to be well... sequential. How are sequences implemented? Thread locks. That means everything going for that sequence blocks. As an alternative use a randomly generated UUID that uses a secure random algorithm. Although it is theoretically possible to get a duplicate, after generating trillions of rows you still have a better chance of getting hit in the head with a meteorite. I’ve had developers actually sit in front of me bareheaded with no meteorite helmet and tell me that not even a theoretical chance of duplicates was acceptable in their system but I guess they didn’t value their own life as much. At least wear foil, sheesh.

5. Opening connections

Whether it be database, HTTP, or whatever, pool that stuff. Also on larger systems don’t try and open them all at once because you’ll find out your database wasn’t designed to do that!

6. Swapping

You need more memory than you can hope to use. If you use any swap at all, that’s bad. I used to configure my Linux boxes with no swap enabled because I wanted them to just crash and burn rather than silently kill my software.

7. I/O synchronization

Most caching software has the capacity to do “write behind” where data is written to memory on at least two machines and life goes on rather than waiting for disk to catch up. This “softens” the read-write wave. Eventually if write throughput is high enough you’ll have to block to catch up before the write-behind cache blows up. I/O sync exists elsewhere too, in things like log files and really anywhere you persist anything. Some software still calls fsync a lot and that’s not something you want in your high-end distributed scalable software – at least not with a lot of help.

8. Process spawning

Some software packages, especially on Unix operating systems, are still designed around processes and subprocesses where each process has a single thread. You can pool these and reuse them or other bandaging but this just isn’t a good design. Each process and child process gets its own memory space. Sometimes you can allocate another horrible idea called shared memory. Modern software has processes that manage multiple threads. This scales much better on modern multicore CPUs where each core can often handle multiple threads concurrently as well.

9. Network contention

Supposedly a distributed filesystem and Spark for in-memory computing make all of your server nodes work together and life is just grand, right? Actually, you still have NIC cards and switches and other things that constrain that bandwidth. NICs can be bonded, and switches are rated for certain numbers of packets per second (this is different than, say, a 1G switch that may not deliver 1G on all 20 ports). So it’s great you have lots of nodes delivering your data in bursts but are they bottlenecking on their own NICs, your actual network bandwidth, or on your switch’s actual available throughput?

Hopefully if you’re out there coding and architecting systems, you’re avoiding these pitfalls. Otherwise, remember that some old timers leave the industry and open bars, so there is always that.