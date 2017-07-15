


```logstash
filter{
#   codec=>rubydebug
    mutate{
    split=>["message"," "]
        add_field => {
            "field1" => "%{[message][0]}"
        }   
        add_field => {
            "field2" => "%{[message][1]}"
        }
        remove_field => ["message"]
    }
```

参考：
1. [logstash利用ruby语言写复杂的处理逻辑 - 小小邮电 - CSDN博客]( http://blog.csdn.net/ty_0930/article/details/52609360)