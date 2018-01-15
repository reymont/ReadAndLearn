

https://docs.fluentd.org/v1.0/articles/filter_grep

Example Configurations

filter_grep is included in Fluentd’s core. No installation required.

<filter foo.bar>
  @type grep
  <regexp>
    key message
    pattern cool
  </regexp>
  <regexp>
    key hostname
    pattern ^web\d+\.example\.com$
  </regexp>
  <exclude>
    key message
    pattern uncool
  </exclude>
</filter>
The above example matches any event that satisfies the following conditions:

The value of the “message” field contains “cool”
The value of the “hostname” field matches web<INTEGER>.example.com.
The value of the “message” field does NOT contain “uncool”.
Hence, the following events are kept:

{"message":"It's cool outside today", "hostname":"web001.example.com"}
{"message":"That's not cool", "hostname":"web1337.example.com"}
whereas the following examples are filtered out:

{"message":"I am cool but you are uncool", "hostname":"db001.example.com"}
{"hostname":"web001.example.com"}
{"message":"It's cool outside today"}
Plugin helpers

record_accessor
Parameters

Common Parameters

<regexp> directive

Specify filtering rule. This directive contains two parameters.

key

type	default	version
string	required parameter	0.14.19
The field name to which the regular expression is applied.

This parameter supports nested field access via record_accessor syntax.

pattern

type	default	version
string	required parameter	0.14.19
The regular expression.

For example, the following filters out events unless the field “price” is a positive integer.

<regexp>
  key price
  pattern [1-9]\d*
</regexp>
The grep filter filters out UNLESS all <regexp>s are matched. Hence, if you have

<regexp>
  key price
  pattern [1-9]\d*
</regexp>
<regexp>
  key item_name
  pattern ^book_
</regexp>
unless the event’s “item_name” field starts with “book_” and the “price” field is an integer, it is filtered out.

For OR condition, you can use | operator of regular expressions. For example, if you have

<regexp>
  key item_name
  pattern (^book_|^article)
</regexp>
unless the event’s “item_name” field starts with “book” or “article”, it is filtered out.

Learn regular expressions for more patterns.

regexpN

type	version
string	0.14.0
This is deprecated parameter. Use <regexp> instead.

The “N” at the end should be replaced with an integer between 1 and 20 (ex: “regexp1”). regexpN takes two whitespace-delimited arguments.

Here is regexpN version of <regexp> example:

regexp1 price [1-9]\d*
regexp2 item_name ^book_
<exclude> directive

Specify filtering rule to reject events. This directive contains two parameters.

key

type	default	version
string	required parameter	0.14.19
The field name to which the regular expression is applied.

This parameter supports nested field access via record_accessor syntax.

pattern

type	default	version
string	required parameter	0.14.19
The regular expression.

For example, the following filters out events whose “status_code” field is 5xx.

<exclude>
  key status_code
  pattern ^5\d\d$
</exclude>
The grep filter filters out if any <exclude> is matched. Hence, if you have

<exclude>
  key status_code
  pattern ^5\d\d$
</exclude>
<exclude>
  key url
  pattern \.css$
</exclude>
Then, any event whose “status_code” is 5xx OR “url” ends with “.css” is filtered out.

excludeN

type	version
string	0.14.0
This is deprecated parameter. Use <exclude> instead.

The “N” at the end should be replaced with an integer between 1 and 20 (ex: “exclude1”). excludeN takes two whitespace-delimited arguments.

Here is excludeN version of <exclude> example:

exclude1 status_code ^5\d\d$
exclude2 url \.css$
If <regexp> and <exclude> are used together, both are applied.
Learn More

Filter Plugin Overview
record_transformer Filter Plugin