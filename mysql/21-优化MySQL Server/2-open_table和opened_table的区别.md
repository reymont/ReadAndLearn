

open_table和opened_table的区别 -zhangx105504-ChinaUnix博客 http://blog.chinaunix.net/uid-7574487-id-4098742.html

open_tables:是当前在缓存中打开表的数量。
opened_tables:是mysql自启动起，打开表的数量。

假如没有缓存的话，那么mysql服务在每次执行一个语句的时候，都会先打开一个表。当sql语句执行完成后，则把这个表关掉。这就是opend_tables中的值。

而，open_tables这个值，是mysql在使用缓存的情况下，存储在缓存中的表的个数。

我们可以这样做实验：执行flush tables;这个命令是mysql用来刷新缓存的。当这个命令执行后，我们会看到
open_tables这个值被清零了。但是opened_tables这个值还是保持原来值不变。

但是当我们关闭mysql服务，再重启后，opened_tables这个值也被清零了。

由此，得出上述两个值的结论。

这也就是为什么说当open_tables这个值接近于table_buffer这个值的时候，同时opened_tables的值在不断的增加，这个时候就要考虑增大table_buffer这个缓存值了。

解释如下：
因为open_tables的值接近于table_buffer，说明分配的缓存已经被用完了。而opened_tables这个值又在高速增加，说明mysql在不断的打开表。也就说明缓存中并没有这些要打开的表。所以说，缓存应该是要增加了。因为如果表在缓存中，那么打开表的时候这两个值是不会增加的。

```sql
mysql> show global status like 'open_tables';  
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Open_tables   | 152   |
+---------------+-------+
1 row in set (0.00 sec)

mysql> show global status like 'opened_tables';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Opened_tables | 169   |
+---------------+-------+
1 row in set (0.01 sec)

mysql> flush tables;
Query OK, 0 rows affected (1.88 sec)

mysql> show global status like 'open_tables';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Open_tables   | 1     |
+---------------+-------+
1 row in set (0.00 sec)

mysql> show global status like 'opened_tables';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| Opened_tables | 171   |
+---------------+-------+
1 row in set (0.00 sec)

```
