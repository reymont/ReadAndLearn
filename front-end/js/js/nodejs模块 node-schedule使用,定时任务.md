

nodejs模块 node-schedule使用,定时任务 - 意外金喜 - CSDN博客 http://blog.csdn.net/zzwwjjdj1/article/details/51898257

一. 安装
npm install node-schedule
二. 使用
例子通过定时访问url展示
首先引入2个模块和访问的方法:
[javascript] view plain copy
var http     = require('http');  
var schedule = require("node-schedule");  
[javascript] view plain copy
function httpGet(){  
   var uri = `http://120.25.169.8/before/index`;  
  http.get(uri, function(res) {   
    console.log("访问个人微博状态码: " + res.statusCode);   
  }).on('error', function(e) {   
    console.log("个人微博 error: " + e.message);   
  });  
}  
1. 确定的时间执行
比如: 2016年7月13日15:50:00 , new Date() 的时候月份要减1.
[javascript] view plain copy
var date = new Date(2016,6,13,15,50,0);  
schedule.scheduleJob(date, function(){  
  httpGet();  
});  
运行结果:

2. 秒为单位执行
比如:每5秒执行一次
[javascript] view plain copy
var rule1     = new schedule.RecurrenceRule();  
var times1    = [1,6,11,16,21,26,31,36,41,46,51,56];  
rule1.second  = times1;  
schedule.scheduleJob(rule1, function(){  
  httpGet();  
});  
运行结果:


3.以分为单位执行
比如:每5分种执行一次
[javascript] view plain copy
var rule2     = new schedule.RecurrenceRule();  
var times2    = [1,6,11,16,21,26,31,36,41,46,51,56];  
rule2.minute  = times2;  
schedule.scheduleJob(rule2, function(){  
  httpGet();  
});  
运行结果:

有500尴尬请忽略,不小心把数据库关掉了.
4.以小时为单位执行
比如:每4小时执行一次
[javascript] view plain copy
var rule3     = new schedule.RecurrenceRule();  
var times3    = [1,5,9,13,17,21];  
rule3.hour  = times3; rule1.minute = 0;  
schedule.scheduleJob(rule3, function(){  
  httpGet();  
});  
以小时的就不贴运行结果了.时间太久
5.Cron风格

[javascript] view plain copy
schedule.scheduleJob('5 * * * * *', function(){  
  httpGet();  
});  
这个代码的意思就是每分钟的5秒这个点执行


比较坑的就是如果项目中有定时任务的时候,开启多线程模式就会执行多次,不管是这个模块还是使用 setInterval,有能解决的大神请留言. 
更多详情:https://www.npmjs.com/package/node-schedule