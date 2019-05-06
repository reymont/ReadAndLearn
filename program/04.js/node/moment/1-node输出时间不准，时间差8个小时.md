node输出时间不准，时间差8个小时 - 简书 https://www.jianshu.com/p/665bbdba799d

new Date() 取到的时间不对，
与实际时间相差8个小时，这是因为node获取的UTC时间，浏览器输出的是本地时间
所以为为了获取本地时间 ，node应该这样获取

new Date().toLocaleString()
一、 格式化日期

1、常用的格式化日期 moment.js http://momentjs.com/
安装：

npm install moment
引用：

var moment = require('moment');
使用：

moment(item.date).format('YYYY-MM-DD');
moment(item.date).format(‘YYYY-MM-DD h:mm:ss a’)
年月日 时分秒 上/下午，要求数据存储的格式 ‘2016-03-08 09:56’
2、使用js方法 toLocalDateString和toLocalTimeString

toLocaleDateString() 
方法可根据本地时间把 Date 对象的日期部分转换为字符串，并返回结果。 
toLocaleTimeString() 
方法可根据本地时间把 Date 对象的时间部分转换为字符串，并返回结果。
另外：

toUTCString() 
方法可根据世界时 (UTC) 把 Date 对象转换为字符串，并返回结果
toGMTString() 
方法可根据格林威治时间 (GMT) 把 Date 对象转换为字符串，并返回结果。
如果对你有用，请随意打赏，你的支持将鼓励我继续创作！

作者：萤火虫de梦
链接：https://www.jianshu.com/p/665bbdba799d
來源：简书
著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。