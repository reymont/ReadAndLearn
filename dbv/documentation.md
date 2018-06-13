https://dbv.vizuina.com/documentation/

Installing

Download the latest version of the application.

Unpack the archive in the working copy directory of the project you want to use it on. Alternatively, if you don't want to store the whole application (lightweight as it is) in your revision control system, read this.

If applicable, make sure the user running the application (most often the same user that runs Apache) has write permissions on all the subdirectories of the /data directory.

IMPORTANT! Make sure your VCS is configured to ignore the /data/meta/revision file (via SVN's svn:ignore property, GIT's gitignore, etc.). This is where dbv.php stores information about the database on your machine, and you do not want your file to overwrite those of your team members. They'll probably be mad at you. Alternatively, see the next section to learn how to move the meta information directory to a separate location.
Create a copy of the config.php.sample file named config.php. Leave the sample file intact, so the other developers in your team get a copy of it when they checkout dbv.php.

IMPORTANT! If you're using a VCS other that GIT, configure it to also ignore the config.php you just created, just like you did with /data/meta/revision above. GIT users can skip this, as a .gitignore file is already included.

Enter your database access information in the config.php file. See the next section for additional configuration options, or skip directly to usage instructions.

Optional settings

Password-protecting dbv.php
dbv.php provides HTTP authentication that you can configure via the DBV_USERNAME and DBV_PASSWORD constants found in config.php. Make sure you change these default values

define('DBV_USERNAME', 'dbv');
define('DBV_PASSWORD', 'dbv');	
Installing dbv.php outside the working copy directory
Normally, you would commit the entire dbv.php installation to your VCS. However, if you don't want the extra overhead, you can install dbv.php in any location on your webserver, place, the /data directory somewhere in your working copy directory, and edit the config.php file accordingly:

define('DBV_DATA_PATH', DBV_ROOT_PATH . DS . 'data');
define('DBV_SCHEMA_PATH', DBV_DATA_PATH . DS . 'schema');
define('DBV_REVISIONS_PATH', DBV_DATA_PATH . DS . 'revisions');
define('DBV_META_PATH', DBV_DATA_PATH . DS . 'meta');	
How to use

Following is a guide on how to use dbv.php during all four of the usage scenarios:

Scenario 1: You've created a new schema object (table, views, stored procedure, etc) and want to share it with your team.

Scenario 2: Someone in your team has created a new schema object, and you want to update your database to include the new object.

Scenario 3: You have made a generic change on the database (altered a table, dropped some records, pretty much anything) and want to share the changes with your team.

Scenario 4: Someone in your team has made a change to the database, and you want to apply the same change to the database on your machine.

Pushing schema objects
A schema object can be pretty much any database entity: tables, views, stored procedures, functions, triggers, etc. Let's say you want to add a new table to the database, and share that new table with your team:

Create the table view / etc. in the database.

Access dbv.php. You will see something like this:



Notice how the On Disk column says NO right next to your new object.

Select your new object, and press the Export to disk button. You should see this message:



Commit the newly created file to your VCS.

Receiving schema objects
One of your teammates has created a new table, and you want your local database to reflect this change.

Run the update / pull command of your VCS.

Acccess dbv.php. You should see something like this:



Notice how the In DB column says NO right next to the new object.

Select the new object, and press the Push to database button. This confirmation message should appear shortly:



Creating revisions
This is where the true magic of database version control into place: revision scripts.

A revision script is just a simple SQL query that alters the database in some way. Whether it drops a column from a database, inserts some records, or does something else entirely, any operation you do on the database, even if performed using a tool like Adminer, will result in a SQL query that every team member will have to process.

For this example, let's say we are working on a simple blog engine. Until now, we have been accepting anonymous comments, but our team decided to only allow registered users to add comments from now on. Since I am the developer implementing this new feature, I get to make the required changes on the database structure too. I figure out that I will need to:

Drop the email field from the comments table.

Add a new user_id field to the comments table.

Add an index to the new user_id field, to facilitate querying.

I start up my database administration tool of choice, make the changes, and generate the following two queries:

ALTER TABLE `comments`
ADD `user_id` int(10) unsigned NOT NULL AFTER `id`,
DROP `email`;	
ALTER TABLE `comments`
ADD INDEX `user_id` (`user_id`);	
I then navigate to where I installed my copy of dbv.php, in the /data/revisions directory. I create a new subdirectory that will hold my two changes, according to my current revision number, and place the two queries in a .sql file:



You can place as many .sql files in a revision subdirectory as you like. The tipical use case is to create an .sql file for each schema object that you alter.

IMPORTANT! While the .sql file name isn't important, the subdirectory I placed it in is. Make sure the subdirectory's name is numerical, even if your VCS doesn't provide numerical revision identifiers.

After this step, I simply commit the new file to the VCS, and keep on working.

Receiving revisions
After I've commited to version control the changes I've made to the database, Mike, another developer, wants to apply those changes to his database.

Mike runs the update / pull command of our VCS, in order to receive the new files

Accessing dbv.php, the new revision is highlighted for him:



Mike presses the Run selected revisions button at the bottom of the table.

His database has now been updated, and is in the same state as mine.

Writing custom DBMS adapters

MySQL isn't your flavor of choice when it comes to database platforms? No problem, I made sure implementing your own was as easy as possible. All you have to do is create a PHP class (whose name begins with DBV_Adapter_) that implements DBV_Interface and throws DBV_Exception instances on errors. The interface code (found in /lib/adapters/Interface.php) is self-explanatory, so I will simply include it here instead of writing instructions:

interface DBV_Adapter_Interface
{
    /**
     * Connects to the database
     * @throws DBV_Exception
     */
    public function connect(
        $host = false, $port = false, $username = false, $password = false, $database_name = false
    );
 
    /**
     * Runs an SQL query
     * @throws DBV_Exception
     */
    public function query($sql);
 
    /**
     * Must return an array() that contains all the schema object names in the database
     * @example return array('articles', 'comments', 'posts')
     * @throws DBV_Exception
     * @return array()
     */
    public function getSchema();
 
    /**
     * Given a schema object name, returns the SQL query that will create 
     * that schema object on any machine running the DBMS of choice.
     * @example CREATE TABLE / CREATE PROCEDURE queries in MySQL
     * @throws DBV_Exception
     */
    public function getSchemaObject($name);
}