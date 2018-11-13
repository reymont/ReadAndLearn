添加账户（credentials）

../jenkins/credentials/store/system/domain/_/createCredentials?json= 
{“credentials”: 
{“description”:”123456”, 
“id”:”“, 
“password”:”123456”, 
“username”:”user”, 
“scope”:”GLOBAL”, 
“$class”:”com.cloudbees.plugins.credentials.impl.UsernamePasswordCredentialsImpl”}, 
“”:”0”}

获取所有credentials

../jenkins/credentials/store/system/domain/_/api/xml?depth=1 
获取所有credentials之后解析xml文本内容即可获取想要的信息。

## 参考

1. https://blog.csdn.net/snow_114/article/details/70215530