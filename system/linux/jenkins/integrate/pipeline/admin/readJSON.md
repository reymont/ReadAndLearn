

https://plugins.jenkins.io/pipeline-utility-steps
https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/#readjson-read-json-from-files-in-the-workspace
安装Pipeline Utility Steps

```groovy
def props = readJSON file: 'dir/input.json'
assert props['attr1'] == 'One'
assert props.attr1 == 'One'

def props = readJSON text: '{ "key": "value" }'
assert props['key'] == 'value'
assert props.key == 'value'

def props = readJSON text: '[ "a", "b"]'
assert props[0] == 'a'
assert props[1] == 'b'
```

# net.sf.json.JSONArray

解析json之net.sf.json - CSDN博客 
http://blog.csdn.net/itlwc/article/details/38442667

org.jenkinsci.plugins.scriptsecurity.sandbox.RejectedAccessException: unclassified field net.sf.json.JSONArray size

import net.sf.json.JSONArray;  
import net.sf.json.JSONObject;  
  
