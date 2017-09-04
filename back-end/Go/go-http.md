
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [golang 中get和post请求详解](#golang-中get和post请求详解)
	* [1、get请求](#1-get请求)
	* [２、post请求](#2-post请求)
	* [３、http.NewRequest 和 Client.Do](#3-httpnewrequest-和-clientdo)
* [Go by Example: URL Parsing](#go-by-example-url-parsing)
* [Golang Web编程的Get和Post请求发送与解析](#golang-web编程的get和post请求发送与解析)
	* [一、Client-Get](#一-client-get)
	* [二、Client-Post](#二-client-post)
	* [三、Server](#三-server)
* [Http](#http)
	* [http server](#http-server)

<!-- /code_chunk_output -->

---


# golang 中get和post请求详解

* [golang 中get和post请求详解 - skh2015java的博客 - CSDN博客 ](http://blog.csdn.net/skh2015java/article/details/61422672)

今天整理了一下golang 中http请求的常用几种方式
 
## 1、get请求
(1)http.Get
func Get(url string) (resp *Response, err error) {
      return DefaultClient.Get(url)
}
 
get请求可以直接使用http.Get(url)方法进行请求，非常简单
 
例：
func httpGet() {
     resp, err := http.Get("https://open.ys7.com")
    if err != nil {
    // handle error
}
 
defer resp.Body.Close()
     body, err := ioutil.ReadAll(resp.Body)   //请求数据进行读取
       if err != nil {
            // handle error
       }
 
        fmt.Println(string(body))
}
 
(2)client.Get请求
client := &http.Client{}
client.Get(url)
 
## ２、post请求
 
  (1)http.Post()
func Post(url string, bodyType string, body io.Reader) (resp *Response, err error) {
            return DefaultClient.Post(url, bodyType, body)
}
 
参数说明：url－－请求路径
          bodyType－－为http请求消息头中的Content-Type
          body －－为请求体内容
 
例：
```go
func httpPost() {
resp, err := http.Post("https://open.ys7.com","application/x-www-form-urlencoded",strings.NewReader("name=abc"))
     if err != nil {
           fmt.Println(err)
      }
 
     defer resp.Body.Close()
     body, err := ioutil.ReadAll(resp.Body)
      if err != nil {
           // handle error
     }
 
fmt.Println(string(body))
}
```

(2)client.Post()
  client := &http.Client{}
  client.Post(url, bodyType, body)
 
 
 
 
 (3)http.PostForm
func PostForm(url string, data url.Values) (resp *Response, err error) {
         return DefaultClient.PostForm(url, data)
}
 
type Values map[string][]string        //url中的Values
 
请求参数说明：url－－请求路径
              data－－data中的keys和values可以作为request的body
 
例：
 
func httpPostForm(){
    form := url.Values{}
    form.Add("authorName", “Tom”)
     form.Add("title", “golang”)
    url=”https://open.ys7.com”
     resp,err:=http.PostForm(url,form)
      //do something
}
 
 
## ３、http.NewRequest 和 Client.Do
　这种请求可以自定义请求的method(POST,GET,PUT,DELETE等),以及需要自定义request的header等比较复杂的请求
第一步通过NewRequest新建一个request
func NewRequest(method, urlStr string, body io.Reader) {}
req,err1:=http.NewRequest(method,url,body)
 
第二步可以自定义header
       req.Header.Set(key, value string)
 
第三步发送http请求
    resp,err2:=http.DefaultClient.Do(req)
       或者使用 Client.Do请求
        client := &http.Client{}
        resp,err3:=client.Do(req)
 
   第四步　处理获取到响应信息resp

# Go by Example: URL Parsing

* [Go by Example: URL Parsing ](https://gobyexample.com/url-parsing)

> postgres://user:pass@host.com:5432/path?k=v#f

```go
package main
import "fmt"
import "net"
import "net/url"
func main() {
    s := "postgres://user:pass@host.com:5432/path?k=v#f"
    u, err := url.Parse(s)
    if err != nil {
        panic(err)
    }
    fmt.Println(u.Scheme)
    fmt.Println(u.User)
    fmt.Println(u.User.Username())
    p, _ := u.User.Password()
    fmt.Println(p)
    host, port, _ := net.SplitHostPort(u.Host)
    fmt.Println(host)
    fmt.Println(port)
    fmt.Println(u.Path)
    fmt.Println(u.Fragment)
    fmt.Println(u.RawQuery)
    m, _ := url.ParseQuery(u.RawQuery)
    fmt.Println(m)
    fmt.Println(m["k"][0])
}
$ go run url-parsing.go 
postgres
user:pass
user
pass
host.com:5432
host.com
5432
/path
f
k=v
map[k:[v]]
v
```


# Golang Web编程的Get和Post请求发送与解析

* [Golang Web编程的Get和Post请求发送与解析 - typ2004的专栏 - CSDN博客 ](http://blog.csdn.net/typ2004/article/details/38669949)

本文的是一篇入门文章，通过一个简单的例子介绍Golang的Web编程主要用到的技术。
          文章结构包括：

Client-Get 请求 
Client-Post 请求
Server 处理 Get 和 Post 数据
          在数据的封装中，我们部分采用了json，因而本文也涉及到Golang中json的编码和解码。


## 一、Client-Get


```go
package main  
  
import (  
        "fmt"  
        "net/url"  
        "net/http"  
        "io/ioutil"  
        "log"  
)  
  
func main() {  
        u, _ := url.Parse("http://localhost:9001/xiaoyue")  
        q := u.Query()  
        q.Set("username", "user")  
        q.Set("password", "passwd")  
        u.RawQuery = q.Encode()  
        res, err := http.Get(u.String());  
        if err != nil {   
              log.Fatal(err) return   
        }  
        result, err := ioutil.ReadAll(res.Body)   
        res.Body.Close()   
        if err != nil {   
              log.Fatal(err) return   
        }   
        fmt.Printf("%s", result)  
}   
```


## 二、Client-Post

```go
package main  
  
import (  
        "fmt"  
        "net/url"  
        "net/http"  
        "io/ioutil"  
        "log"  
        "bytes"  
        "encoding/json"  
)  
  
type Server struct {  
        ServerName string  
        ServerIP   string  
}  
  
type Serverslice struct {  
        Servers []Server  
        ServersID  string  
}  
  
  
func main() {  
  
        var s Serverslice  
  
        var newServer Server;  
        newServer.ServerName = "Guangzhou_VPN";  
        newServer.ServerIP = "127.0.0.1"         
        s.Servers = append(s.Servers, newServer)  
  
        s.Servers = append(s.Servers, Server{ServerName: "Shanghai_VPN", ServerIP: "127.0.0.2"})  
        s.Servers = append(s.Servers, Server{ServerName: "Beijing_VPN", ServerIP: "127.0.0.3"})  
          
        s.ServersID = "team1"  
  
        b, err := json.Marshal(s)  
        if err != nil {  
                fmt.Println("json err:", err)  
        }  
  
        body := bytes.NewBuffer([]byte(b))  
        res,err := http.Post("http://localhost:9001/xiaoyue", "application/json;charset=utf-8", body)  
        if err != nil {  
                log.Fatal(err)  
                return  
        }  
        result, err := ioutil.ReadAll(res.Body)  
        res.Body.Close()  
        if err != nil {  
                log.Fatal(err)  
                return  
        }  
        fmt.Printf("%s", result)  
}  
```

## 三、Server

```go
package main  
  
import (  
        "fmt"  
        "net/http"  
        "strings"  
        "html"  
        "io/ioutil"  
        "encoding/json"  
)  
  
type Server struct {  
        ServerName string  
        ServerIP   string  
}  
  
type Serverslice struct {  
        Servers []Server  
        ServersID  string  
}  
  
func main() {  
        http.HandleFunc("/", handler)   
        http.ListenAndServe(":9001", nil)  
}  
  
func handler(w http.ResponseWriter, r *http.Request) {   
        r.ParseForm() //解析参数，默认是不会解析的   
        fmt.Fprintf(w, "Hi, I love you %s", html.EscapeString(r.URL.Path[1:]))  
        if r.Method == "GET" {  
                fmt.Println("method:", r.Method) //获取请求的方法   
  
                fmt.Println("username", r.Form["username"])   
                fmt.Println("password", r.Form["password"])   
  
                for k, v := range r.Form {  
                        fmt.Print("key:", k, "; ")  
                        fmt.Println("val:", strings.Join(v, ""))  
                }  
        } else if r.Method == "POST" {  
                result, _:= ioutil.ReadAll(r.Body)  
                r.Body.Close()  
                fmt.Printf("%s\n", result)  
  
                //未知类型的推荐处理方法  
  
                var f interface{}  
                json.Unmarshal(result, &f)   
                m := f.(map[string]interface{})  
                for k, v := range m {  
                        switch vv := v.(type) {  
                                case string:  
                                        fmt.Println(k, "is string", vv)  
                                case int:  
                                        fmt.Println(k, "is int", vv)  
                                case float64:  
                                        fmt.Println(k,"is float64",vv)  
                                case []interface{}:  
                                        fmt.Println(k, "is an array:")  
                                        for i, u := range vv {  
                                                fmt.Println(i, u)  
                                        }  
                                default:  
                                        fmt.Println(k, "is of a type I don't know how to handle")   
                         }  
                  }  
  
                 //结构已知，解析到结构体  
  
                 var s Serverslice;  
                 json.Unmarshal([]byte(result), &s)  
  
                 fmt.Println(s.ServersID);  
    
                 for i:=0; i<len(s.Servers); i++ {  
                         fmt.Println(s.Servers[i].ServerName)  
                         fmt.Println(s.Servers[i].ServerIP)  
                 }  
        }   
}  
```


# Http

*   [Golang http.NewRequest POST模拟登陆](http://www.wangshangyou.com/go/124.html?utm_source=tuicool&utm_medium=referral)
*   [golang Http Request - webyh的个人页面](https://my.oschina.net/yang1992/blog/530816) （Method，RequestURI）
*   [golang几种post方式 - Go语言中文网 - Golang中文社区](http://studygolang.com/articles/4383)
*   [golang中net/http包用法 - Go知识库](http://lib.csdn.net/article/go/34318)
*   [Go和HTTPS | Tony Bai](http://tonybai.com/2015/04/30/go-and-https/) （https get）
*   [HTTPS and Go](http://www.kaihag.com/https-and-go/)
*   [Go和HTTPS | Tony Bai](http://tonybai.com/2015/04/30/go-and-https/)
*   [go - Simple GoLang SSL example - Stack Overflow](https://stackoverflow.com/questions/25807204/simple-golang-ssl-example)
*   [nginx - Using self signed SSL Certificates - Stack Overflow](https://stackoverflow.com/questions/35972742/using-self-signed-ssl-certificates)
*   [denji/golang-tls: Simple Golang HTTPS/TLS Examples](https://github.com/denji/golang-tls)
*   [ssl - golang: How to do a https request with bad certificate? - Stack Overflow](https://stackoverflow.com/questions/12122159/golang-how-to-do-a-https-request-with-bad-certificate)
*   [abbot/go-http-auth: Basic and Digest HTTP Authentication for golang http](https://github.com/abbot/go-http-auth)
*   [go - authenticated http client requests from golang - Stack Overflow](https://stackoverflow.com/questions/11361431/authenticated-http-client-requests-from-golang)
*   [Golang Tip: Wrapping http.ResponseWriter for Middleware](https://upgear.io/blog/golang-tip-wrapping-http-response-writer-for-middleware/)



## http server

*   [golang http server探究（上） - tudo](https://my.oschina.net/Tudo/blog/739243)
*   [golang http server 探究(下) - tudo](https://my.oschina.net/Tudo/blog/739754)
*   [Creating A Simple Web Server With Golang | TutorialEdge.net](https://tutorialedge.net/post/golang/creating-simple-web-server-with-golang/)
*   [Golang Web编程的Get和Post请求发送与解析 - typ2004的专栏 - 博客频道 - CSDN.NET](http://blog.csdn.net/typ2004/article/details/38669949?utm_source=tuicool&utm_medium=referral)
*   [【GoLang】golang HTTP GET/POST JSON的服务端、客户端示例，包含序列化、反序列化 - junneyang - 博客园](http://www.cnblogs.com/junneyang/p/6211190.html)
*   [go - Golang http request results in EOF errors when making multiple requests successively - Stack Overflow](https://stackoverflow.com/questions/17714494/golang-http-request-results-in-eof-errors-when-making-multiple-requests-successi)