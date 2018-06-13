http://www.liquibase.org/2010/05/liquibase-formatted-sql.html

Part of the changes made in the upcoming 2.0 release is supporting the ability to specify changelog files in formats other than XML.

As a proof of concept, I added the ability to write your changelog files in specially formatted SQL format rather than XML.

You can now write your changelogs like this:

--liquibase formatted sql
--changeset nvoxland:1
create table test1 (
    id int primary key,
    name varchar(255)
);

--changeset nvoxland:2
insert into test1 (id, name) values (1, 'name 1');
insert into test1 (id, name) values (2, 'name 2');

--changeset nvoxland:3 (dbms:oracle)
create sequence seq_test
which, when run, will run three separate changeSets on oracle, and two changesets on all other databases. Note that this is specifying raw SQL, not abstracted liquibase changes like “createTable” that generate different SQL depending on the target database.

You do need to have your file contain “–liquibase formatted sql” on the first line, and delineate your changelogs with the “–changeset AUTHOR:ID” lines.

After the AUTHOR:ID, you can specify any attribute normally available on the or XML tags, including:

stripComments
splitStatements
endDelimiter
runOnChange
runAlways
context
dbms
runInTransaction
failOnError
Since the formatted SQL builds the same internal changelog structure as the XML changelogs do, all the normal liquibase functionality (rollback, tag, dbdoc, updateCount, updateSQL, changelog parameters, etc.) are still available.

You can try out this new feature from the current 2.0 snapshot (http://liquibase.org/ci/latest). Let me know if you have any suggestions or problems. I am considering it an early access feature until 2.0 final is released, and there may be changes in the format of this file based on user feedback.