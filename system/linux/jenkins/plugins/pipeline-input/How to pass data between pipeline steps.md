

How to pass data between pipeline steps? – CloudBees Support 
https://support.cloudbees.com/hc/en-us/articles/208487668?q=pipeline%20input%20step

```groovy
def content
node {
  sh 'curl -s http://server/api1/resource > .resource'
  content = readFile '.resource'
}
node {
  sh "curl -s http://server/api2/${content} > .resource"
  // …
}
```