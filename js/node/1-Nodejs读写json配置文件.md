Nodejs读写json配置文件-CSDN问答 http://ask.csdn.net/questions/673154

Nodejs读写json配置文件
jsonjsnodejsjavascriptconfig
环境：Nodejs + express
配置文件采用的json文件
需求是：在nodejs中读取并能修改本地的json配置文件。比如：配置文件
 {
    "para1":"aaa",
    "para2":"bbb",
    "para3":"ccc"
}
可以弄个类似这样的代码，就能改变这个json文件
 var config = require('./config/config.json');
config.para1 = "11111"