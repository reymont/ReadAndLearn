HTTP Request Plugin https://jenkins.io/doc/pipeline/steps/http_request/

Usage example:

```groovy
def response = httpRequest 'http://localhost:8080/jenkins/api/json?pretty=true'
println("Status: "+response.status)
println("Content: "+response.content)
```