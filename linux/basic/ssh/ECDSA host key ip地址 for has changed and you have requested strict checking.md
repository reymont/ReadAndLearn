
ECDSA host key "ip地址" for has changed and you have requested strict checking. - - ITeye博客 http://1197757723.iteye.com/blog/2398053

Linux SSH登录服务器报ECDSA host key "ip地址" for has changed and you have requested strict checking错误 - 专注于移动互联网 - CSDN博客 http://blog.csdn.net/ausboyue/article/details/52775281

丨版权说明 : 《Linux SSH登录服务器报ECDSA host key "ip地址" for  has changed and you have requested strict checking错误》于当前CSDN博客和乘月网属同一原创，转载请说明出处，谢谢。

Linux SSH命令用了那么久，第一次遇到这样的错误：ECDSA host key "ip地址" for  has changed and you have requested strict checking.记录下方便记忆。
解决方案：在终端上输入以下命令：
[plain] view plain copy
ssh-keygen -R "你的远程服务器ip地址"  
目的是清除你当前机器里关于你的远程服务器的缓存和公钥信息，注意是大写的字母“R”。
原因分析：根据个人的情况，原因是我的云服务器重装了系统（清除了与我本地SSH连接协议相关信息），本地的SSH协议信息便失效了。SSH连接相同的ip地址时因有连接记录直接使用失效的协议信息去验证该ip服务器，所以会报错，使用上述命令便可以清除known_hosts里旧缓存文件。
延伸：远程服务器的ssh服务被卸载重装或ssh相关数据（协议信息）被删除也会导致这个错误。