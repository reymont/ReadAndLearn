

Linux shell if [ -n ] 正确使用方法 - CSDN博客 http://blog.csdn.net/ciky2011/article/details/37876119

if [ str1 = str2 ]　　　　　  当两个串有相同内容、长度时为真 
if [ str1 != str2 ]　　　　　 当串str1和str2不等时为真 
`if [ -n str1 ]　　　　　　 当串的长度大于0时为真(串非空) `
`if [ -z str1 ]　　　　　　　 当串的长度为0时为真(空串) `
if [ str1 ]　　　　　　　　 当串str1为非空时为真
shell 中利用 -n 来判定字符串非空。
错误用法：
ARGS=$*
if [ -n $ARGS  ]
then
   print "with argument"
fi
print " without argument"
不管传不传参数，总会进入if里面。
原因：因为不加“”时该if语句等效于if [ -n ]，shell 会把它当成if [ str1 ]来处理，-n自然不为空，所以为正。

正确用法：需要在$ARGS上加入双引号，即"$ARGS".
ARGS=$*
if [ -n "$ARGS"  ]
then
   print "with argument"
fi
print " without argument"
