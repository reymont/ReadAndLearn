* https://tcollignon.github.io/2017/07/10/How-To-Use-third-party-libraries-in-Jenkins-Pipeline.html
* https://jenkins.io/doc/book/pipeline/shared-libraries/#using-third-party-libraries
* http://docs.groovy-lang.org/latest/html/documentation/grape.html
* https://stackoverflow.com/questions/18036110/groovy-class-not-found
* http://docs.groovy-lang.org/latest/html/api/groovy/lang/GrabConfig.html

Jenkins Pipeline has so many features and this new way of using Jenkins it’s very powerfull. I use a lot of pipeline, and in some case I need to use a third party jar. There a many options to do that, let’s see!

The use case
My principal use case is establish a JDBC connection in Jenkins Pipeline. To do this I need the JDBC driver in the system classloader. By default it’s not the case obviously.

## Old way with Groovy
In my first implementation, I wrote this groovy code to do the job :

```groovy
import groovy.sql.Sql;

def classLoader = ClassLoader.systemClassLoader
while (classLoader.parent) {
    classLoader = classLoader.parent
}
classLoader.addURL(new File("/opt/oracle/product/11.2.0/client/jdbc/lib/ojdbc6.jar").toURL())
def sql = Sql.newInstance('jdbc:oracle:thin:@SERVER:2483/INSTANCE', 'USER', 'PASSWORD', 'oracle.jdbc.OracleDriver')
sql.execute 'select 1 from dual'
sql.close()
```

```groovy
import groovy.sql.Sql;

def classLoader = ClassLoader.systemClassLoader
while (classLoader.parent) {
	classLoader = classLoader.parent
}
classLoader.addURL(new File("/var/jenkins_home/plugins/database-mysql/WEB-INF/lib/mysql-connector-java-5.1.42.jar").toURL())
def sql = Sql.newInstance("jdbc:mysql://172.20.62.130:3306/flyway_mysql", "root", "123456", "com.mysql.jdbc.Driver")
def rows = sql.execute "select count(*) from persons;"
echo rows.dump()
sql.close()	
```

In this solution there is half the code that is technical. It is not very readable and understandable, but it works.

## New way : Groovy Grab
Thanks to @aheritier I found that we can use Groovy Grab in Jenkins to add third pary libraries. At first glance this can be a very good way to achieve this use case. The new code could be this :

```groovy
@Grab('com.oracle:ojdbc6:11.2.0.4')
import groovy.sql.Sql;

def sql = Sql.newInstance('jdbc:oracle:thin:@SERVER:2483/INSTANCE', 'USER', 'PASSWORD', 'oracle.jdbc.OracleDriver')
sql.execute 'select 1 from dual'
sql.close()
```
This is better than the first one : less code, no more technical code, more readable. But in fact it doesn’t work. At least in my case. Let see why.

### 1st problem : Get Jar
Groovy Grab use Ivy to manage the recovery of jars. You need to add Shared Groovy Libraries Plugin. By default it get jars from maven central, but you can specify other repositories with the annotation @GrabResolver If you are familiar with this repo, you know that Oracle Driver will not be present. Of course it commercial part etc…​ So the previous code doesn’t work and we get this kind of error :

org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
General error during conversion: Error grabbing Grapes -- [unresolved dependency: com.oracle#ojdbc6;11.2.0.4: not found]
java.lang.RuntimeException: Error grabbing Grapes -- [unresolved dependency: com.oracle#ojdbc6;11.2.0.4: not found]
at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
There are other problem if Maven central is not accessible, like in enterprise with http proxy for example. If you have a binary repository like artifactory, you must add a Ivy configuration to let Grab get jar from this repository. To do this add a grapeConfig.xml in your jenkins MASTER installation, in the $JENKINS_HOME/.groovy directory. You can generate Ivy config from the artifactory instance. An example can be :

<?xml version="1.0" encoding="UTF-8"?>
<ivy-settings
  <settings defaultResolver="downloadGrapes" />
  <credentials host="artifactoryHostname" realm="Artifactory Realm" username="user" passwd="password" />
  <resolvers>
    <chain name="downloadGrapes">
      <ibiblio name="public" m2compatible="true" root="http://artifactoryHostname/artifactory/libs-release" />
    </chain>
  </resolvers>
</ivy-settings>
You need to restart Jenkins MASTER to load new _grapeConfig.xml" file.
With this config, the jars we be downloading correctly and will be in the grape cache under $JENKINS_HOME/.groovy/grapes directory.

### 2nd problem : JDBC
Now we have a good configuration of Grape (and Ivy) in Jenkins, but this example still does not work. The new error is :

```java
java.sql.SQLException: No suitable driver found for jdbc:oracle:thin:@SERVER:2483/INSTANCE
at java.sql.DriverManager.getConnection(DriverManager.java:689)
at java.sql.DriverManager.getConnection(DriverManager.java:247)
at groovy.sql.Sql.newInstance(Sql.java:402)
at groovy.sql.Sql.newInstance(Sql.java:446)
at groovy.sql.Sql$newInstance.call(Unknown Source)
at org.codehaus.groovy.runtime.callsite.CallSiteArray.defaultCall(CallSiteArray.java:48)
at org.codehaus.groovy.runtime.callsite.AbstractCallSite.call(AbstractCallSite.java:113)
at com.cloudbees.groovy.cps.sandbox.DefaultInvoker.methodCall(DefaultInvoker.java:18)
```
The problem is JDBC itself, it need to be loading by the system classloader to work correctly.

### First idea : @GrabConfig(systemClassLoader=true).

It’s the Groovy way to deal with JDBC driver. I try it, but actually Jenkins does not support this solution and raise this error :

```java
org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
General error during conversion: No suitable ClassLoader found for grab
java.lang.RuntimeException: No suitable ClassLoader found for grab
at sun.reflect.NativeConstructorAccessorImpl.newInstance0(Native Method)
at sun.reflect.NativeConstructorAccessorImpl.newInstance(NativeConstructorAccessorImpl.java:62)
at sun.reflect.DelegatingConstructorAccessorImpl.newInstance(DelegatingConstructorAccessorImpl.java:45)
at java.lang.reflect.Constructor.newInstance(Constructor.java:423)
at org.codehaus.groovy.reflection.CachedConstructor.invoke(CachedConstructor.java:83)
at org.codehaus.groovy.runtime.callsite.ConstructorSite$ConstructorSiteNoUnwrapNoCoerce.callConstructor(ConstructorSite.java:105)
at org.codehaus.groovy.runtime.callsite.AbstractCallSite.callConstructor(AbstractCallSite.java:247)
at groovy.grape.GrapeIvy.chooseClassLoader(GrapeIvy.groovy:182)
at groovy.grape.GrapeIvy$chooseClassLoader.callCurrent(Unknown Source)
at groovy.grape.GrapeIvy.grab(GrapeIvy.groovy:249)
at groovy.grape.Grape.grab(Grape.java:167)
```
So another solution is to register the driver before instantiating the connection, thanks to @GroGro57 and @evildethow for their help.

DriverManager.registerDriver(new oracle.jdbc.OracleDriver())
Edit : @JosePaumard give another solution to load the driver, the final code use this one. This solution actually works in Jenkins 2.60.1, but I hope @GrabConfig will be added in a future release of the Shared Groovy Plugin.

## Final Code
In the end the pipeline code will be :

```groovy
@Grab('com.oracle:ojdbc6:11.2.0.4')
import groovy.sql.Sql;
import java.util.ServiceLoader;
import java.sql.Driver;

ServiceLoader<Driver> loader = ServiceLoader.load(Driver.class);
def sql = Sql.newInstance('jdbc:oracle:thin:@SERVER:2483/INSTANCE', 'USER', 'PASSWORD', 'oracle.jdbc.OracleDriver')
sql.execute 'select 1 from dual'
sql.close()
```


```groovy
@Grab('mysql:mysql-connector-java:5.1.6')
import groovy.sql.Sql;
import java.util.ServiceLoader;
import java.sql.Driver;

ServiceLoader<Driver> loader = ServiceLoader.load(Driver.class);
def sql = Sql.newInstance("jdbc:mysql://172.20.62.130:3306/flyway_mysql", "root", "123456", "com.mysql.jdbc.Driver")
def rows = sql.execute "select count(*) from persons;"
sql.close()	



// http://172.20.62.42:8080/scriptApproval/
method groovy.sql.Sql close
method groovy.sql.Sql execute java.lang.String
method java.io.File toURL
method java.lang.ClassLoader getParent
method java.net.URLClassLoader addURL java.net.URL
new java.io.File java.lang.String
staticMethod groovy.sql.Sql newInstance java.lang.String java.lang.String java.lang.String java.lang.String
staticMethod java.lang.Class forName java.lang.String
staticMethod java.lang.ClassLoader getSystemClassLoader
staticMethod org.codehaus.groovy.runtime.DefaultGroovyMethods getAt java.util.Collection java.lang.String
```