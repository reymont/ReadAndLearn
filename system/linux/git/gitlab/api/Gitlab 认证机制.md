
* Gitlab 认证机制-博宝头条 

* 获取GitLab的Private Token
  * 点击Profile Settings-选择Account可以看到Private Token
  * GitLab为每个用户都分配了一个Private Token
  * 通过该token能获取到该用户下能看到的全部项目资源
* 获取Access Token流程
  * clientId和回调地址，请求GitLab的auth认证Api
  * 跳转登陆界面进行登陆
  * 确认授权
  * 回调函数获取GitLab返回的code
  * 遵循Oauth2认证机制：ClientId、code、secret、RedirectURI
  * 获取Access Token
* 获取Access Token的操作步骤
  * 输入：name和Redirect，点击save application创建一个Application。
  * 生成的Application id、secret用于Oauth2认证
* java实现OAuth2认证