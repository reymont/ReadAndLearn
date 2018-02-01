SMTP 之 Nodejs 调用示例_SMTP 参考_开发指南_邮件推送-阿里云 https://help.aliyun.com/document_detail/29456.html

使用 Nodejs 通过 SMTP 协议发信

```js
// load nodemailer as follows
// npm install nodemailer --save
var nodemailer = require('nodemailer');
// create reusable transporter object using SMTP transport
var transporter = nodemailer.createTransport({
    "host": "smtpdm.aliyun.com",
    "port": 25,
    "secureConnection": true, // use SSL
    "auth": {
        "user": 'username@userdomain', // user name
        "pass": 'xxxxxxx'         // password
    }
});
// NB! No need to recreate the transporter object. You can use
// the same transporter object for all e-mails
// setup e-mail data with unicode symbols
var mailOptions = {
    from: 'NickName<username@userdomain>', // sender address mailfrom must be same with the user
    to: 'x@x.com, xx@xx.com', // list of receivers
    cc:'haha<xxx@xxx.com>', // copy for receivers
    bcc:'haha<xxxx@xxxx.com>', // secret copy for receivers
    subject: 'Hello', // Subject line
    text: 'Hello world', // plaintext body
    html: '<b>Hello world</b><img src="cid:01" style="width:200px;height:auto">', // html body
    attachments: [
        {
            filename: 'text0.txt',
            content: 'hello world!'
        },
        {
            filename: 'text1.txt',
            path: './app.js'
        },{
            filename:'test.JPG',
            path:'./Desert.jpg',
            cid:'01'
       }
    ],
};
// send mail with defined transport object
transporter.sendMail(mailOptions, function(error, info){
    if(error){
        return console.log(error);
    }
    console.log('Message sent: ' + info.response);
});
```