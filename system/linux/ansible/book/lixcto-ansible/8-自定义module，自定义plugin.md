
http://blog.51cto.com/lixcto/1434604

今天看了下ansible的API，楼主一看，这玩意牛逼啊，估计ansible Tower也是根据这套API来的吧。
闲话不说，看看咋玩的吧。
咱们先看看接口的主角，ansible.runner.Runner这个类吧
wKioL1O2WUWwYLGTAARdF7vfSbg359.jpg
想必大伙也也都看到了，这个类初始化函数里面的这些参数，就是咱们要输入的参数，不过全都有默认值，看到了没，也就是说咱们只要修改我们需要改变的就OK了。  
我们想要调用这个接口，其实很简单，两步就OK了，第一步实例化ansible.runner.Runner这个类，
第二步，实例化后的对象调用run()这个函数。
咱们先举小例子，看看运行run()函数之后，返回的结果长什么样的吧
wKioL1O2Xc3wXimWAAJY7X1uG48851.jpg想必大伙也看到了，返回的结果是一个json格式的字典。
dark，指的是没返回结果的，因为salt-minion这台机器，楼主没开机，所以没返回。
contacted，这里面，有我们要的结果。 result['contacted']['stdout']是我们的输出。
OK，知道这些了。那大伙也差不多知道了，ansible这个接口是干什么的了吧？
它干的活，其实就是把ansible标准库的模块，或者咱们自己写的模块传进去，然后我们可以得到
一个字典格式的结果。 有了这个结果，我们就可以对结果进行一系列的处理了。
最重要的一点是啥呢? 有了这个接口，咱们就不用走ansible  命令行，或playbook执行这一流程了。
就可以利用这个接口，写好一个python模块，咱们自己的系统就可以直接调用这个模块，然后得到
正常情况下通过ansible命令行或playbooks才能得到的结果
。
下面再说说自定义module吧，上上一篇总结facts的时候，写了一个自定义模块的小例子。
其实ansible里面自定义模块，用bash，perl，lua,python,c++等等这些语言都可以写模块。
只要这些模块，返回一个json格式的结果给ansible就OK了。
楼主举个小例子，测试一下。
wKioL1O2bZvDvaZgAAIvq7UsI3k240.jpg
OK，看看结果吧
wKiom1O2b6vgOXu9AAEJ7p2TiUc397.jpg
当然，咱们自定义的模块入库之前，最好先测试一下。可以用ansible安装包里的一个东西测试下
wKiom1O2cKzCqWFXAABcZhA-32k367.jpg

OK，自定义模块就到这里了。关键把输入和输出给弄好，中间的过程就可以自由发挥了

最好咱们来看看，怎么自定义plugins吧。 
ansible有很多类型的插件都可以自定义，上一篇咱们总结facts的时候，楼主弄个了自定了loops插件的小例子。 loops插件也是众多类型插件中的一种。下面这个图，里面就是可以自定的插件，
以及插件，默认存放的位置。也就是说咱们，定义好插件直接丢在这些文件夹里面就OK了
wKioL1O2cXXhJPx2AAF3-FKOTAU755.jpg
楼主举个callback插件的例子吧，因为，这个插件和salt-stack里的ruturner长的差不多。
咱们ansible执行后的结果，一般来说，不都是打印到屏幕上的吗？
而callback插件，则可以接收ansible执行的结果，并安装我们的设计，把结果输出到不同的地方去。
比如说输出到文件，数据库，发邮件等。
mark一个官网callback例子的地址
https://github.com/ansible/ansible/tree/devel/plugins/callbacks
wKiom1O2gGexQSEDAAN20nirv3o152.jpg
把文件丢进/usr/share/ansible_plugins/callback_plugins/文件夹下面，咱们随便找个playbooks执行下看看结果吧
wKiom1O2gUTwf2fXAAKxN1ecN8k492.jpg
看到了没，执行了两次。。。啥原因，楼主也不知道。。。
ansible，楼主就大多数功能也测试了一遍，没啥实际需求，一直处于自娱自乐的状态，不准备搞下去了。。。
搞了两三个礼拜的salt-stack和ansible，得出一个结论，楼主python太水了。
接下来开始好好补补python了
