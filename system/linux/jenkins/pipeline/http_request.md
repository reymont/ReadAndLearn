

https://jenkins.io/doc/pipeline/steps/http_request/#httprequest-perform-an-http-request-and-return-a-response-object

```groovy
        def response = httpRequest 'http://localhost:8080/jenkins/api/json?pretty=true'
        println("Status: "+response.status)
        println("Content: "+response.content)
```