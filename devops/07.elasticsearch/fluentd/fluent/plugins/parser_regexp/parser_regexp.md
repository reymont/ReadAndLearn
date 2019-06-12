https://docs.fluentd.org/v1.0/articles/parser_regexp

The regexp parser plugin parses logs by given regexp pattern. The regexp must have at least one named capture (?<NAME>PATTERN). If the regexp has a capture named time, this is configurable via time_key parameter, it is used as the time of the event. You can specify the time format using the time_format parameter.

<parse>
  @type regexp
  expression /.../
</parse>
Table of Contents

Parameters
expression
ignorecase
multiline
Example
FAQ
How to debug my regexp pattern?
Parameters

See Parse section configurations for common parameters.

expression

type	default	version
string	required parameter	0.14.2
Regular expression for matching logs.

ignorecase

type	default	version
bool	false	0.14.2
Ignore case in matching.

multiline

type	default	version
bool	false	0.14.2
Build regular expression as a multline mode. . matches newline. See Ruby’s Regexp document

Example

<parse>
  @type regexp
  expression /^\[(?<logtime>[^\]]*)\] (?<name>[^ ]*) (?<title>[^ ]*) (?<id>\d*)$/
  time_key logtime
  time_format %Y-%m-%d %H:%M:%S %z
  types id:integer
</parse>
With this config:

[2013-02-28 12:00:00 +0900] alice engineer 1
This incoming log is parsed as:

time:
1362020400 (22013-02-28 12:00:00 +0900)

record:
{
  "name" : "alice",
  "title": "engineer",
  "id"   : 1
}
FAQ

How to debug my regexp pattern?

fluentd-ui’s in_tail editor helps your regexp testing. Another way, Fluentular is a great website to test your regexp for Fluentd configuration.

NOTE: You may hit Application Error at Fluentular due to heroku free plan limitation. Retry a few hours later or use fluentd-ui instead.