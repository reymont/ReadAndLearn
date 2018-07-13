

# https://stackoverflow.com/questions/39713002/fluentd-assigning-types-to-new-field-in-filter

<filter *>
  @type record_transformer
  enable_ruby
  <record>
    year ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%Y")}
    monthnumber ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%-m")}
    monthname ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%B")}
    daynumber ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%-d")}
    dayname ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%A")}
    hour ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%-k")}
    minutes ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%-M")}
    seconds ${Time.at(Integer(record['timestamp'])/1000.0).strftime("%-S")}
  </record>
</filter>

year ${Integer(Time.at(Integer(record['timestamp'])/1000.0).strftime("%Y"))}