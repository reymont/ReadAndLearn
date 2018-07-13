

# https://www.fluentd.org/guides/recipes/apache-add-hostname

Adding Hostname to Event Logs (Apache httpd Example)Home Guides & Recipes Here
If Fluentd is used to collect data from many servers, it becomes less clear which event is collected from which server. In such cases, it's helpful to add the hostname data.

There are two canonical ways to do this.

Adding the "hostname" field to each event: Note that this is already done for you for in_syslog since syslog messages have hostnames.
pro: This approach is useful if you are collecting all data into the same output. For example, doing GROUP-BYs by hostnames.
con: This approach is unwieldy if different operations are performed to different hosts.
Generating event tags based on the hostname: For example, if data is collected from two servers srv1.example.com and srv2.example.com, then all the events coming from srv1.example.com have the tag access.srv1 and the ones coming from srv2.example.com have the tag access.srv2.
pro: This approach is useful if different operations need to be performed for different servers.
con: This approach can get complex if there is too much tag manipulation.
The following examples are tested on Ubuntu Precise. Also, the data source is Apache webserver access logs.

Example 1: Adding the hostname field to each event
There are many filter plugins in 3rd party that you can use. Here, we proceed with build-in record_transformer filter plugin.

Next, suppose you have the following tail input configured for Apache log files

<source>
  @type tail
  tag access
  path /var/log/apache2/access.log
  format apache2
  buffer_type file
  buffer_path /path/to/buffer
  pos_file /path/to/pos/file
</source>
Then, using record_transformer, we will add a <filter access>...</filter> block that adds a new field "hostname". record_transformer processes ${hostname} as Ruby's Socket.gethostname.

NOTE: This is a special case. Almost plugins don't process ${hostname}.

<filter access>
  @type record_transformer
  <record>
    hostname ${hostname}
  </record>
</filter>
The new events should have the "hostname" field like this.

{
  "host": "127.0.0.1",
  "user": "-",
  "method": "GET",
  "path": "/",
  "code": "200",
  "size": "140",
  "referer": "-",
  "agent": "Mozilla/5.0 (Windows...",
  "hostname": "web01.example.com"
}
Example 2: Generating event tags based on the hostname
Fluentd v1 configuration, v0.12 or later, will have more powerful syntax, including the ability to inline Ruby code snippet (See here for the details). In particular, we can use Ruby's Socket#gethostname function to dynamically configure the hostname like this:

<source>
  type tail
  tag "access.#{Socket.gethostname}"
  path /var/log/apache2/access.log
  format apache2
  buffer_type file
  buffer_path /path/to/buffer
  pos_file /path/to/pos/file
</source>
Then, start fluentd with the --use-v1-config option, this option is default since v0.12. If your hostname is web001.example.com, the above configuration becomes

<source>
  @type tail
  tag access.web001.example.com
  path /var/log/apache2/access.log
  format apache2
  buffer_type file
  buffer_path /path/to/buffer
  pos_file /path/to/pos/file
</source>
What's Next?
Interested in other data sources and output destinations? Check out the following resources:

Fluentd Data Sources
Fluentd Data Outputs