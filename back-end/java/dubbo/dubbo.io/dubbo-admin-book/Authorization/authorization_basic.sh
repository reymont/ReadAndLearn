

# http://blog.csdn.net/shuipaomo062/article/details/47020203

# 1、请求头Authorization
# 在curl 中添加请求头信息，需要用-H ，并且用“请求头属性:属性值”的格式，如
curl -H "Authorization:Basic MTIzNA=="  http://www.aaaa.com
# 2、curl的get方式，请求中带有多参数的，需要将请求中的&符号转义\&，否则只能取到第一个参数的值 ，如
curl -H "Authorization:Basic MTIzNA=="  http://www.aaaa.com?A=1\&B=2\&C=3

# http://codingstandards.iteye.com/blog/934928

# 从标准输入中读取数据，按Ctrl+D结束输入。将输入的内容编码为base64字符串输出。
echo "str" | base64
# 将字符串str+换行 编码为base64字符串输出。
echo -n "str" | base64
# 将字符串str编码为base64字符串输出。注意与上面的差别。（2011.08.01 补充）

# https://segmentfault.com/a/1190000004362731
# http://www.cnblogs.com/QLeelulu/archive/2009/11/22/1607898.html

curl -H "Authorization:Basic $(echo -n 'root:root'|base64)" http://localhost:8080
curl http://localhost:8080 -u root:root
curl http://root:root@localhost:8080