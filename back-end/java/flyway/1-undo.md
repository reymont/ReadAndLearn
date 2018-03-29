https://flywaydb.org/documentation/commandline/undo
https://flywaydb.org/documentation/command/undo

Undoes the most recently applied versioned migration.

undo

Usage
> flyway [options] undo
Options
Option	Required	Default	Description
url	YES		The jdbc url to use to connect to the database
driver	NO	Auto-detected based on url	The fully qualified classname of the jdbc driver to use to connect to the database
user	NO		The user to use to connect to the database
password	NO		The password to use to connect to the database
schemas	NO	default schema of the connection	Comma-separated case-sensitive list of schemas managed by Flyway.
The first schema in the list will be automatically set as the default one during the migration. It will also be the one containing the schema history table.
table	NO	flyway_schema_history	The name of Flyway's schema history table.
By default (single-schema mode) the schema history table is placed in the default schema for the connection provided by the datasource.
When the flyway.schemas property is set (multi-schema mode), the schema history table is placed in the first schema of the list.
locations	NO	filesystem:<install-dir>/sql	Comma-separated list of locations to scan recursively for migrations. The location type is determined by its prefix.
Unprefixed locations or locations starting with classpath: point to a package on the classpath and may contain both sql and java-based migrations.
Locations starting with filesystem: point to a directory on the filesystem and may only contain sql migrations.
jarDirs	NO	<install-dir>/jars	Comma-separated list of directories containing JDBC drivers and Java-based migrations
sqlMigrationPrefix	NO	V	
The file name prefix for versioned SQL migrations.

Versioned SQL migrations have the following file name structure: prefixVERSIONseparatorDESCRIPTIONsuffix , which using the defaults translates to V1.1__My_description.sql
undoSqlMigrationPrefix	NO	U	
The file name prefix for undo SQL migrations.

Undo SQL migrations are responsible for undoing the effects of the versioned migration with the same version.

They have the following file name structure: prefixVERSIONseparatorDESCRIPTIONsuffix , which using the defaults translates to U1.1__My_description.sql
repeatableSqlMigrationPrefix	NO	R	
The file name prefix for repeatable SQL migrations.

Repeatable SQL migrations have the following file name structure: prefixSeparatorDESCRIPTIONsuffix , which using the defaults translates to R__My_description.sql
sqlMigrationSeparator	NO	__	The file name separator for Sql migrations
sqlMigrationSuffixes	NO	.sql	
Comma-separated list of file name suffixes for SQL migrations.

SQL migrations have the following file name structure: prefixVERSIONseparatorDESCRIPTIONsuffix , which using the defaults translates to V1_1__My_description.sql

Multiple suffixes (like .sql,.pkg,.pkb) can be specified for easier compatibility with other tools such as editors with specific file associations.
mixed	NO	false	Whether to allow mixing transactional and non-transactional statements within the same migration
group	NO	false	Whether to group all pending migrations together in the same transaction when applying them (only recommended for databases with support for DDL transactions)
encoding	NO	UTF-8	The encoding of Sql migrations
placeholderReplacement	NO	true	Whether placeholders should be replaced
placeholders.name	NO		Placeholders to replace in Sql migrations
placeholderPrefix	NO	${	The prefix of every placeholder
placeholderSuffix	NO	}	The suffix of every placeholder
resolvers	NO		Comma-separated list of fully qualified class names of custom MigrationResolver implementations to be used in addition to the built-in ones for resolving Migrations to apply.
skipDefaultResolvers	NO	false	Whether default built-in resolvers (sql, jdbc and spring-jdbc) should be skipped. If true, only custom resolvers are used.
callbacks	NO		Comma-separated list of fully qualified class names of FlywayCallback implementations to use to hook into the Flyway lifecycle.
skipDefaultCallbacks	NO	false	Whether default built-in callbacks (sql) should be skipped. If true, only custom callbacks are used.
target	NO	previous version	The target version up to which Flyway should undo migrations. Migrations with a lower version number will be ignored.
ignoreMissingMigrations	NO	false	Ignore missing migrations when reading the schema history table. These are migrations that were performed by an older deployment of the application that are no longer available in this version. For example: we have migrations available on the classpath with versions 1.0 and 3.0. The schema history table indicates that a migration with version 2.0 (unknown to us) has also been applied. Instead of bombing out (fail fast) with an exception, a warning is logged and Flyway continues normally. This is useful for situations where one must be able to deploy a newer version of the application even though it doesn't contain migrations included with an older one anymore. Note that if the most recently applied migration is removed, Flyway has no way to know it is missing and will mark it as future instead.
ignoreFutureMigrations	NO	true	Ignore future migrations when reading the schema history table. These are migrations that were performed by a newer deployment of the application that are not yet available in this version. For example: we have migrations available on the classpath up to version 3.0. The schema history table indicates that a migration to version 4.0 (unknown to us) has already been applied. Instead of bombing out (fail fast) with an exception, a warning is logged and Flyway continues normally. This is useful for situations where one must be able to redeploy an older version of the application after the database has been migrated by a newer one.
installedBy	NO	Current database user	The username that will be recorded in the schema history table as having applied the migration
errorHandlers	NO	none	Comma-sparated list of fully qualified class names of Error Handlers for errors and warnings that occur during a migration. This can be used to customize Flyway's behavior by for example throwing another runtime exception, outputting a warning or suppressing the error instead of throwing a FlywayException. ErrorHandlers are invoked in order until one reports to have successfully handled the errors or warnings. If none do, or if none are present, Flyway falls back to its default handling of errors and warnings.
dryRunOutput	NO	Execute directly against the database	The file where to output the SQL statements of a migration dry run. If the file specified is in a non-existent directory, Flyway will create all directories and parent directories as needed. Omit to use the default mode of executing the SQL statements directly against the database.
Sample configuration
flyway.driver=org.hsqldb.jdbcDriver
flyway.url=jdbc:hsqldb:file:/db/flyway_sample
flyway.user=SA
flyway.password=mySecretPwd
flyway.schemas=schema1,schema2,schema3
flyway.table=schema_history
flyway.locations=classpath:com.mycomp.migration,database/migrations,filesystem:/sql-migrations
flyway.sqlMigrationPrefix=Migration-
flyway.undoSqlMigrationPrefix=downgrade
flyway.repeatableSqlMigrationPrefix=RRR
flyway.sqlMigrationSeparator=__
flyway.sqlMigrationSuffixes=.sql,.pkg,.pkb
flyway.encoding=ISO-8859-1
flyway.placeholderReplacement=true
flyway.placeholders.aplaceholder=value
flyway.placeholders.otherplaceholder=value123
flyway.placeholderPrefix=#[
flyway.placeholderSuffix=]
flyway.resolvers=com.mycomp.project.CustomResolver,com.mycomp.project.AnotherResolver
flyway.skipDefaultCallResolvers=false
flyway.callbacks=com.mycomp.project.CustomCallback,com.mycomp.project.AnotherCallback
flyway.skipDefaultCallbacks=false
flyway.target=5.1
flyway.mixed=false
flyway.group=false
flyway.ignoreMissingMigrations=false
flyway.ignoreFutureMigrations=false
flyway.installedBy=my-user
flyway.errorHandlers=com.mycomp.MyCustomErrorHandler,com.mycomp.AnotherErrorHandler
flyway.dryRunOutput=/my/sql/dryrun-outputfile.sql
Sample output
> flyway undo

Flyway 5.0.7 by Boxfuse

Database: jdbc:h2:file:C:\Programs\flyway-0-SNAPSHOT\flyway.db (H2 1.3)
Current version of schema "PUBLIC": 1
Undoing migration of schema "PUBLIC" to version 1 - First
Successfully undid 1 migration to schema "PUBLIC" (execution time 00:00.024s).