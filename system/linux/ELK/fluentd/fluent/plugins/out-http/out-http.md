

# https://github.com/ento/fluent-plugin-out-http

```yml
<match *>
  type http
  endpoint_url    http://localhost.local/api/
  http_method     put    # default: post
  serializer      json   # default: form
  rate_limit_msec 100    # default: 0 = no rate limiting
  raise_on_error  false  # default: true
  authentication  basic  # default: none
  username        alice  # default: ''
  password        bobpop # default: '', secret: true
</match>
```