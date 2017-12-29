
# https://beego.me/docs/install
# https://beego.me/docs/install/bee.md

go get github.com/astaxie/beego
# git https 无法获取，请配置本地的 git，关闭 https 验证：
git config --global http.sslVerify false
# Go 升级,通过该方式用户可以升级 beego 框架，强烈推荐该方式：
go get -u github.com/astaxie/beego

go get github.com/beego/bee
# new 命令是新建一个 Web 项目，我们在命令行下执行 bee new <项目名> 就可以创建一个新的项目。
# 但是注意该命令必须在 $GOPATH/src 下执行。最后会在 $GOPATH/src 相应目录下生成如下目录结构的项目：
bee new myproject
# api 命令
# 上面的 new 命令是用来新建 Web 项目，不过很多用户使用 beego 来开发 API 应用。
所以这个 api 命令就是用来创建 API 应用的，执行命令之后如下所示：
bee api apiproject
