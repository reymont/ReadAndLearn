


# js判断为空Null与字符串为空简写方法

* [js判断为空Null与字符串为空简写方法_javascript技巧_脚本之家 ](http://www.jb51.net/article/47234.htm)

最近突然发现自己写的JavaScript代码比较臃肿，所以开始研究JavaScript的简写方法。这样一来，可以让我们的JavaScript代码看起来比较清爽，同时也可以提高我们的技术。那么判断为空怎么简写呢? 
下面就是有关判断为空的简写方法。 
代码如下 
复制代码 代码如下:

if (variable1 !== null || variable1 !== undefined || variable1 !== '') { 
var variable2 = variable1; 
} 

上面的意思是说如果variable1不是一个空对象，或者未定义，或者不等于空字符串，那么声明一个variable2变量，将variable1赋给variable2。也就是说如果variable1存在那么就将variable1的值赋给variable2，若不存在则为空字符串。如下面的简写代码。 
简写代码： 
代码如下 
复制代码 代码如下:

var variable2 = variable1 || ''; 

以下是不正确的方法： 
代码如下 
复制代码 代码如下:

var exp = null; 
if (exp == null) 
{ 
alert("is null"); 
} 

exp 为 undefined 时，也会得到与 null 相同的结果，虽然 null 和 undefined 不一样。注意：要同时判断 null 和 undefined 时可使用本法。 
代码如下 
复制代码 代码如下:

var exp = null; 
if (!exp) 
{ 
alert("is null"); 
} 

如果 exp 为 undefined，或数字零，或 false，也会得到与 null 相同的结果，虽然 null 和二者不一样。注意：要同时判断 null、undefined、数字零、false 时可使用本法。 
代码如下 
复制代码 代码如下:

var exp = null; 
if (typeof exp == "null") 
{ 
alert("is null"); 
} 

为了向下兼容，exp 为 null 时，typeof null 总返回 object，所以不能这样判断。 
代码如下 
复制代码 代码如下:

var exp = null; 
if (isNull(exp)) 
{ 
alert("is null"); 
} 

判断字符串是否为空 
s 匹配任何空白字符，包括空格、制表符、换页符等等。等价于 [ fnrtv]。 很多情况下，都是用length来直接判断字符串是否为空，如下： 
代码如下 
复制代码 代码如下:

var strings = ''; 
if (string.length == 0) 
{ 
alert('不能为空'); 
} 

但如果用户输入的是空格，制表符，换页符呢?这样的话，也是不为空的，但是这样的数据就不是我们想要的吧。 
其实可以用正则表达式来把这些“空”的符号去掉来判断的 
代码如下 
复制代码 代码如下:

var strings = ' '; 
if (strings.replace(/(^s*)|(s*$)/g, "").length ==0) 
{ 
alert('不能为空'); 
} 

s 小写的s是，匹配任何空白字符，包括空格、制表符、换页符等等。等价于 [ fnrtv]。 
判断为空怎么简写，就为大家介绍到这里，希望上面的方法能对大家有所帮助。

# javascript - var.replace is not a function

* [javascript - var.replace is not a function - Stack Overflow ](https://stackoverflow.com/questions/4775206/var-replace-is-not-a-function)

var stringValue = str.toString();
return stringValue.replace(/^\s+|\s+$/g,'');

