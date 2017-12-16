

https://docs.fluentd.org/v1.0/articles/parser-plugin-overview

Here is an example with in_tail:

<source>
  @type tail
  path /path/to/input/file
  <parse>
    @type my_custom_parser
  </parse>
</source>
List of Built-in Parsers

regexp
apache2
apache_error
nginx
syslog
csv
tsv
ltsv
json
multiline
none