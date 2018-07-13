https://docs.fluentd.org/v1.0/articles/fluentd-ui

fluentd-ui is a browser-based fluentd and td-agent manager that supports following operations.

Install, uninstall, and upgrade Fluentd plugins
start/stop/restart fluentd process
Configure Fluentd settings such as config file content, pid file path, etc
View Fluentd log with simple error viewer
Table of Contents

Getting Started
Screenshots
Dashboard
Setting
in_tail setting
Plugin
Getting Started

If you’ve installed td-agent, you can start it by td-agent-ui start as below:

$ sudo /usr/sbin/td-agent-ui start
Puma 2.9.2 starting...
* Min threads: 0, max threads: 16
* Environment: production
* Listening on tcp://0.0.0.0:9292
Or if you use fluentd gem, install fluentd-ui via gem command at first.

$ gem install -V fluentd-ui
$ fluentd-ui start
Puma 2.9.2 starting...
* Min threads: 0, max threads: 16
* Environment: production
* Listening on tcp://0.0.0.0:9292
Then, open http://localhost:9292/ by your browser.

The default account is username=“admin” and password=“changeme”

fluentd-ui

Screenshots

(v0.3.9)

Dashboard

dashboard

Setting

setting

in_tail setting

in_tail

Plugin

plugin

ss01ss02ss03ss04ss05

Last updated: 2018-01-16 01:37:22 +0000
Versions | v1.0 (td-agent3) | v0.12 (td-agent2)