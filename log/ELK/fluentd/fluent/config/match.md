

# https://docs.fluentd.org/v0.12/articles/config-file

(2) “match”: Tell fluentd what to do!

The “match” directive looks for events with matching tags and processes them. The most common use of the match directive is to output events to other systems (for this reason, the plugins that correspond to the match directive are called “output plugins”). Fluentd’s standard output plugins include file and forward. Let’s add those to our configuration file.

```sh
# Receive events from 24224/tcp
# This is used by log forwarding and the fluent-cat command
<source>
  @type forward
  port 24224
</source>

# http://this.host:9880/myapp.access?json={"event":"data"}
<source>
  @type http
  port 9880
</source>

# Match events tagged with "myapp.access" and
# store them to /var/log/fluent/access.%Y-%m-%d
# Of course, you can control how you partition your data
# with the time_slice_format option.
<match myapp.access>
  @type file
  path /var/log/fluent/access
</match>
```

Each match directive must include a match pattern and a type parameter. Only events with a tag matching the pattern will be sent to the output destination (in the above example, only the events with the tag “myapp.access” is matched). The type parameter specifies the output plugin to use.

Just like input sources, you can add new output destinations by writing your own plugins. For further information regarding Fluentd’s output destinations, please refer to the Output Plugin Overview article.

Match Pattern: how you control the event flow inside fluentd

The following match patterns can be used for the <match> tag.

* matches a single tag part.

For example, the pattern a.* matches a.b, but does not match a or a.b.c
** matches zero or more tag parts.

For example, the pattern a.** matches a, a.b and a.b.c
{X,Y,Z} matches X, Y, or Z, where X, Y, and Z are match patterns.

For example, the pattern {a,b} matches a and b, but does not match c
This can be used in combination with the * or ** patterns. Examples include a.{b,c}.* and a.{b,c.**}
When multiple patterns are listed inside one <match> tag (delimited by one or more whitespaces), it matches any of the listed patterns. For example:

The patterns <match a b> match a and b.
The patterns <match a.** b.*> match a, a.b, a.b.c (from the first pattern) and b.d (from the second pattern).
Match Order

Fluentd tries to match tags in the order that they appear in the config file. So if you have the following configuration:

```sh
# ** matches all tags. Bad :(
<match **>
  @type blackhole_plugin
</match>

<match myapp.access>
  @type file
  path /var/log/fluent/access
</match>
then myapp.access is never matched. Wider match patterns should be defined after tight match patterns.

<match myapp.access>
  @type file
  path /var/log/fluent/access
</match>

# Capture all unmatched tags. Good :)
<match **>
  @type blackhole_plugin
</match>
```

Of course, if you use two same patterns, second match is never matched.

If you want to send events to multiple outputs, consider out_copy plugin.