

https://jenkins.io/doc/pipeline/steps/http_request/#httprequest-perform-an-http-request-and-return-a-response-object
https://plugins.jenkins.io/http_request
https://jenkinsci.github.io/job-dsl-plugin/

```groovy
        def response = httpRequest 'http://localhost:8080/jenkins/api/json?pretty=true'
        println("Status: "+response.status)
        println("Content: "+response.content)
```

```groovy
job('example') {
    steps {
        httpRequest('http://www.example.com') {
            httpMode('POST')
            authentication('Credentials')
            returnCodeBuildRelevant()
            logResponseBody()
        }
    }
}
```