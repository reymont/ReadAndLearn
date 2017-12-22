
# https://github.com/kazegusuri/fluent-plugin-flatten-hash


Requirements

fluent-plugin-flatten-hash	fluentd	ruby
>= 0.5.0	>= 0.14.8	>= 2.1
< 0.5.0	> 0.12.0	>= 1.9
Installation

Add this line to your application's Gemfile:

gem 'fluent-plugin-flatten-hash'
And then execute:

$ bundle
Or install it yourself as:

$ gem install fluent-plugin-flatten-hash
Configuration

fluent-plugin-flatten-hash supports both Output and Filter plugin.

Output

You can set a configuration like below:

<match message>
  type flatten_hash
  add_tag_prefix flattened.
  separator _
</match>
In this configuration, if you get a following nested/complex message:

{
  "message":{
    "today":"good day",
    "tommorow":{
      "is":{
        "a":{
          "bad":"day"
        }
      }
    }
  },
  "days":[
    "2013/08/24",
    "2013/08/25"
  ]
}
The message is flattened like below:

{
  "message_today":"good day",
  "message_tommorow_is_a_bad":"day",
  "days_0":"2013/08/24",
  "days_1":"2013/08/25"
}
In order to prevent arrays from being indexed, you can use a configuration like below:

<match message>
  type flatten_hash
  add_tag_prefix flattened.
  separator _
  flatten_array false
</match>
Using the same input, you'll instead end up with a message flattened like below:

{
  "message_today":"good day",
  "message_tommorow_is_a_bad":"day",
  "days":["2013/08/24","2013/08/25"]
}
Filter

You can set a configuration like below:

<filter message>
  type flatten_hash
  separator _
</filter>

<match message>
  type stdout
</match>
Contributing

Fork it
Create your feature branch (git checkout -b my-new-feature)
Commit your changes (git commit -am 'Add some feature')
Push to the branch (git push origin my-new-feature)
Create new Pull Request
Mixins

HandleTagNameMixin
Copyright

Author	Masahiro Sano
Copyright	Copyright (c) 2013- Masahiro Sano
License	MIT License