
https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/#-readjson- read json from files in the workspace.

readJSON: Read JSON from files in the workspace.
Reads a file in the current working directory or a String as a plain text JSON file. The returned object is a normal Map with String keys or a List of primitives or Map.

Example:

```py
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
	
file (optional)
Path to a file in the workspace from which to read the JSON data. Data could be access as an array or a map.

You can only specify file or text, not both in the same invocation.

Type: String
text (optional)
A string containing the JSON formatted data. Data could be access as an array or a map.

You can only specify file or text, not both in the same invocation.

Type: String



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
  
