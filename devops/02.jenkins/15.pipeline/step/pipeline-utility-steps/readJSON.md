
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