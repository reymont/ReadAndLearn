https://docs.fluentd.org/v1.0/articles/in_http

Example Configuration

in_http is included in Fluentd’s core. No additional installation process is required.

<source>
  @type http
  port 8888
  bind 0.0.0.0
  body_size_limit 32m
  keepalive_timeout 10s
</source>
Please see the Config File article for the basic structure and syntax of the configuration file.
Example Usage

The example below posts a record using the curl command.

$ curl -X POST -d 'json={"action":"login","user":2}'
  http://localhost:8888/test.tag.here;
Plugin helpers

parser
compat_parameters
event_loop
Parameters

Common Parameters

@type (required)

The value must be http.

port

type	default	version
integer	9880	0.14.0
The port to listen to.

bind

type	default	version
string	0.0.0.0 (all addresses)	0.14.0
The bind address to listen to.

body_size_limit

type	default	version
size	32MB	0.14.0
The size limit of the POSTed element.

keepalive_timeout

type	default	version
size	10 (seconds)	0.14.0
The timeout limit for keeping the connection alive.

add_http_headers

type	default	version
bool	false	0.14.0
Add HTTP_ prefix headers to the record.

add_remote_addr

type	default	version
bool	false	0.14.0
Add REMOTE_ADDR field to the record. The value of REMOTE_ADDR is the client’s address.

If your system set multiple X-Forwarded-For headers in the request, in_http uses first one. For example:

X-Forwarded-For: host1, host2
X-Forwarded-For: host3
If send above multiple headers, REMOTE_ADDR value is host1.

cors_allow_origins

type	default	version
array	nil(disabled)	0.14.0
White list domains for CORS.

If you set ["domain1", "domain2"] to cors_allow_origins, in_http returns 403 to access from othe domains.

<parse> directive

The format of the HTTP body. The default @type is in_http.

in_http
Accept records using json= / msgpack= style.

regexp
Specify body format by regular expression.

<parse>
  @type regexp
  expression /^(?<field1>\d+):(?<field2>\w+)$/
</parse>
If you execute following command:

$ curl -X POST -d '123456:awesome' "http://localhost:8888/test.tag.here"
then got parsed result like below:

{"field1":"123456","field2":"awesome}
json, ltsv, tsv, csv and none are also supported. Check parser plugin overview for more details.

format

Deprecated parameter. Use <parse> instead.

@log_level option

The @log_level option allows the user to set different levels of logging for each plugin. The supported log levels are: fatal, error, warn, info, debug, and trace.

Please see the logging article for further details.

Additional Features

time query parameter

If you want to pass the event time from your application, please use the time query parameter.

$ curl -X POST -d 'json={"action":"login","user":2}'
  "http://localhost:8888/test.tag.here?time=1392021185"
Batch mode

If you use default format, then you can send array type of json / msgpack to in_http.

$ curl -X POST -d 'json=[{"action":"login","user":2,"time":1392021185},{"action":"logout","user":2,"time":1392027356}]'
  http://localhost:8888/test.tag.here;
This improves the input performance by reducing HTTP access. Non default format doesn’t support batch mode yet. Here is a simple bechmark result on MacBook Pro with ruby 2.3:

json	msgpack	msgpack array(10 items)
2100 events/sec	2400 events/sec	10000 events/sec
Tested configuration and ruby script is here.

Learn More

Input Plugin Overview
FAQ

Why in_http removes ‘+’ from my log?

This is HTTP spec, not fluentd problem. You need to encode your payload properly or use multipart request. Here is ruby example:

# OK
URI.encode_www_form({json: {"message" => "foo+bar"}.to_json})

# NG
"json=#{"message" => "foo+bar"}.to_json}"
curl command example:

# OK
curl -X POST -H 'Content-Type: multipart/form-data' -F 'json={"message":"foo+bar"}' http://localhost:8888/test.tag.here

# NG
curl -X POST -F 'json={"message":"foo+bar"}' http://localhost:8888/test.tag.here