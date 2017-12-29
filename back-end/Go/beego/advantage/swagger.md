

# https://beego.me/docs/advantage/docs.md

要使得文档工作，你需要做几个事情，

第一开启应用内文档开关，在配置文件中设置：EnableDocs = true,
然后在你的 main.go 函数中引入 _ "beeapi/docs"（beego 1.7.0 之后版本不需要添加该引用）。
这样你就已经内置了 docs 在你的 API 应用中，然后你就使用 bee run -gendoc=true -downdoc=true,让我们的 API 应用跑起来，-gendoc=true 表示每次自动化的 build 文档，-downdoc=true 就会自动的下载 swagger 文档查看器


http://localhost:8080/swagger/