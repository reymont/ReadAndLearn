https://blog.csdn.net/zheng0518/article/details/65631205

本文链接为：http://nkcoder.github.io/2016/04/10/liquibase-in-maven-and-gradle/ ，转载请注明出处，谢谢！

LiquiBase是一个用于数据库重构和迁移的开源工具，通过日志文件的形式记录数据库的变更，然后执行日志文件中的修改，将数据库更新或回滚到一致的状态。LiquiBase的主要特点有：

支持几乎所有主流的数据库，如MySQL, PostgreSQL, Oracle, Sql Server, DB2等；
支持多开发者的协作维护；
日志文件支持多种格式，如XML, YAML, JSON, SQL等；
支持多种运行方式，如命令行、Spring集成、Maven插件、Gradle插件等；
本文首先简单介绍一下LiquiBase的changelog文件的常用标签配置，然后介绍在Maven和Gradle中集成并运行LiquiBase。

1. changelog文件格式
changelog是LiquiBase用来记录数据库的变更，一般放在CLASSPATH下，然后配置到执行路径中。

changelog支持多种格式，主要有XML/JSON/YAML/SQL，其中XML/JSON/YAML除了具体格式语法不同，节点配置很类似，SQL格式中主要记录SQL语句，这里仅给出XML格式和SQL格式的示例，更多的格式示例请参考文档

changelog.xml

<changeSet id="2" author="daniel" runOnChange="true">
    <insert tableName="contest_info">
        <column name="id">3</column>
        <column name="title">title 3</column>
        <column name="content">content 3</column>
    </insert>
</changeSet>
changelog.sql

--liquibase formatted sql
--changeset daniel:16040707
CREATE TABLE `role_authority_sum` (
  `row_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `role_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '关联role的role_id',
  `authority_sum` int(11) unsigned NOT NULL DEFAULT '0' COMMENT 'perms的值的和',
  `data_type_id` int(11) unsigned NOT NULL DEFAULT '0' COMMENT '关联data_type的id',
  PRIMARY KEY (`row_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='角色的权限值的和，如角色有RD权限，则和为2+8=10';
2. 常用的标签及命令
2.1 标签

一个<changeSet>标签对应一个变更集，由属性id、name，以及changelog的文件路径唯一标识。changelog在执行的时候并不是按照id的顺序，而是按照changeSet在changelog中出现的顺序。

LiquiBase在执行changelog时，会在数据库中插入两张表：DATABASECHANGELOG和DATABASECHANGELOGLOCK，分别记录changelog的执行日志和锁日志。

LiquiBase在执行changelog中的changeSet时，会首先查看DATABASECHANGELOG表，如果已经执行过，则会跳过（除非changeSet的runAlways属性为true，后面会介绍），如果没有执行过，则执行并记录changelog日志；

changelog中的一个changeSet对应一个事务，在changeSet执行完后commit，如果出现错误则rollback；

<changeSet>标签的主要属性有：

runAlways：即使已经执行过，仍然每次都执行；注意: 由于DATABASECHANGELOG表中还记录了changeSet的MD5校验值MD5SUM，如果changeSet的id和name没变，而内容变了，则由于MD5值变了，即使runAlways的值为True，执行也是失败的，会报错。这种情况应该使用runOnChange属性。
[ERROR] Failed to execute goal org.liquibase:liquibase-maven-plugin:3.4.2:update (default-cli) on project tx_test: Error setting up or running Liquibase: Validation Failed:
[ERROR] 1 change sets check sum
runOnChange：第一次的时候执行以及当changeSet的内容发生变化时执行。不受MD5校验值的约束。

runInTransaction：是否作为一个事务执行，默认为true。设置为false时需要小心：如果执行过程中出错了则不会rollback，数据库很可能处于不一致的状态；

<changeSet>下有一个重要的子标签<rollback>，即定义回滚的SQL语句。对于create table, rename column和add column等，LiquiBase会自动生成对应的rollback语句，而对于drop table、insert data等则需要显示定义rollback语句。

2.2 <include>与<includeAll>标签

当changelog文件越来越多时，可以使用<include>将文件管理起来，如：

<?xml version="1.0" encoding="utf-8"?>
<databaseChangeLog
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns="http://www.liquibase.org/xml/ns/dbchangelog"
    xsi:schemaLocation="http://www.liquibase.org/xml/ns/dbchangelog
    http://www.liquibase.org/xml/ns/dbchangelog/dbchangelog-3.1.xsd">
    <include file="logset-20160408/0001_authorization_init.sql" relativeToChangelogFile="true"/>
</databaseChangeLog>
<include>的file属性表示要包含的changelog文件的路径，这个文件可以是LiquiBase支持的任意格式，relativeToChangelogFile如果为true，则表示file属性表示的文件路径是相对于根changelog而不是CLASSPATH的，默认为false。

<includeAll>指定的是changelog的目录，而不是为文件，如：

<includeAll path="com/example/changelogs/"/>
注意: 目前<include>没有解决重复引用和循环引用的问题，重复引用还好，LiquiBase在执行的时候可以判断重复，而循环引用会导致无限循环，需要注意！

2.3 diff命令

diff命令用于比较数据库之间的异同。比如通过命令行执行：

java -jar liquibase.jar --driver=com.mysql.jdbc.Driver \
    --classpath=./mysql-connector-java-5.1.29.jar \
    --url=jdbc:mysql://127.0.0.1:3306/test \
    --username=root --password=passwd \
    diff \
    --referenceUrl=jdbc:mysql://127.0.0.1:3306/authorization \
    --referenceUsername=root --referencePassword=passwd
2.4 generateChangeLog

在已有的项目上使用LiquiBase，要生成当前数据库的changeset，可以采用两种方式，一种是使用数据库工具导出SQL数据，然后changelog文件以SQL格式记录即可；另一种方式就是用generateChangeLog命令，如：

liquibase --driver=com.mysql.jdbc.Driver \
      --classpath=./mysql-connector-java-5.1.29.jar \
      --changeLogFile=liquibase/db.changelog.xml \
      --url="jdbc:mysql://127.0.0.1:3306/test" \
      --username=root \
      --password=yourpass \
      generateChangeLog
不过generateChangeLog不支持以下功能：存储过程、函数以及触发器；

3. Maven集成LiquiBase
3.1 liquibase-maven-plugin的配置

Maven中集成LiquiBase，主要是配置liquibase-maven-plugin，首先给出一个示例：

<plugin>
  <groupId>org.liquibase</groupId>
  <artifactId>liquibase-maven-plugin</artifactId>
  <version>3.4.2</version>
  <configuration>
      <changeLogFile>src/main/resources/liquibase/test_changelog.xml</changeLogFile>
      <driver>com.mysql.jdbc.Driver</driver>
      <url>jdbc:mysql://127.0.0.1:3306/test</url>
      <username>root</username>
      <password>passwd</password>
  </configuration>
  <executions>
      <execution>
          <phase>process-resources</phase>
          <goals>
              <goal>update</goal>
          </goals>
      </execution>
  </executions>
</plugin>
其中<configuration>节点中的配置可以放在单独的配置文件里。

如果需要在父项目中配置子项目共享的LiquiBase配置，而各个子项目可以定义自己的配置，并覆盖父项目中的配置，则只需要在父项目的pom中将propertyFileWillOverride设置为true即可，如：

<plugin>
    <groupId>org.liquibase</groupId>
    <artifactId>liquibase-maven-plugin</artifactId>
    <version>3.4.2</version>
    <configuration>
        <propertyFileWillOverride>true</propertyFileWillOverride>
        <propertyFile>liquibase/liquibase.properties</propertyFile>
    </configuration>
</plugin>
3.2 liquibase:update

执行changelog中的变更：

$ mvn liquibase:update
3.3 liquibase:rollback

rollback有3中形式，分别是：

- rollbackCount: 表示rollback的changeset的个数；
- rollbackDate：表示rollback到指定的日期；
- rollbackTag：表示rollback到指定的tag，需要使用LiquiBase在具体的时间点打上tag；
rollbackCount比较简单，示例如：

$ mvn liquibase:rollback -Dliquibase.rollbackCount=3
rollbackDate需要注意日期的格式，必须匹配当前平台上执行DateFormat.getDateInstance()得到的格式，比如我的格式为MMM d, yyyy，示例如：

$ mvn liquibase:rollback -Dliquibase.rollbackDate="Apr 10, 2016"
rollbackTag使用tag标识，所以需要先打tag，示例如：

$ mvn liquibase:tag -Dliquibase.tag=tag20160410
然后rollback到tag20160410，如：

$ mvn liquibase:rollback -Dliquibase.rollbackTag=tag20160410
4. Gradle集成LiquiBase
首先在build.gradle中配置liquibase-gradle-plugin：

buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath "org.liquibase:liquibase-gradle-plugin:1.2.1"
        classpath "mysql:mysql-connector-java:5.1.38"
    }
}
apply plugin: 'org.liquibase.gradle'
然后在build.gradle中配置该plugin的activities，其中一个activity表示一种运行环境：

liquibase {
    activities {
        main {
            changeLogFile "src/main/resources/web-bundle-config/liquibase/main-changelog.xml"
            url "jdbc:mysql://127.0.0.1:3306/test?useUnicode=true&amp;characterEncoding=utf-8"
            username "root"
            password "yourpass"
        }
        test {
            main {
                changeLogFile "src/main/resources/web-bundle-config/liquibase/main-test-changelog.xml"
                url "jdbc:mysql://127.0.0.1:3306/test?useUnicode=true&amp;characterEncoding=utf-8"
                username "root"
                password "yourpass"
            }
        }
        runList = project.ext.runList
    }
}
比如执行main的命令为：

$ gradle update -PrunList=main
参考

Building Changelogs
How to tag a changeset in liquibase to rollback
only buildscript {} and other plugins {} script blocks are allowed before plugins {} blocks, no other statements are allowed