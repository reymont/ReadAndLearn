


* [c#, string, EndsWith, 判断字符串是否以另一个字符串结尾 tutorial, example ](http://www.howsoftworks.net/csharp/string/endswith.html)

bool EndsWith(string value)
bool EndsWith(string value, StringComparison comparisonType)
bool EndsWith(string value, bool ignoreCase, CultureInfo culture)
判断字符串是否以另一个字符串结尾

参数

value	-	结尾字符串。
ignoreCase	-	是否忽略大小写。为true时忽略大小写。
comparisonType	-	指定区域、大小写和排序规则。
culture	-	指定区域相关的信息，如区域名字，书写系统，使用的日历，日期时间格式化方式。
EndsWith.cs

```cs
using System;
  
namespace net.howsoftworks
{
    class EndsWith
    {
        static void Main(string[] args)
        {
            string str = "how soft works";
            Console.WriteLine("str.EndsWith('ks') = " + str.EndsWith("ks"));
            Console.WriteLine("str.EndsWith('') = " + str.EndsWith(""));
            Console.WriteLine("str.EndsWith('soft') = " + str.EndsWith("soft"));
            
            try 
            {
                str.EndsWith(null);
            }
            catch (ArgumentNullException e)
            {
                Console.WriteLine("\n1." + e.Message);
            }
        }
    }
}
```