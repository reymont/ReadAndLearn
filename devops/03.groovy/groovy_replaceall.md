

Groovy replaceAll()方法_w3cschool
 https://www.w3cschool.cn/groovy/groovy_replaceall.html

 通过对该文本的关闭结果替换捕获的组的所有出现。
句法

void replaceAll(String regex, String replacement)
参数

regex - 此字符串要匹配的正则表达式。
replacement - 将替换找到的表达式的字符串。
返回值

此方法返回生成的String。
例子

下面是一个使用这个方法的例子 -
class Example { 
   static void main(String[] args) { 
      String a = "Hello World Hello"; 
      println(a.replaceAll("Hello","Bye")); 
      println(a.replaceAll("World","Hello"));     
   } 
}
当我们运行上面的程序，我们将得到以下结果 -
Bye World Bye 
Hello Hello Hello