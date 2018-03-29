http://www.liquibase.org/documentation/command_line.html

Liquibase Command Line

Liquibase can be run from the command line by running:

    liquibase [options] [command] [command parameters]
(Optionally, replace the liquibase command with java -jar <path-to-liquibase-jar>)

The command line migrator works well when you want to do migrations on demand, but don’t have Ant or Maven available such as on servers. The command line migrator also gives you more control over the process than the servlet listener, Ant, or Maven do, allowing you to run maintenance commands like outputting SQL and listing/releasing database changelog locks.

Any values found after the command on the command line invocation will be considered a command parameter. The command line processor will validate whether the command line parameters are allowed for the current command. If the current command does not allow command line parameters or the parameter appears to be an incorrect format, then an error message of ‘unexpected command parmeter’ will be logged and the execution will terminate.

The command line migrator also allows you to

perform rollback operations and generate rollback scripts
generate “diffs”
generate creation scripts from existing databases
generate database change documentation
If you run the command line migrator without any arguments, you will get a help message listing these available parameters:

Database Update Commands

Command	Description
update	Updates database to current version.
updateCount <value>	Applies the next <value> change sets.
updateSQL	Writes SQL to update database to current version to STDOUT.
updateCountSQL <value>	Writes SQL to apply the next <value> change sets to STDOUT.
Database Rollback Commands

Command	Description
rollback <tag>	Rolls back the database to the state it was in when the tag was applied.
rollbackToDate <date/time>	Rolls back the database to the state it was in at the given date/time.
rollbackCount <value>	Rolls back the last <value> change sets.
rollbackSQL <tag>	Writes SQL to roll back the database to the state it was in when the tag was applied to STDOUT.
rollbackToDateSQL <date/time>	Writes SQL to roll back the database to the state it was in at the given date/time version to STDOUT.
rollbackCountSQL <value>	Writes SQL to roll back the last <value> change sets to STDOUT.
futureRollbackSQL	Writes SQL to roll back the database to the current state after the changes in the changeslog have been applied.
updateTestingRollback	Updates the database, then rolls back changes before updating again.
generateChangeLog	generateChangeLog of the database to standard out. v1.8 requires the dataDir parameter currently.
Diff Commands

Command	Description
diff [diff parameters]	Writes description of differences to standard out.
diffChangeLog [diff parameters]	Writes Change Log XML to update the base database to the target database to standard out.
Documentation Commands

Command	Description
dbDoc <outputDirectory>	Generates Javadoc-like documentation based on current database and change log.
Maintenance Commands

Command	Description
tag <tag>	"Tags" the current database state for future rollback.
tagExists <tag>	Checks whether the given tag is already existing.
status	Outputs count (list if --verbose) of unrun change sets.
validate	Checks the changelog for errors.
changelogSync	Mark all changes as executed in the database.
changelogSyncSQL	Writes SQL to mark all changes as executed in the database to STDOUT.
markNextChangeSetRan	Mark the next change set as executed in the database.
listLocks	Lists who currently has locks on the database changelog.
releaseLocks	Releases all locks on the database changelog.
dropAll	Drops all database objects owned by the user. Note that functions, procedures and packages are not dropped (limitation in 1.8.1).
clearCheckSums	Removes current checksums from database. On next run checksums will be recomputed.
Required Parameters

Option	Description
--changeLogFile=<path and filename>	The changelog file to use.
--username=<value>	Database username.
--password=<value>	Database password.
--url=<value>	Database JDBC URL.
--driver=<jdbc.driver.ClassName>	Database driver class name.
Optional Parameters

Option	Description
--classpath=<value>	Classpath containing migration files and JDBC Driver.
--contexts=<value>	ChangeSet contexts to execute.
--defaultSchemaName=<schema>	Specifies the default schema to use for managed database objects and for Liquibase control tables.
--databaseClass=<custom.DatabaseImpl>	Specifies a custom Database implementation to use
--defaultsFile=</path/to/file>	File containing default option values. (default: ./liquibase.properties)
--includeSystemClasspath=<true or false>	Include the system classpath in the Liquibase classpath. (default: true)
--promptForNonLocalDatabase=<true or false>	Prompt if non-localhost databases. (default: false)
--currentDateTimeFunction=<value>	Overrides current date time function used in SQL. Useful for unsupported databases.
--logLevel=<level>	Execution log level (debug, info, warning, severe, off).
--help	Output command line parameter help.
--exportDataDir	Directory where insert statement csv files will be kept (required by generateChangeLog command).
--propertyProviderClass=<properties.ClassName>	custom Properties implementation to use
Required Diff Parameters

Option	Description
--referenceUsername=<value>	Base Database username.
--referencePassword=<value>	Base Database password.
--referenceUrl=<value>	Base Database URL.
Optional Diff Parameters

Option	Description
--referenceDriver=<jdbc.driver.ClassName>	Base Database driver class name.
Change Log Properties

Option	Description
-D<property.name>=<property.value>	Pass a name/value pair for substitution of ${} blocks in the change log(s).
Using a liquibase.properties file

If you do not want to always specify options on the command line, you can create a properties file that contains default values. By default, Liquibase will look for a file called “liquibase.properties” in the current working directory, but you can specify an alternate location with the --defaultsFile flag. If you have specified an option in a properties file and specify the same option on the command line, the value on the command line will override the properties file value.

Examples

Standard Migrator Run

java -jar liquibase.jar \
      --driver=oracle.jdbc.OracleDriver \
      --classpath=\path\to\classes:jdbcdriver.jar \
      --changeLogFile=com/example/db.changelog.xml \
      --url="jdbc:oracle:thin:@localhost:1521:oracle" \
      --username=scott \
      --password=tiger \
      update
Run Migrator pulling changelogs from a .WAR file

java -jar liquibase.jar \
      --driver=oracle.jdbc.OracleDriver \
      --classpath=website.war \
      --changeLogFile=com/example/db.changelog.xml \
      --url=jdbc:oracle:thin:@localhost:1521:oracle \
      --username=scott \
      --password=tiger \
      update
Run Migrator pulling changelogs from an .EAR file

java -jar liquibase.jar \
      --driver=oracle.jdbc.OracleDriver \
      --classpath=application.ear \
      --changeLogFile=com/example/db.changelog.xml \
      --url=jdbc:oracle:thin:@localhost:1521:oracle \
      --username=scott \
      --password=tiger
Don’t execute changesets, save SQL to /tmp/script.sql

java -jar liquibase.jar \
        --driver=oracle.jdbc.OracleDriver \
        --classpath=jdbcdriver.jar \
        --url=jdbc:oracle:thin:@localhost:1521:oracle \
        --username=scott \
        --password=tiger \
        updateSQL > /tmp/script.sql
List locks on the database change log

java -jar liquibase.jar \
        --driver=oracle.jdbc.OracleDriver \
        --classpath=jdbcdriver.jar \
        --url=jdbc:oracle:thin:@localhost:1521:oracle \
        --username=scott \
        --password=tiger \
        listLocks
Unicode

MySQL

Add url parameters useUnicode=true and characterEncoding=UTF-8 to set character encoding to utf8.

Since v5.1.3 Connector/J now auto-detects servers configured with character_set_server=utf8mb4 or treats the Java encoding utf-8 passed using characterEncoding=… as utf8mb4.

--url="jdbc:mysql://localhost/dbname?useUnicode=true&characterEncoding=UTF-8
more information about MySQL Connector J Using Character Sets and Unicode

Runs Liquibase using defaults from ./liquibase.properties

java -jar liquibase.jar update
#liquibase.properties

driver: oracle.jdbc.OracleDriver
classpath: jdbcdriver.jar
url: jdbc:oracle:thin:@localhost:1521:oracle
username: scott
password: tiger
Export Data from Database

This will export the data from the targeted database and put it in a folder “data” in a file name specified with <insert file name>.

java -jar liquibase.jar --changeLogFile="./data/<insert file name> " --diffTypes="data" generateChangeLog
Update passing changelog parameters

liquibase.bat update -Dengine=myisam