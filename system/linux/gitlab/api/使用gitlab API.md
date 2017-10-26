
* [使用gitlab API - 简书 ](http://www.jianshu.com/p/50d58fa8bdc6)

* 实践
  * 列举项目的api
  GET /projects
  * 取得当前用户能够访问的所有项目信息
```py
#gitlab API的返回值大多是分页的, 这里将页面的内容扩展为50个(项目).
#打印了"Snack-Cherry" 这个项目的id
import requests
url = 'http://gitlab.myserver.com/api/v3/projects?private_token=XXXXXX&per_page=50'
r = requests.get(url)

data = r.json
for i in data:
    if i[u'name']=='Snack-Cherry':
        print i[u'id']
```
  * 找到了project id, 我们就可以使用这个id来访问指定的项目了.
  GET /projects/:id/repository/files

```py
url = 'http://gitlab.myserver.com//api/v3/projects/24948/repository/files?private_token=xxxx'
url = 'http://gitlab.myserver.com//api/v3/projects/24948/repository/files?private_token=XXXXX&file_path=myfolder/myfile.txt&ref=master'
r = requests.get(url)
print r.text
#解析文件内容.
data = r.json['content']
print data
#将内容转换成UTF-8或者其他可以输出的形式:
import base64
print base64.b64decode(data)
```


