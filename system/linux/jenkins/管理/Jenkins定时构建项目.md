

* [Jenkins定时构建项目（五）_夢雨情殤_新浪博客 ](http://blog.sina.com.cn/s/blog_b5fe6b270102v7xo.html)

* 自动的来构建项目需要使用Poll SCM和Build periodically
* 在构建触发中选择这两项即可，其实他们两个就是一个自动任务，cron的语法

触发远程构建:触发远程构建
Build after other projects are built:在其他项目触发的时候触发，里面有分为三种情况，也就是其他项目构建成功、失败、或者不稳定（这个不稳定我这里还木有理解）时候触发项目
Poll SCM：定时检查源码变更（根据SCM软件的版本号），如果有更新就checkout最新code下来，然后执行构建动作。我的配置如下：
*/5 * * * * （每5分钟检查一次源码变化）
Build periodically：周期进行项目构建（它不care源码是否发生变化），我的配置如下：
0 2 * * * （每天2:00 必须build一次源码）