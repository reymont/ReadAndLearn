

python服务器端收发请求的实现代码 - CSDN博客 http://blog.csdn.net/LegenDavid/article/details/52935291

发送get/post请求
```py
# coding:utf-8  
import urllib2  
  
# 定义post的地址  
url = 'http://127.0.0.1:8765/'  
post_data = "aaaaaaaaaaaaaaa"  
  
# 提交，发送数据  
req = urllib2.urlopen(url, post_data)  
  
  
# 获取提交后返回的信息  
content = req.read()  
print content  
```

利用urllib模块可以方便的实现发送http请求.urllib的参考手册
http://docs.python.org/2/library/urllib.html
建立http服务器，处理get,post请求
```py
# coding:utf-8  
from BaseHTTPServer import HTTPServer,BaseHTTPRequestHandler  
class RequestHandler(BaseHTTPRequestHandler):  
  def _writeheaders(self):  
    print self.path  
    print self.headers  
    self.send_response(200);  
    self.send_header('Content-type','text/html');  
    self.end_headers()  
  def do_Head(self):  
    self._writeheaders()  
  def do_GET(self):  
    self._writeheaders()  
    self.wfile.write("""<!DOCTYPE HTML> 
<html lang="en-US"> 
<head> 
    <meta charset="UTF-8"> 
    <title></title> 
</head> 
<body> 
<p>this is get!</p> 
</body> 
</html>"""+str(self.headers))  
  def do_POST(self):  
    self._writeheaders()  
    length = self.headers.getheader('content-length');  
    nbytes = int(length)  
    data = self.rfile.read(nbytes)  
    self.wfile.write("""<!DOCTYPE HTML> 
<html lang="en-US"> 
<head> 
    <meta charset="UTF-8"> 
    <title></title> 
</head> 
<body> 
<p>this is put!</p> 
</body> 
</html>"""+str(self.headers)+str(self.command)+str(self.headers.dict)+data)  
addr = ('',8765)  
server = HTTPServer(addr,RequestHandler)  
server.serve_forever()
``` 
注意这里，python把response的消息体记录在了rfile中。BaseHpptServer没有实现do_POST方法，需要自己重写。之后我们新建类RequestHandler，继承自 baseHTTPServer 重写do_POST方法，读出rfile的内容即可。
但是要注意，发送端必须指定content-length.若不指定，程序就会卡在rfile.read()上，不知道读取多少。
版权声明：本文为博主原创文章，未经博主允许不得转载。