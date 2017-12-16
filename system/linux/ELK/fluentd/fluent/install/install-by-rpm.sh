
# https://docs.fluentd.org/v0.12/articles/install-by-rpm
curl -L https://toolbelt.treasuredata.com/sh/install-redhat-td-agent2.sh | sh

# The /etc/init.d/td-agent script is provided to start, stop, or restart the agent.
$ /etc/init.d/td-agent start 
Starting td-agent: [  OK  ]
$ /etc/init.d/td-agent status
td-agent (pid  21678) is running...
# The following commands are supported:
$ /etc/init.d/td-agent start
$ /etc/init.d/td-agent stop
$ /etc/init.d/td-agent restart
$ /etc/init.d/td-agent status
# Please make sure your configuration file is located at /etc/td-agent/td-agent.conf.

# 安装plugins
# mkmf.rb can't find header files for ruby at
yum install -y ruby ruby-devel
gem install fluent-plugin-elasticsearch --no-rdoc --no-ri --version 1.9.5

cat /var/log/td-agent/td-agent.log

# Step3: Post Sample Logs via HTTP
# By default, /etc/td-agent/td-agent.conf is configured to take logs from HTTP 
# and route them to stdout (/var/log/td-agent/td-agent.log). 
curl -X POST -d 'json={"json":"message"}' http://localhost:8888/debug.test