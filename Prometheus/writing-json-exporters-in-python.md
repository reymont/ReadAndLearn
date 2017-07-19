原文：[Writing JSON Exporters in Python | Robust Perception ](https://www.robustperception.io/writing-json-exporters-in-python/)

#使用Python写JSON Exporter
Brian Brazil August 19, 2015

日常有一个常见的问题：是否有一种方法可以将JSON文本存储到普罗米修斯中。从任意的JSON 文档中提取有用的`指标(metrics)`是不可能的，毕竟没有现成的实现。不过，可以使用Python快速实现并产生有意义的`指标(metrics)`。

更新: Python客户端有一个新的API，更容易使用。请参考[Python编写一个Jenkins导出器](http://www.robustperception.io/writing-a-jenkins-exporter-in-python/)

假设有一个名为SVC的服务它通过HTTP产生JSON输出。
```json
{
  "requests_handled": 14324,
  "requests_duration_milliseconds": 1235257,
  "request_failures": 7,
  "documents_loaded": {
    "fast": 7,
    "slow": 60
  }
}
```
首先，安装普罗米修斯Python客户端和请求库。
```bash
pip install prometheus_client requests
```
然后就可以写一个简单的exporter。将以下内容放入一个名为`json exporter.py`的文件中：
```python
from prometheus_client import start_http_server, Metric, REGISTRY
import json
import requests
import sys
import time

class JsonCollector(object):
  def __init__(self, endpoint):
    self._endpoint = endpoint
  def collect(self):
    # Fetch the JSON
    response = json.loads(requests.get(self._endpoint).content.decode('UTF-8'))

    # Convert requests and duration to a summary in seconds
    metric = Metric('svc_requests_duration_seconds',
        'Requests time taken in seconds', 'summary')
    metric.add_sample('svc_requests_duration_seconds_count',
        value=response['requests_handled'], labels={})
    metric.add_sample('svc_requests_duration_seconds_sum',
        value=response['requests_duration_milliseconds'] / 1000.0, labels={})
    yield metric

    # Counter for the failures
    metric = Metric('svc_requests_failed_total',
       'Requests failed', 'summary')
    metric.add_sample('svc_requests_failed_total',
       value=response['request_failures'], labels={})
    yield metric

    # Metrics with labels for the documents loaded
    metric = Metric('svc_documents_loaded', 'Requests failed', 'gauge')
    for k, v in response['documents_loaded'].items():
      metric.add_sample('svc_documentes_loaded', value=v, labels={'repository': k})
    yield metric


if __name__ == '__main__':
  # Usage: json_exporter.py port endpoint
  start_http_server(int(sys.argv[1]))
  REGISTRY.register(JsonCollector(sys.argv[2]))

  while True: time.sleep(1)
```
执行代码
```python
python json_exporter.py 1234 http://host/path/to/metrics.json
```
如果访问http://localhost:1234/metrics，就可以访问到`指标(metrics)`!

#翻译阅读

##单机执行

- [reymont/prometheus-python - 码云 - 开源中国 ](https://git.oschina.net/reymont/prometheus-python)

原文中并不能直接执行，这里修改了部分代码支持直接执行。

```
python json_exporter.py
curl -XGET http://localhost:1234/metrics
```

##yield

- [关于Python中的yield - tqsummer - 博客园 ](http://www.cnblogs.com/tqsummer/archive/2010/12/27/1917927.html)
- [十二、Python的yield用法与原理 - alvine008的专栏 - CSDN博客 ](http://blog.csdn.net/alvine008/article/details/43410079)

当for第一次调用函数的时候，生成一个生成器，并且在的函数中运行该循环，直到生成第一个值。然后每次调用都会运行循环并且返回下一个值，直到没有值返回为止。

```python
>>> def g(n):
...     for i in range(n):
...             yield i **2
...
>>> for i in g(5):
...     print i,":",
...
0 : 1 : 4 : 9 : 16 :
```