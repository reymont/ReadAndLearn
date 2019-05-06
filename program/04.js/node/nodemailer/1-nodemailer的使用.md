nodemailer的使用 - CSDN博客 http://blog.csdn.net/u013471947/article/details/47148125

最近公司的项目上要用到定时发送邮件的功能！就去自己倒腾了一下nodemailer！这个第三方包还是挺好用的！不过Gmail被强了，qq的邮件系统从0.7版本升级到1.0后就不能使用了！

本次使用到的第三方的包有：nodemailer：1.4.0；这个必须有

                                                   nodemailer-smtp-transport: 1.0.3； 用smtp协议发送需要的包

                                                   node-schedule: 0.2.9;                  nodejs定时包；

直接上代码：

var nodemailer = require('nodemailer');
var smtpTransport = require('nodemailer-smtp-transport');
var schedule = require("node-schedule");
// 在这儿我的服务器是pop的，nodemailer的官网文档上没有说到底支持pop没有，我就直接试了下smtp的方式发送邮件
// 成功了，贴出来，分享下，有错的地方请大家指正！

 var transporter = nodemailer.createTransport(smtpTransport({
    host: 'hostname',          // 主机名
    port: 25,                  // 端口号，这儿是发送邮件所以用的是25，接收端口号是110,
    auth: {                    // 不同的邮件系统的端口号不同，QQ的就是465的发送端口
        user: 'user',          // 用户名和密码，用户名不用填写@xxxx.com的后缀
        pass: 'pass'
    }
}));

function sendMailService() {

}

// from和user的名称必须一致，
// 页面的编码的问题
sendMailService.sendmail = function(recive, messageSubject, messageText) {
    transporter.sendMail({
        from: 'user@address',
        to: recive,                     // 接收人xxx@xxxx.com
        contentType: 'text/html',  
        subject: messageSubject,       // 邮件主题
        text: messageText              // 邮件内容
    });
}

/*
 * param: recive参数为邮件接收人地址， messageSubject为邮件主题，
 * messageText为邮件正文，time为邮件几秒钟发送一次，stop为停止发送标识位，为true时停止发送
 */
// 利用node-schedule第三方包执行定时任务
sendMailService.sendmailCyle = function(recive, messageSubject, messageText, stop) {
    var rule = new schedule.RecurrenceRule();
    var times = [];
    for (var i = 1; i < 60; i++) {
        times.push(i);
    }
    rule.second = times;
    var c = 0;
    var j = schedule.scheduleJob(rule, function () {
        c++;
        console.log("发送中...");
        transporter.sendMail({
            from: 'user@address',
            to: recive,
            contentType: 'text/html',
            subject: messageSubject,
            text: messageText
        });
        if(stop) {
            return;
        }
    });
}
module.exports = sendMailService;

/*
*我将发送邮件的功能封装成了一 个模块，调用的代码如下
*/
var sendMailService = require('./email-copy');

var recive = 'wanglei01@wondersgroup.com';
var subject = 'test message';
var messageText = 'this is a test message!这是一封测试邮件';
var time = 100;
var stop = false;
sendMailService.sendmail(recive, subject, messageText); // 发送一封邮件
sendMailService.sendmailCyle(recive, subject, messageText, stop); // 定时一秒一直不停发送邮件


提示：解决中文乱码的问题，因为我用的IDE是webstorm，每个IDE对文件的保存的格式都有自己的编码方式，我们收到的邮件是以UTF-8的格式打开的，只需要将IDE保存文件的方式改为UTF-8就可解决收到的邮件的乱码的问题。

nodemailer官网:     http://www.nodemailer.com/