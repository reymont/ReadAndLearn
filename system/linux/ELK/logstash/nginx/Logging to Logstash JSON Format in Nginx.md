





# Logging to Logstash JSON Format in Nginx 
https://blog.pkhamre.com/logging-to-logstash-json-format-in-nginx/

Inspired by the logstash cookbook on logging to JSON-format in Apache, I made a similar nginx log_format to make nginx log to Logstash JSON-format as well. The configuration is quite similar to the Apache configuration, but nginx got more sensible variable names. The configuration below needs to be included within the http-context in nginx.
log_format logstash_json '{ "@timestamp": "$time_iso8601", '
                         '"@fields": { '
                         '"remote_addr": "$remote_addr", '
                         '"remote_user": "$remote_user", '
                         '"body_bytes_sent": "$body_bytes_sent", '
                         '"request_time": "$request_time", '
                         '"status": "$status", '
                         '"request": "$request", '
                         '"request_method": "$request_method", '
                         '"http_referrer": "$http_referer", '
                         '"http_user_agent": "$http_user_agent" } }';
Then use something like this in your server configuration.
access_log /var/log/nginx/www.example.org-access.json logstash_json;
A simple logstash.conf for demo-purposes.
input {
  file {
    path => "/var/log/nginx/www.example.org-access.json"
    type => nginx

    # This format tells logstash to expect 'logstash' json events from the file.
    format => json_event
  }
}

output {
  stdout { debug => true }
}
Running the logstash agent gives the following output.
Note: The output is “beautified” with JSONLint.
$ java -jar logstash-1.1.1-monolithic.jar agent -f logstash.conf
{
    "@source"=>"unknown",
    "@type"=>"nginx",
    "@tags"=>[],
    "@fields"=>{
        "remote_addr"=>"192.168.0.1",
        "remote_user"=>"-",
        "body_bytes_sent"=>"13988",
        "request_time"=>"0.122",
        "status"=>"200",
        "request"=>"GET /some/url HTTP/1.1",
        "request_method"=>"GET",
        "http_referrer"=>"http://www.example.org/some/url",
        "http_user_agent"=>"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.79 Safari/537.1"
    },
    "@timestamp"=>"2012-08-23T10:49:14+02:00"
}
Thanks to @jordansissel and @ripienaar for their awesome work on the apache cookbook.










