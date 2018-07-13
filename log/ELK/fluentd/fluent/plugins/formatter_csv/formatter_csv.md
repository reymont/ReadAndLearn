https://docs.fluentd.org/v1.0/articles/formatter_csv

The csv formatter plugin output an event as CSV.

"value1"[delimiter]"value2"[delimiter]"value3"\n
Table of Contents

Parameters
fields
delimiter (String, Optional. defaults to “,”)
force_quotes
add_newline
Example
Parameters

Common Parameters
Format section configurations
fields

type	default	version
array of string	required parameter	0.14.0
Specify output fields

delimiter (String, Optional. defaults to “,”)

type	default	version
string	,	0.14.0
Delimiter for values.

Use \t or TAB to specify tab character.

force_quotes

type	default	version
bool	true	0.14.0
If false, value won’t be framed by quotes.

add_newline

type	default	version
bool	true	0.14.12
Add \n to the result.

Example

<format>
  @type csv
  fields host,method
</format>
With this configuration:

tag:    app.event
time:   1362020400
record: {"host":"192.168.0.1","size":777,"method":"PUT"}
This incoming event is formatted to:

"192.168.0.1","PUT"\n
With force_quotes false, the result is:

192.168.0.1,PUT\n
Last updated: 2018-01-15 09:03:05 +0000