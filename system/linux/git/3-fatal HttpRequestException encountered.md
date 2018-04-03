https://blog.csdn.net/txy864/article/details/79557729

之前在windows下一段时间git push都没什么问题，最近一旦提交就会弹出 
这里写图片描述 
无论是push前先将远程仓库pull到本地仓库，还是强制push都会弹出这个问题。

网上查了一下发现是Github 禁用了TLS v1.0 and v1.1，必须更新Windows的git凭证管理器，才行。 
https://github.com/Microsoft/Git-Credential-Manager-for-Windows/releases/tag/v1.14.0