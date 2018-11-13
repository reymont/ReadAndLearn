Example 1: Get version of Jenkins

```py
import jenkins

server = jenkins.Jenkins('http://localhost:8080', username='myuser', password='mypassword')
user = server.get_whoami()
version = server.get_version()
print('Hello %s from Jenkins %s' % (user['fullName'], version))
```

## 参考

1. http://python-jenkins.readthedocs.io/en/latest/examples.html#example-1-get-version-of-jenkins