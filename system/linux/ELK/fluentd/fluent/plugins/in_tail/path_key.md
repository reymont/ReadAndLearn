

https://docs.fluentd.org/v0.12/articles/in_tail#path_key


path_key

Add watching file path to path_key field.

path /path/to/access.log
path_key tailed_path
With this config, generated events are like {"tailed_path":"/path/to/access.log","k1":"v1",...,"kN":"vN"}.