prometheus报警消息钉钉通知 - 深空灰 - 博客园 http://www.cnblogs.com/ssss429170331/p/7686228.html

设置prometheus 的web hook 为对应服务：

报警的配置如下，设置了web hook url，报警就会把消息发给web hookurl，但是这里的数据格式和钉钉要求的格式不一样，所以后面会加一层。

由于部署在k8s中，url 是 'http://dingding-alerts:80/'

复制代码
```yml
global:
  #已经解决
  resolve_timeout: 5m
route:
  group_by: ['job']
  group_wait: 30s
  #同一组间隔
  group_interval: 5m
  #相同报警内容间隔
  repeat_interval: 3h
  receiver: 'webhook'
receivers:
- name: 'webhook'
  webhook_configs:
  - url: 'http://dingding-alerts:80/'
```  
复制代码
 

如下python代理起一个转发的服务：

如果部署在k8s，为了能直接获取链接，需要对应url的转化，我这里设置成nodePort模式，通过设置nodeporturl来替换内网的url

复制代码
```py
# -*- coding: utf-8 -*-

from flask import Flask
from flask import request
import json
import requests

app = Flask(__name__)

def transform(text):
    textMap = json.loads(text)

    nodePorturl = 'http://XXX:30027/'
    externalURL = textMap['externalURL']
    print(externalURL)
    links =[]
    for alert in textMap['alerts']:
        print('-------------')
        time = alert['startsAt'] + ' -- ' + alert['endsAt']
        generatorURL = alert['generatorURL'];
        generatorURL = nodePorturl+generatorURL[generatorURL.index('graph'):]
        summary = alert['annotations']['summary']
        description = alert['annotations']['description']
        status = alert['status']
        title = alert['labels']['alertname']
        link = {}
        link['title'] = title
        link['text'] = status + ': ' + description
        link['messageUrl'] = generatorURL
        link['picUrl'] = ''
        links.append(link)
    return links

@app.route('/',methods=['POST'])
def send():
    if request.method == 'POST':
        post_data = request.get_data()
        alert_data(post_data)
    return "hello"

def alert_data(data):
    url = 'https://oapi.dingtalk.com/robot/send?access_token=‘XXX'
    headers = {'Content-Type': 'application/json'}
    for link in transform(data):
        send_data = {"msgtype": "link", "link": link}
        print(send_data)
        r = requests.post(url, data=json.dumps(send_data), headers=headers)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
```    
复制代码