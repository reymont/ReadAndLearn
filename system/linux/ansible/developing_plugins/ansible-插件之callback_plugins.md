

灿哥的Blog | ansible 插件之callback_plugins （实战） http://www.shencan.net/index.php/2014/07/17/ansible-%E6%8F%92%E4%BB%B6%E4%B9%8Bcallback_plugins-%EF%BC%88%E5%AE%9E%E6%88%98%EF%BC%89/

关于ansible的callback 插件前面 有一篇文章 我已经专门介绍了  。还没大概讲解了下  callback 插件的用户  以及如果想自定义 怎么编写思路啥的。今天我们就来演练下  自己下个callback 插件。

因为最近我们有这个这样的需求 。 我们用ansible 部署完东西后  我们需要发邮件 给QA 部门测试 啥的。 所有 我们这里需要写个callback 插件  去部署完后  我需要了解 整个部署过程中的 是否又错误 是否全部 部署正确啥的

 

直接上callback脚本吧

QQ20140718-1@2x

 

关于 你在什么情况下 调用 这个发邮件 前面文章已经说过 我这里先 演示 这3种情况下  就调用calllback 发邮件

写完callback 把脚本 放到 callback 目录下 （ansible.cfg 里面可以定义callback 插件的目录  脚本有执行权限）

 

下面我们来测试下 这个callback吧

我随便写paly-book 吧   让她跑的时候  出现报错 就行  （上面在runner_on_failed 的时候调用）

 

QQ20140718-2@2x

我这里 因为 /tmp/下 没有cpis.j2 这个文件 所有跑的时候 会报错

我们先来跑一下吧 我把结果 贴下

QQ20140718-3@2x

 

 

提示已经失败了  我们再去 我们的邮箱看看 是不是收到邮件了

 

QQ20140718-4@2x

 

 

如果你 仔细 看我那个脚本 你就知道 这个红色的 是怎么来的    其他他就是   解析runner 结果 res 得到的   ，前面也提到过  ansible  runner api  最终执行完后 所有的结果 都会在res 里面 你需要上面 就去解析 这个字典就行  比如输出  时间啥的 。

 

下面 演示下 正确的情况下 callback吧 。

 

我这里为了 简单 随便 写了个  最重要的就是  那个res   可以试试用runner api 跑后看看结果 再解析 你想要的部分

 

QQ20140718-5@2x

 

 

我这里 直接就把 那个res 转化成str 就发出去   自己更加自己想要的东西去解析 这个json 吧