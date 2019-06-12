SCM Implementation: Subversion

http://maven.apache.org/scm/scms-overview.html
http://maven.apache.org/scm/subversion.html



SCM Url
For all URLs below, we use a colon (:) as separator. If you use a colon for one of the variables (e.g. a windows path), then use a pipe (|) as separator.
scm:svn:svn://[username[:password]@]server_name[:port]/path_to_repository
scm:svn:svn+ssh://[username@]server_name[:port]/path_to_repository
scm:svn:file://[hostname]/path_to_repository
scm:svn:http://[username[:password]@]server_name[:port]/path_to_repository
scm:svn:https://[username[:password]@]server_name[:port]/path_to_repository
Examples
scm:svn:file:///svn/root/module
scm:svn:file://localhost/path_to_repository
scm:svn:file://my_server/path_to_repository
scm:svn:http://svn.apache.org/svn/root/module
scm:svn:https://username@svn.apache.org/svn/root/module
scm:svn:https://username:password@svn.apache.org/svn/root/module
Configuration directory
You can define the subversion configuration directory ('--config-dir' svn global option) in the provider configuration file or with 'maven.scm.svn.config_directory' command line parameter.
mvn -Dmaven.scm.svn.config_directory=your_configuration_directory scm:update

