# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Forwarded-For
# https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/X-Forwarded-For

The X-Forwarded-For (XFF) header is a de-facto standard header for identifying the originating IP address of a client connecting to a web server through an HTTP proxy or a load balancer. When traffic is intercepted between clients and servers, server access logs contain the IP address of the proxy or load balancer only. To see the original IP address of the client, the X-Forwarded-For request header is used.

X-Forwarded-For (XFF) 在客户端访问服务器的过程中如果需要经过HTTP代理或者负载均衡服务器，可以被用来获取最初发起请求的客户端的IP地址，这个消息首部成为事实上的标准。在消息流从客户端流向服务器的过程中被拦截的情况下，服务器端的访问日志只能记录代理服务器或者负载均衡服务器的IP地址。如果想要获得最初发起请求的客户端的IP地址的话，那么 X-Forwarded-For 就派上了用场。

这个消息首部会被用来进行调试和统计，以及生成基于位置的定制化内容，按照设计的目的，它会暴露一定的隐私和敏感信息，比如客户端的IP地址。所以在应用此消息首部的时候，需要将用户的隐私问题考虑在内。

HTTP 协议中的 Forwarded 是这个消息首部的标准化版本。

X-Forwarded-For 也是一个电子邮件相关协议中用到的首部，用来表示一封电子邮件是从其他账户转发过来的。


# https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/X-Forwarded-Host

The X-Forwarded-Host (XFH) 是一个事实上的标准首部，用来确定客户端发起的请求中使用  Host  指定的初始域名。

反向代理（如负载均衡服务器、CDN等）的域名或端口号可能会与处理请求的源头服务器有所不同，在这种情况下，X-Forwarded-Host 可以用来确定哪一个域名是最初被用来访问的。

这个消息首部会被用来进行调试和统计，以及生成基于位置的定制化内容，按照设计的目的，它会暴露一定的隐私和敏感信息，比如客户端的IP地址。所以在应用此消息首部的时候，需要将用户的隐私问题考虑在内。

HTTP 协议中的  Forwarded  是这个消息首部的标准化版本。



