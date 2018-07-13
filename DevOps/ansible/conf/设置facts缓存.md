

http://www.cnblogs.com/f-ck-need-u/p/7580170.html

### 1.4.4 设置facts缓存

ansible或ansible-playbook默认总是先收集facts信息。在被控主机较少的情况下，收集信息还可以容忍，如果被控主机数量非常大，收集facts信息会消耗掉非常多时间。

可以设置"gather_facts: no"来禁止ansible收集facts信息，但是有时候又需要使用facts中的内容，这时候可以设置facts的缓存。例如，在空闲的时候收集facts，缓存下来，在需要的时候直接读取缓存进行引用。

ansible的配置文件中可以修改'gathering'的值为'smart'、'implicit'或者'explicit'。`smart表示默认收集facts，但facts已有的情况下不会收集`，即使用缓存facts；implicit表示默认收集facts，要禁止收集，必须使用gather_facts: False；explicit则表示默认不收集，要显式收集，必须使用gather_facts: Ture。

在使用facts缓存时(即设置为smart)，ansible支持两种facts缓存：redis和jsonfile。

例如，以下是`/etc/ansible/ansible.cfg`中jsonfile格式的缓存配置方法。

```conf
[defaults]
gathering = smart
fact_caching_timeout = 86400
fact_caching = jsonfile
fact_caching_connection = /path/to/cachedir
```
这里设置的缓存过期时间为86400秒，即`缓存一天`。
缓存的json文件放在/path/to/cachedir目录下，各主机的`缓存文件以主机名命名`。
缓存文件是一个json文件，要查看缓存文件，如/path/to/cachedir/192.168.100.59中的内容，使用如下语句即可。

cat /path/to/cachedir/192.168.100.59 | python -m json.tool
回到系列文章大纲：http://www.cnblogs.com/f-ck-need-u/p/7048359.html

转载请注明出处：http://www.cnblogs.com/f-ck-need-u/p/7580170.html
注：若您觉得这篇文章还不错请点击下右下角的推荐，有了您的支持才能激发作者更大的写作热情，非常感谢！