

https://dotlayer.com/extremely-fast-mysql-backup-restore-using-mydumpermyloader/

Mydumper and Myloader are utility software programs that allow you to perform extremely fast and reliable multi-threaded MySQL backup and restore which is written in the C programming language.

It was initially developed by MySQL engineers who later moved to Facebook. Mydumper is approximately 10 times faster than the mysqldump tools typically used for backups.

When it comes to backing up and restoring MySQL database, most people usually use the very popular mysqldump. Whilst, mysqldump can be very easy to use for a smaller database, it doesn’t work well with larger databases. It’s very slow for huge databases and very error prone when used for very big MySQL databases.

In this article, we discuss how to use Mydumper and Myloader to perform very fast backups and restores for MySQL. Before we begin, we want to highlight the major benefits of Mydumper below:

The main advantages of Mydumper & Myloader

Parallelism and performance – Mydumper is able to use multiple threads to perform simultaneous connections and imports at the same time.
Easier to manage output (separate files for tables, dump metadata,etc, easy to view/parse data)
Consistency – maintains snapshot across all threads, provides accurate master and slave log positions, etc
Manageability – supports PCRE for specifying database and tables inclusions and exclusions
Install mydumper on ubuntu

We are going to install Mydumper on Ubuntu using the apt-get package manager, other operating systems use their own package managers. Open the terminal and run the following command

sudo apt-get install mydumper
How to Use Mydumper

Below is the complete breakdown of the MyDumper command with the respective options and what they mean:

Syntax

mydumper [options]

Application Options:
-B, --database Database to dump
-T, --tables-list Comma delimited table list to dump (does not exclude regex option)
-o, --outputdir Directory to output files to
-s, --statement-size Attempted size of INSERT statement in bytes, default 1000000
-r, --rows Try to split tables into chunks of this many rows
-c, --compress Compress output files
-e, --build-empty-files Build dump files even if no data available from table
-x, --regex Regular expression for ‘db.table' matching
-i, --ignore-engines Comma delimited list of storage engines to ignore
-m, --no-schemas Do not dump table schemas with the data
-k, --no-locks Do not execute the temporary shared read lock. WARNING: This will cause inconsistent backups
-l, --long-query-guard Set long query timer in seconds, default 60
--kill-long-queries Kill long running queries (instead of aborting)
-b, --binlogs Get a snapshot of the binary logs as well as dump data
-D, --daemon Enable daemon mode
-I, --snapshot-interval Interval between each dump snapshot (in minutes), requires --daemon, default 60
-L, --logfile Log file name to use, by default stdout is used
-h, --host The host to connect to
-u, --user Username with privileges to run the dump
-p, --password User password
-P, --port TCP/IP port to connect to
-S, --socket UNIX domain socket file to use for connection
-t, --threads Number of threads to use, default 4
-C, --compress-protocol Use compression on the MySQL connection
-V, --version Show the program version and exit
-v, --verbose Verbosity of output, 0 = silent, 1 = errors, 2 = warnings, 3 = info, default 2
This is how you would use Mydumper for create a backup of a MySQL database, replace the variables (bash words starting with $) with the actual values. Once this process is complete you can zipup the folder and transfer it to the destination folder.

mydumper \
--database=$DB_NAME \
--host=$DB_HOST \
--user=$DB_USER \
--password=$DB_PASS \
--outputdir=$DB_DUMP \
--rows=500000 \
--compress \
--build-empty-files \
--threads=2 \
--compress-protocol
Description of Mydumper’s output data

Mydumper does not output to files, but rather to files in a directory. The --outputdir option specifies the name of the directory to use.

Related:  How to Speed Up Your WordPress Site By Disabling Smileys, Emojis and Emoticons
The output is two parts Schema. For each table in the database, a file containing the CREATE TABLE statement will be created. It will be named: dbname.tablename-schema.sql.gz. Secondly, Data, for each table with number of rows above the –rows parameter, you will have a file called:
dbname.tablename.0000n.sql.gz.

Where “n” starts with 0 up to the number of.

Below is the complete describtion of MyLoader and all the optins and theier meaning.

Usage:
  myloader [OPTION...] multi-threaded MySQL loader

Help Options:
  -?, --help                        Show help options

Application Options:
  -d, --directory                   Directory of the dump to import
  -q, --queries-per-transaction     Number of queries per transaction, default 1000
  -o, --overwrite-tables            Drop tables if they already exist
  -B, --database                    An alternative database to restore into
  -s, --source-db                   Database to restore
  -e, --enable-binlog               Enable binary logging of the restore data
  -h, --host                        The host to connect to
  -u, --user                        Username with privileges to run the dump
  -p, --password                    User password
  -P, --port                        TCP/IP port to connect to
  -S, --socket                      UNIX domain socket file to use for connection
  -t, --threads                     Number of threads to use, default 4
  -C, --compress-protocol           Use compression on the MySQL connection
  -V, --version                     Show the program version and exit
  -v, --verbose                     Verbosity of output, 0 = silent, 1 = errors, 2 = warnings, 3 = info, default 2
If you want to restore these backup you can use Myloader

myloader \
--database=$DB_NAME \
--directory=$DB_DUMP \
--queries-per-transaction=50000 \
--threads=10 \
--compress-protocol \
--verbose=3
We hope this article helped with doing MySQL backups. If you liked this article, then please subscribe to our Facebook/Twitter page for updates.