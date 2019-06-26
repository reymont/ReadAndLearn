# https://github.com/thx/RAP/wiki/deploy_manual_cn

Admin初始密码是什么？

由于密码进行了加密，所以无法直接登录。

使用管理员账号登陆的方法有很多：

建议自行注册账号，并按照上面的方式添加管理员权限即可。
随便注册个小号，设置密码例如123456，然后将该账户的密码，拷贝的admin的密码列当中。
如果亲使用源代码自行编译，可以通过设置PRIVATE_CONFIG.java中的adminPassword字段（万用密码）来进行登录。