
# http://blog.51cto.com/lixcto/1432722


roles类似于salt-stack里面的state，state有一定的组织结构。
而roles则是ansible中，playbooks的目录组织结构。
这么划分有啥好处呢？好处多了去了，如果把所有的东西都写到playbooks里面的话，
可能会导致我们这个playbooks很臃肿，不宜读。而模块化之后，成为roles的组织结构，易读，代码可重用，层次清晰方面贡献等等好处。

来看一下，楼主弄的一个小的目录结构。楼主自己做测试，内容都是瞎掰的，和实际环境完全不搭嘎的。
wKiom1OxY9Wyt1lZAAFEk2CIC6k694.jpg
第一级目录，有俩文件夹，俩文件。
group_vars这里面存的组变量，这里面的变量和/etc/ansible/group_vars里面的组变量定义规则是一样的。  groups_vars下面的salt文件，里面的变量只对salt这个组有效。。。如果文件名为all，则对所有主机所有组都有效。 而相对于roles，这里面的变量则是全局的。
1
2
lixc@ansible:~/ansible_script/web$ cat  group_vars/salt 
http_port: 80
hosts存放的是主机及组信息
1
2
3
lixc@ansible:~/ansible_script/web$ cat hosts 
[salt]
salt-master
roles目录下的mysql，和webservers显然就是两个role了。
像mysql，webservers这些目录下面可以有这些目录。
files:存文件的，把文件丢进这个目录，ansible默认就会到这里目录去找文件，对应task里面的copy模块
tasks：显然是存放tasks的
handlers：存放handlers
templates：存放模板，对应task里面的模块template
vars：这里面定义的变量，只对当前role有作用
meta：定义role和role直接的依赖关系。
先看webserver文件夹下有什么东西
wKioL1OxY1azM6V_AAPOkkFG6oE307.jpg
再看看mysql文件夹下面都有些啥东西
wKiom1OxYj7gyjogAAM5pBGUUvM496.jpg
site.yml文件，是我们要调用的文件了。
wKioL1OxZ8OBp0jZAABbCmuYgZ4479.jpg
看一下执行结果吧
wKiom1OxaUfhe27WAASnOa5-6mA978.jpg
想必大伙都看到了，楼主在前面tasks里面定义的tags标签，那在roles里咋用tags呢
请看
wKioL1Oxae6w9s6jAABqY8N3GCM369.jpg
执行一下。有以下，结果！
wKiom1OxakqQtRy9AARt6etBneU886.jpg
OK，下班回家了。