2@Prometheus监控 - Alertmanager报警模块
 - y_xiao_的专栏 - 博客频道 - CSDN.NET 
http://blog.csdn.net/y_xiao_/article/details/50818451

Overview
Alertmanager与Prometheus是相互分离的两个部分。Prometheus服务器根据报警规则将警报发送给Alertmanager，然后Alertmanager将silencing、inhibition、aggregation等消息通过电子邮件、PaperDuty和HipChat发送通知。
设置警报和通知的主要步骤：
•	安装配置Alertmanager
•	配置Prometheus通过-alertmanager.url标志与Alertmanager通信
•	在Prometheus中创建告警规则
Alertmanager简介及机制
Alertmanager处理由类似Prometheus服务器等客户端发来的警报，之后需要删除重复、分组，并将它们通过路由发送到正确的接收器，比如电子邮件、Slack等。Alertmanager还支持沉默和警报抑制的机制。
分组
分组是指当出现问题时，Alertmanager会收到一个单一的通知，而当系统宕机时，很有可能成百上千的警报会同时生成，这种机制在较大的中断中特别有用。
例如，当数十或数百个服务的实例在运行，网络发生故障时，有可能服务实例的一半不可达数据库。在告警规则中配置为每一个服务实例都发送警报的话，那么结果是数百警报被发送至Alertmanager。
但是作为用户只想看到单一的报警页面，同时仍然能够清楚的看到哪些实例受到影响，因此，人们通过配置Alertmanager将警报分组打包，并发送一个相对看起来紧凑的通知。
分组警报、警报时间，以及接收警报的receiver是在配置文件中通过路由树配置的。
抑制
抑制是指当警报发出后，停止重复发送由此警报引发其他错误的警报的机制。
例如，当警报被触发，通知整个集群不可达，可以配置Alertmanager忽略由该警报触发而产生的所有其他警报，这可以防止通知数百或数千与此问题不相关的其他警报。
抑制机制可以通过Alertmanager的配置文件来配置。
沉默
沉默是一种简单的特定时间静音提醒的机制。一种沉默是通过匹配器来配置，就像路由树一样。传入的警报会匹配RE，如果匹配，将不会为此警报发送通知。
沉默机制可以通过Alertmanager的Web页面进行配置。
Alertmanager的配置
Alertmanager通过命令行flag和一个配置文件进行配置。命令行flag配置不变的系统参数、配置文件定义的禁止规则、通知路由和通知接收器。
要查看所有可用的命令行flag，运行alertmanager -h。
Alertmanager在运行时加载配置，如果不能很好的形成新的配置，更改将不会被应用，并记录错误。
配置文件
要指定加载的配置文件，需要使用-config.file标志。该文件使用YAML来完成，通过下面的描述来定义。括号内的参数是可选的，对于非列表的参数的值设置为指定的缺省值。
global:
  # ResolveTimeout is the time after which an alert is declared resolved
  # if it has not been updated.
  [ resolve_timeout: <duration> | default = 5m ]

  # The default SMTP From header field.
  [ smtp_from: <tmpl_string> ]
  # The default SMTP smarthost used for sending emails.
  [ smtp_smarthost: <string> ]

  # The API URL to use for Slack notifications.
  [ slack_api_url: <string> ]

  [ pagerduty_url: <string> | default = "https://events.pagerduty.com/generic/2010-04-15/create_event.json" ]
  [ opsgenie_api_host: <string> | default = "https://api.opsgenie.com/" ]

# Files from which custom notification template definitions are read.
# The last component may use a wildcard matcher, e.g. 'templates/*.tmpl'.
templates:
  [ - <filepath> ... ]

# The root node of the routing tree.
route: <route>

# A list of notification receivers.
receivers:
  - <receiver> ...

# A list of inhibition rules.
inhibit_rules:
  [ - <inhibit_rule> ... ]
路由 route
路由块定义了路由树及其子节点。如果没有设置的话，子节点的可选配置参数从其父节点继承。
每个警报进入配置的路由树的顶级路径，顶级路径必须匹配所有警报（即没有任何形式的匹配）。然后匹配子节点。如果continue的值设置为false，它在匹配第一个孩子后就停止；如果在子节点匹配，continue的值为true，警报将继续进行后续兄弟姐妹的匹配。如果警报不匹配任何节点的任何子节点（没有匹配的子节点，或不存在），该警报基于当前节点的配置处理。
路由配置格式
[ receiver: <string> ]
[ group_by: '[' <labelname>, ... ']' ]

# Whether an alert should continue matching subsequent sibling nodes.
[ continue: <boolean> | default = false ]

# A set of equality matchers an alert has to fulfill to match the node.
match:
  [ <labelname>: <labelvalue>, ... ]

# A set of regex-matchers an alert has to fulfill to match the node.
match_re:
  [ <labelname>: <regex>, ... ]

# How long to initially wait to send a notification for a group
# of alerts. Allows to wait for an inhibiting alert to arrive or collect
# more initial alerts for the same group. (Usually ~0s to few minutes.)
[ group_wait: <duration> ]

# How long to wait before sending notification about new alerts that are
# in are added to a group of alerts for which an initial notification
# has already been sent. (Usually ~5min or more.)
[ group_interval: <duration> ]

# How long to wait before sending a notification again if it has already
# been sent successfully for an alert. (Usually ~3h or more).
[ repeat_interval: <duration> ]

# Zero or more child routes.
routes:
  [ - <route> ... ]
示例：
# The root route with all parameters, which are inherited by the child
# routes if they are not overwritten.
route:
  receiver: 'default-receiver'
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 4h
  group_by: [cluster, alertname]
  # All alerts that do not match the following child routes
  # will remain at the root node and be dispatched to 'default-receiver'.
  routes:
  # All alerts with service=mysql or service=cassandra
  # are dispatched to the database pager.
  - receiver: 'database-pager'
    group_wait: 10s
    match_re:
      service: mysql|cassandra
  # All alerts with the team=frontend label match this sub-route.
  # They are grouped by product and environment rather than cluster
  # and alertname.
  - receiver: 'frontend-pager'
    group_by: [product, environment]
    match:
      team: frontend
抑制规则 inhibit_rule
抑制规则，是存在另一组匹配器匹配的情况下，静音其他被引发警报的规则。这两个警报，必须有一组相同的标签。
抑制配置格式
# Matchers that have to be fulfilled in the alerts to be muted.
target_match:
  [ <labelname>: <labelvalue>, ... ]
target_match_re:
  [ <labelname>: <regex>, ... ]

# Matchers for which one or more alerts have to exist for the
# inhibition to take effect.
source_match:
  [ <labelname>: <labelvalue>, ... ]
source_match_re:
  [ <labelname>: <regex>, ... ]

# Labels that must have an equal value in the source and target
# alert for the inhibition to take effect.
[ equal: '[' <labelname>, ... ']' ]
接收器 receiver
顾名思义，警报接收的配置。
通用配置格式
# The unique name of the receiver.
name: <string>

# Configurations for several notification integrations.
email_configs:
  [ - <email_config>, ... ]
pagerduty_configs:
  [ - <pagerduty_config>, ... ]
slack_config:
  [ - <slack_config>, ... ]
opsgenie_configs:
  [ - <opsgenie_config>, ... ]
webhook_configs:
  [ - <webhook_config>, ... ]
邮件接收器 email_config
# Whether or not to notify about resolved alerts.
[ send_resolved: <boolean> | default = false ]

# The email address to send notifications to.
to: <tmpl_string>
# The sender address.
[ from: <tmpl_string> | default = global.smtp_from ]
# The SMTP host through which emails are sent.
[ smarthost: <string> | default = global.smtp_smarthost ]

# The HTML body of the email notification.
[ html: <tmpl_string> | default = '{{ template "email.default.html" . }}' ] 

# Further headers email header key/value pairs. Overrides any headers
# previously set by the notification implementation.
[ headers: { <string>: <tmpl_string>, ... } ]
Slack接收器 slack_config
# Whether or not to notify about resolved alerts.
[ send_resolved: <boolean> | default = true ]

# The Slack webhook URL.
[ api_url: <string> | default = global.slack_api_url ]

# The channel or user to send notifications to.
channel: <tmpl_string>

# API request data as defined by the Slack webhook API.
[ color: <tmpl_string> | default = '{{ if eq .Status "firing" }}danger{{ else }}good{{ end }}' ]
[ username: <tmpl_string> | default = '{{ template "slack.default.username" . }}'
[ title: <tmpl_string> | default = '{{ template "slack.default.title" . }}' ]
[ title_link: <tmpl_string> | default = '{{ template "slack.default.titlelink" . }}' ]
[ pretext: <tmpl_string> | default = '{{ template "slack.default.pretext" . }}' ]
[ text: <tmpl_string> | default = '{{ template "slack.default.text" . }}' ]
[ fallback: <tmpl_string> | default = '{{ template "slack.default.fallback" . }}' ]
Webhook接收器 webhook_config
# Whether or not to notify about resolved alerts.
[ send_resolved: <boolean> | default = true ]

# The endpoint to send HTTP POST requests to.
url: <string>
Alertmanager会使用以下的格式向配置端点发送HTTP POST请求：
{
  "version": "2",
  "status": "<resolved|firing>",
  "alerts": [
    {
      "labels": <object>,
      "annotations": <object>,
      "startsAt": "<rfc3339>",
      "endsAt": "<rfc3339>"
    },
    ...
  ]
}
报警规则
报警规则允许你定义基于Prometheus语言表达的报警条件，并发送报警通知到外部服务。
定义报警规则
报警规则通过以下格式定义：
ALERT <alert name>
  IF <expression>
  [ FOR <duration> ]
  [ LABELS <label set> ]
  [ ANNOTATIONS <label set> ]
FOR子句使得Prometheus等待第一个传进来的向量元素（例如高HTTP错误的实例），并计数一个警报。如果元素是active，但是没有firing的，就处于pending状态。
LABELS（标签）子句允许指定一组附加的标签附到警报上。现有的任何标签都会被覆盖，标签值可以被模板化。
ANNOTATIONS（注释）子句指定另一组未查明警报实例的标签，它们被用于存储更长的其他信息，例如警报描述或者链接，注释值可以被模板化。
报警规则示例
# Alert for any instance that is unreachable for >5 minutes.
ALERT InstanceDown
  IF up == 0
  FOR 5m
  LABELS { severity = "page" }
  ANNOTATIONS {
    summary = "Instance {{ $labels.instance }} down",
    description = "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.",
  }

# Alert for any instance that have a median request latency >1s.
ALERT APIHighRequestLatency
  IF api_http_request_latencies_second{quantile="0.5"} > 1
  FOR 1m
  ANNOTATIONS {
    summary = "High request latency on {{ $labels.instance }}",
    description = "{{ $labels.instance }} has a median request latency above 1s (current value: {{ $value }}s)",
  }
发送警报通知
Prometheus可以周期性的发送关于警报状态的信息到Alertmanager实例，然后Alertmanager调度来发送正确的通知。该Alertmanager可以通过-alertmanager.url命令行flag来配置。
