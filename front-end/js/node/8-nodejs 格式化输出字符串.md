

nodejs 格式化输出字符串 - CSDN博客 http://blog.csdn.net/kaitlyn2011/article/details/50471455

http://www.educity.cn/wenda/54242.html

util.format(format,[...])

　　把第一个参数用类似printf的功能格式化后,返回格式化后的字符串.

　　第一个参数是一个字符串,包含0个或者更多个占位符.每个占位符都会被相应的参数转换后的值替换.支持的占位符有:

%s - String 字符串.
%d - Number (both integer and float). 数字 包括整形和浮点型
%j - JSON.json格式
% - single percent sign ('%'). This does not consume an argument.单个百分号,这占一个占位符空间.
　　如果占位符没有对应的参数,占位符不会被替换.

　　util.format('%s:%s', 'foo'); // 'foo:%s'

如果参数比占位符多,额外的参数将会被使用util.inspect()转换成字符串.并且用空格隔开.
　　util.format('%s:%s', 'foo', 'bar', 'baz'); // 'foo:bar baz'

如果第一个参数不是一个格式化字符串(意思是不是占位符),那么util.format()将会返回一个用空格分开的字符串.每个参数都会被util.inspect()转换成字符串.
　　util.format(1, 2, 3); // '1 2 3'

util.log(string)    
　　带上时间戳输出到stdout.