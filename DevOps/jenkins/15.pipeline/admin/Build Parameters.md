

https://github.com/jenkinsci/pipeline-plugin/blob/master/TUTORIAL.md

Build Parameters

If you have configured your pipeline to accept parameters when it is built — Build with Parameters — they are accessible as Groovy variables inside params. They are also accessible as environment variables.

Example: Using isFoo parameter defined as a boolean parameter (checkbox in the UI):

```groovy
node {
  sh "isFoo is ${params.isFoo}"
  sh 'isFoo is ' + params.isFoo
  if (params.isFoo) {
    // do something
  }
```