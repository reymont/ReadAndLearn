

# golang HTTP基本认证机制

* [golang HTTP基本认证机制 - 豆蔻 - 让分享自由自在! ](http://www.dotcoo.com/golang-http-auth)

看了<<http权威指南>>第12章HTTP基本认证机制,感觉讲的蛮详细的,写了一个小小例子测试.

请求响应过程:

==>
GET /hello HTTP/1.1
Host: 127.0.0.1:12345

<==
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="Dotcoo User Login"

==>
GET /hello HTTP/1.1
Host: 127.0.0.1:12345
Authorization: Basic YWRtaW46YWRtaW5wd2Q=

<==
HTTP/1.1 200 OK
Content-Type: text/plain; charset=utf-8
golang HTTP基本认证机制的实现

```go
package main

import (
    "fmt"
    "io"
    "net/http"
    "log"
    "encoding/base64"
    "strings"
)

// hello world, the web server
func HelloServer(w http.ResponseWriter, req *http.Request) {
    auth := req.Header.Get("Authorization")
    if auth == "" {
        w.Header().Set("WWW-Authenticate", `Basic realm="Dotcoo User Login"`)
        w.WriteHeader(http.StatusUnauthorized)
        return
    }
    fmt.Println(auth)

    auths := strings.SplitN(auth, " ", 2)
    if len(auths) != 2 {
        fmt.Println("error")
        return
    }

    authMethod := auths[0]
    authB64 := auths[1]

    switch authMethod {
    case "Basic":
        authstr, err := base64.StdEncoding.DecodeString(authB64)
        if err != nil {
            fmt.Println(err)
            io.WriteString(w, "Unauthorized!\n")
            return
        }
        fmt.Println(string(authstr))

        userPwd := strings.SplitN(string(authstr), ":", 2)
        if len(userPwd) != 2 {
            fmt.Println("error")
            return
        }

        username := userPwd[0]
        password := userPwd[1]

        fmt.Println("Username:", username)
        fmt.Println("Password:", password)
        fmt.Println()

    default:
        fmt.Println("error")
        return
    }


    io.WriteString(w, "hello, world!\n")
}

func main() {
    http.HandleFunc("/hello", HelloServer)
    err := http.ListenAndServe(":12345", nil)
    if err != nil {
        log.Fatal("ListenAndServe: ", err)
    }
}
```

# Go实战--通过basic认证的http(basic authentication)

* [Go实战--通过basic认证的http(basic authentication) - wangshubo1989的博客 - CSDN博客 ](http://blog.csdn.net/wangshubo1989/article/details/73838571)

生命不止， 继续 Go go go !!!

之前写过相关博客： 
Go实战–go中使用base64加密(The way to go)

Go实战–实现简单的restful api(The way to go)

今天就跟大家介绍一下带有basic认证的api。

何为basic authentication

In the context of a HTTP transaction, basic access authentication is a method for a HTTP user agent to provide a user name and password when making a request.

但是这种认证方式有很多的缺点： 
虽然基本认证非常容易实现，但该方案建立在以下的假设的基础上，即：客户端和服务器主机之间的连接是安全可信的。特别是，如果没有使用SSL/TLS这样的传输层安全的协议，那么以明文传输的密钥和口令很容易被拦截。该方案也同样没有对服务器返回的信息提供保护。

请各位大大稍安勿躁，今天我们先介绍一下go中使用basic认证，之后会跟大家介绍更安全的认证方式 auth2.0.

那么如何进行base64加密解密之前介绍过了：
```go
package main

import (
    "encoding/base64"
    "fmt"
)

func main() {
    s := "heal the world, make it a better place"

    encodeStd := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    s64 := base64.NewEncoding(encodeStd).EncodeToString([]byte(s))
    fmt.Println("base64.NewEncoding(encodeStd).EncodeToString")
    fmt.Println(len(s))
    fmt.Println(len(s64))
    fmt.Println(s)
    fmt.Println(s64)

    s64_std := base64.StdEncoding.EncodeToString([]byte(s))
    fmt.Println("base64.StdEncoding.EncodeToString")
    fmt.Println(len(s))
    fmt.Println(len(s64_std))
    fmt.Println(s)
    fmt.Println(s64_std)
}
```
basic 认证形如：

Authorization: Basic ZGVtbzpwQDU1dzByZA==
1
1
这里写图片描述

简单的basic认证

strings.SplitN 
记忆中，没有详细介绍过strings package，这里就啰嗦这一个方法：

func SplitN(s, sep string, n int) []string
1
1
SplitN slices s into substrings separated by sep and returns a slice of the substrings between those separators. If sep is empty, SplitN splits after each UTF-8 sequence. 
看到了吗，golang中的strings包为我们提供了强大的字符串处理能力。

```go
package main

import (
    "encoding/base64"
    "net/http"
    "strings"
)

func checkAuth(w http.ResponseWriter, r *http.Request) bool {
    s := strings.SplitN(r.Header.Get("Authorization"), " ", 2)
    if len(s) != 2 {
        return false
    }

    b, err := base64.StdEncoding.DecodeString(s[1])
    if err != nil {
        return false
    }

    pair := strings.SplitN(string(b), ":", 2)
    if len(pair) != 2 {
        return false
    }

    return pair[0] == "user" && pair[1] == "pass"
}

func main() {
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        if checkAuth(w, r) {
            w.Write([]byte("hello world!"))
            return
        }

        w.Header().Set("WWW-Authenticate", `Basic realm="MY REALM"`)
        w.WriteHeader(401)
        w.Write([]byte("401 Unauthorized\n"))
    })

    http.ListenAndServe(":8080, nil)
}
```
通过postman进行访问： 
这里写图片描述
这里写图片描述

通过第三方完成basic认证

github.com/ant0ine/go-json-rest/rest 
Go-Json-Rest is a thin layer on top of net/http that helps building RESTful JSON APIs easily. It provides fast and scalable request routing using a Trie based implementation, helpers to deal with JSON requests and responses, and middlewares for functionalities like CORS, Auth, Gzip, Status …

star:2810

go get -u github.com/ant0ine/go-json-rest/rest
应用：
```go
package main

import (
    "log"
    "net/http"

    "github.com/ant0ine/go-json-rest/rest"
)

func main() {
    api := rest.NewApi()
    api.Use(rest.DefaultDevStack...)
    api.Use(&rest.AuthBasicMiddleware{
        Realm: "my realm",
        Authenticator: func(userId string, password string) bool {
            if userId == "user" && password == "pass" {
                return true
            }E
            return false
        },
    })
    api.SetApp(rest.AppSimple(func(w rest.ResponseWriter, r *rest.Request) {
        w.WriteJson(map[string]string{"Body": "Hello World!"})
    }))
    log.Fatal(http.ListenAndServe(":8080", api.MakeHandler()))
}
```
通过postman进行访问： 
这里写图片描述

这里写图片描述

顶
1
踩