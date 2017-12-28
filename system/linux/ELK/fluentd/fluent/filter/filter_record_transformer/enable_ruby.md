
# https://docs.fluentd.org/v1.0/articles/filter_record_transformer#enable_ruby

enable_ruby

type	default	version
bool	false	0.14.0
When set to true, the full Ruby syntax is enabled in the ${...} expression. The default value is false.

With true, additional variables could be used inside ${}.

record refers to the whole record.
time refers to event time as Time object, not stringanized event time.
Here is the examples:

jsonized_record ${record.to_json}
avg ${record["total"] / record["count"]}
formatted_time ${time.strftime('%Y-%m-%dT%H:%M:%S%z')}
escaped_tag ${tag.gsub('.', '-')}
last_tag ${tag_parts.last}
foo_${record["key"]} bar_${record["value"]}
nested_value ${record["payload"]["key"]}