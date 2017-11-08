

https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/#readjson-read-json-from-files-in-the-workspace

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