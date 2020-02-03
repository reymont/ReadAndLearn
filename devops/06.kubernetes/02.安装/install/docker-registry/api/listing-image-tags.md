

## Listing Image Tags

* [HTTP API V2 | Docker Documentation ](https://docs.docker.com/registry/spec/api/#listing-image-tags)

在给定的存储库下列出所有标记这个功能是必要的。可以使用以下请求检索映像存储库的标记：

```http
GET /v2/<name>/tags/list
```
响应将采用以下格式：
```http
200 OK
Content-Type: application/json

{
    "name": <name>,
    "tags": [
        <tag>,
        ...
    ]
}
```

对于有大量标记的存储库，查询的响应可能比较慢。如果预期将会有这样的结果，应该使用分页。

### 分页

对上述请求的结果可以通过添加适当的参数进行分页。通过标签分页指定相同的目录页码。我们来介绍一个简单的流程来强调有什么地方不同。

分页请求如下：
```http
GET /v2/<name>/tags/list?n=<integer>
```
上述指定一个标签的响应。结果集按字母表次序进行排序，并限制了返回结果的数量为n。这样的一个请求的响应看起来如下：
```html
200 OK
Content-Type: application/json
Link: <<url>?n=<n from the request>&last=<last tag value from previous response>>; rel="next"

{
  "name": <name>,
  "tags": [
    <tag>,
    ...
  ]
}
```
To get the next result set, a client would issue the request as follows, using the value encoded in the RFC5988 Link header:
为了获取下一个结果集，客户将请求如下，使用RFC5988链路报头编码值：
```
GET /v2/<name>/tags/list?n=<n from the request>&last=<last tag value from previous response>
```
The above process should then be repeated until the Link header is no longer set in the response. The behavior of the last parameter, the provided response result, lexical ordering and encoding of the Link header are identical to that of catalog pagination.
应该重复上述过程，直到链接头不再在响应中设置为止。最后一个参数的行为，提供的响应结果，词汇的顺序和链接标题编码，目录页码相同。