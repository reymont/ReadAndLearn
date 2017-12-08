

https://www.elastic.co/guide/en/elasticsearch/plugins/6.0/listing-removing-updating.html

listing plugins
A list of the currently loaded plugins can be retrieved with the list option:

`sudo bin/elasticsearch-plugin list`
Alternatively, use the node-info API to find out which plugins are installed on each node in the cluster

Removing plugins
Plugins can be removed manually, by deleting the appropriate directory under plugins/, or using the public script:

`sudo bin/elasticsearch-plugin remove [pluginname]`
After a Java plugin has been removed, you will need to restart the node to complete the removal process.

By default, plugin configuration files (if any) are preserved on disk; this is so that configuration is not lost while upgrading a plugin. If you wish to purge the configuration files while removing a plugin, use -p or --purge. This can option can be used after a plugin is removed to remove any lingering configuration files.

Updating plugins
Plugins are built for a specific version of Elasticsearch, and therefore must be reinstalled each time Elasticsearch is updated.

`sudo bin/elasticsearch-plugin remove [pluginname]`
`sudo bin/elasticsearch-plugin install [pluginname]`