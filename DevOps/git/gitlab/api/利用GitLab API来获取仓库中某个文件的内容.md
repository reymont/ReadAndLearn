
* [利用GitLab API来获取仓库中某个文件的内容 - CSDN博客 ](http://blog.csdn.net/felix_yujing/article/details/52712925)

通过GET /projects/:id/repository/files这个API来获取GitLab上指定项目id的repo里的某个文件信息（下例中项目id值为12）

然后再用python代码对返回的json结果稍作处理，提取出里面content字段对应的内容，即为文件内容

```py
#coding:utf-8

import requests
import base64

# url结构说明：
# http://Gitlab服务器地址/GitLab提供的API访问路径?private_token=xxxxxxxxxxxxx&参数名1=参数值1&参数名2=参数值2[&...参数名n=参数值n]
# 参数说明：file_path指定项目中文件的路径；ref指定分支
url = "http://my.gitlab.com/api/v3/projects/12/repository/files?private_token=4S3JrHunQH7RTTCg9e8J&file_path=mydir/myfile&ref=master"

# 获取请求该url的结果，并转换为json
result = requests.get(url)
data = result.json()

# 由于content内容是base64编码过的，所以需要先作解码处理，不然返回的是一堆字母
print base64.b64decode(data['content'])
```

每个GitLab账号都对应有一个private_token值，通过传递这个参数