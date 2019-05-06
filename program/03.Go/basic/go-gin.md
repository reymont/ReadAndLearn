
* [go-go/gin: Gin is a web framework written in Golang. It features a Martini-like API with much better performance -- up to 40 times faster. If you need smashing performance, get yourself some Gin. ](https://github.com/go-go/gin)
* [Gin Web Framework ](https://gin-gonic.github.io/gin/)


* [go - Golang Gin "c.Param undefined (type *gin.Context has no field or method Param)" - Stack Overflow ](https://stackoverflow.com/questions/38970180/golang-gin-c-param-undefined-type-gin-context-has-no-field-or-method-param/38970414)

	
your `go get -u -v github.com/gin-gonic/gin` fetch failed: Are you having proxy or internet connection problem ? try it again – user6169399 Aug 


Edit: The OP had "vendor dir created by the Glide" with old version of package. and problem solved by removing that folder (updating vendor package).

`Note: go get never checks out or updates code stored in vendor directories.`

c.Param(key) is a shortcut for c.Params.ByName(key), see c.Param(key) Docs:

```go
// Param returns the value of the URL param.
// It is a shortcut for c.Params.ByName(key)
//        router.GET("/user/:id", func(c *gin.Context) {
//            // a GET request to /user/john
//            id := c.Param("id") // id == "john"
//        })
func (c *Context) Param(key string) string {
  return c.Params.ByName(key)
}
```
You need to update  `github.com/gin-gonic/gin` package, try:

```sh
go get -u github.com/gin-gonic/gin
```
And make sure there aren't any vendor and try remove all files and vendor dir except main.go then go build (or update your vendor package).

Your code works fine in go1.7:
```go
package main

import (
    "net/http"

    "github.com/gin-gonic/gin"
)

func main() {
    router := gin.Default()

    router.GET("/user/:name", func(c *gin.Context) {
        name := c.Param("name")
        c.String(http.StatusOK, "Hello %s", name)
    })

    router.Run(":8080")
}
```
Open in browser http://127.0.0.1:8080/user/World
output:

Hello World