https://jenkins.io/doc/pipeline/steps/pipeline-utility-steps/#writejson-write-json-to-a-file-in-the-workspace

writeJSON: Write JSON to a file in the workspace.
Write a JSON file in the current working directory. That for example was previously read by readJSON.

Fields:
json: The JSON object to write.
file: Path to a file in the workspace to write to.
pretty (optional): Prettify the output with this number of spaces added to each level of indentation.
Example:

```groovy
def input = readJSON file: 'myfile.json'
//Do some manipulation
writeJSON file: 'output.json', json: input
// or pretty print it, indented with a configurable number of spaces
writeJSON file: 'output.json', json: input, pretty: 4
```

file
Type: String
json
Nested Choice of Objects
pretty (optional)
Type: int