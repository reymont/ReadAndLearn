mvn test单元测试执行一个类_秋天的红枫_新浪博客
http://blog.sina.com.cn/s/blog_7575fab101019zzl.html

使用 mvn test执行单元测试的时候，默认情况是把工程所有的testcase都执行一遍。

如果需要执行某一个 testcase类，可以通过下面的命令。其中-Dtest参数就是关键，参数的值为“com.package.MyTestCase” 这个是要执行的单元测试类名，需要包含package

mvn test -Dtest=com.package.MyTestCase
