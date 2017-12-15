# Increase the maximum number of file descriptors
echo -e "root soft nofile 65536\nroot hard nofile 65536\n* soft nofile 65536\n* hard nofile 65536" | sudo tee -a /etc/security/limits.conf > /dev/null

sudo apt-get install ruby2.0 ruby2.0-dev

sudo gem install fluentd --no-ri --no-rdoc

fluentd --setup ./fluent
