


 2012/10/11
Maven Jetty Plugin Configuration Guide
http://docs.codehaus.org/display/JETTY/Maven+Jetty+Plugin


In order to run Jetty on a webapp project which is structured according to the usual Maven defaults (resources in ${basedir}/src/main/webapp, classes in${project.build.outputDirectory} and the web.xml descriptor at ${basedir}/src/main/webapp/WEB-INF/web.xml, you don't need to configure anything.
Simply type:
mvn jetty:run
This will start Jetty running on port 8080 and serving your project. Jetty will continue to run until the plugin is explicitly stopped, for example, by a <cntrl-c>. You can also use the mvn jetty:stopcommand.
It is extremely convenient to leave the plugin running because it can be configured to periodically scan for changes and automatically redeploy the webapp. This makes the development cycle much more productive by eliminating the build and deploy steps: you use your IDE to make changes to the project and the running web container will automatically pick them up, allowing you to test them straight away.
If, for whatever reason, you cannot run on an unassembled webapp, the plugin also supports the jetty:run-war and jetty:run-exploded goals which are discussed below.
More information on each of the goals is available at mvn jetty:run page, mvn jetty:run-exploded page, mvn jetty:run-war page and the Jetty Documentation.
Automatic execution of the plugin
Sometimes, for example when doing integration testing, you'd like to be able to automatically have your webapp started at the beginning of the tests, and stopped at the end rather than manually executing mvn jetty:run on the command line.
To do this, you need to set up a couple of <execution> scenarios for the jetty plugin and use the <daemon>true</daemon> configuration option to prevent jetty running indefinitely and force it to only execute while maven is running.
The pre-integration-test and post-integration-test maven build phases can be used to trigger the execution and termination of jetty like so:
<plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <version>6.1.10</version>
        <configuration>
                <scanIntervalSeconds>10</scanIntervalSeconds>
                <stopKey>foo</stopKey>
                <stopPort>9999</stopPort>
        </configuration>
        <executions>
                <execution>
                        <id>start-jetty</id>
                        <phase>pre-integration-test</phase>
                        <goals>
                                <goal>run</goal>
                        </goals>
                        <configuration>
                                <scanIntervalSeconds>0</scanIntervalSeconds>
                                <daemon>true</daemon>
                        </configuration>
                </execution>
                <execution>
                        <id>stop-jetty</id>
                        <phase>post-integration-test</phase>
                        <goals>
                                <goal>stop</goal>
                        </goals>
                </execution>
        </executions>
</plugin>
•	Note: Maven by default looks for plugins with a groupId of org.apache.maven.plugins, even if the groupId is declared differently as above. In order to instruct it to look for the plugin in the groupId as defined, one can set a plugin group in a profile in settings.xml like so: 
<profile>
  ...
  <pluginGroups>
    <pluginGroup>org.mortbay.jetty</pluginGroup>
  </pluginGroups>
</profile>
•	 
•	Note 2: When running with this configuration, the "stopPort" must be free on the machine you are running on. If this is not the case, you will be getting an "address already in use" from the maven plugin, which appears *after* the "Started SelectedChannelConnector ..." message. If you run with the mvn -X option, you'll see org.mortbay.jetty.plugin.util.Monitor is part of the causing stacktrace.
How to stop the plugin from the command line
The run, run-war and run-exploded goals leave the plugin running indefinitely. You can terminate it with a <cntrl-c> in the controlling terminal window, or by executing the stop goal in another terminal window. If you wish to be able to use mvn jetty:stop then you need to configure the plugin with a special port number and key that you also supply on the stop command:
Here's an example configuration:
<plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <version>6.1.10</version>
        <configuration>
          <stopPort>9966</stopPort>
          <stopKey>foo</stopKey>
        </configuration>
</plugin>
To start:
mvn jetty:start
To stop:
mvn jetty:stop
How to configure the plugin
Configuration common to run, run-war and run-exploded goals
Regardless of which jetty goal you execute, the following configuration parameters are common to all. They are divided into configuration that applies to the container as a whole, and configuration that applies specifically to the webapp:
Container Configuration
•	connectors Optional. A list of org.mortbay.jetty.Connector objects, which are the port listeners for jetty. If you don't specify any, an NIO org.mortbay.jetty.nio.SelectChannelConnector will be configured on port 8080. You can change this default port number by using the system property jetty.port on the command line. Eg "mvn -D jetty.port=9999 jetty:run". Alternatively, you can specify as many connectors as you like.
•	jettyConfig Optional. The location of a jetty.xml file that will be applied in addition to any plugin configuration parameters. You might use it if you have other webapps, handlers etc to be deployed, or you have other jetty objects that cannot be configured from the plugin.
•	scanIntervalSeconds Optional. The pause in seconds between sweeps of the webapp to check for changes and automatically hot redeploy if any are detected. By default this is 0, which disables hot deployment scanning. A number greater than 0 enables it.
•	systemProperties Optional. These allow you to configure System properties that will be set for the execution of the plugin. More information can be found on them at Setting System Properties.
•	systemPropertiesFile Optional. This is a file containing System properties that will be set for the execution of the plugin. They will not override any system properties that have been set on the command line, by the JVM, or in the POM via systemProperties. Available from Jetty 6.1.15rc4
•	userRealms Optional. A list of org.mortbay.jetty.security.UserRealm implementations. Note that there is no default realm. If you use a realm in your web.xml you can specify a corresponding realm here.
•	requestLog Optional. An implementation of the org.mortbay.jetty.RequestLog request log interface. An implementation that respects the NCSA format is available asorg.mortbay.jetty.NCSARequestLog.
 	"Manual Reloading"
As of Jetty 6.2.0pre0 a new feature to control webapp redeployment will be available. 
The configuration parameter is: <reload>[manual|automatic]</reload> 
When set to manual, no automatic scanning and redeployment of the webapp is done. Rather, the user can control when the webapp is reloaded by tapping the carriage return key. Set to automatic the scanning and automatic redeployment is performed at intervals controlled by the scanIntervalSeconds parameter. The choice of reloading paradigm can also be configured on the command line by use of the -Djetty.reload system parameter. 
For example: "mvn -Djetty.reload=manual jetty:run" would force manual reloading, regardless of what is configured in the project pom. Similarly: "mvn -Djetty.reload=automatic -Djetty.scanIntervalSeconds=10 jetty:run" will force automatic background reloading with a sweep every 10 seconds, regardless of the configuration in the project pom.
Webapp Configuration
•	contextPath Optional. The context path for your webapp. By default, this is set to the <artifactId> from the project's pom.xml. You can override it and set it to anything you like here.
•	tmpDir Optional. The temporary directory to use for the webapp. This is set to {${basedir}/target} by default but can be changed here.
•	overrideWebXml Optional. A web.xml file which will be applied AFTER the webapp's web.xml. This file can be stored anywhere. It is used to add or modify the configuration of a web.xml for different environments eg test, production etc.
•	webDefaultXml Optional. A webdefault.xml file to use instead of the supplied jetty default for the webapp.
As of release 6.1.6rc0, an alternative and more flexible way to configure the webapp is to use the webAppConfig element instead of the individual parameters listed above. With the webAppConfigelement, you can effectively call any of the setter methods on the org.mortbay.jetty.webapp.WebAppContext class, an instance of which represents your webapp. The example below shows how to use this element to configure the same parameters as above (but of course there are many more you can set):
<project>
  ...
  <plugins>
    ...
      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <configuration>
 
          <scanIntervalSeconds>10</scanIntervalSeconds>
 
          <!-- Configure the webapp -->
          <contextPath>/biggerstrongerbetterfaster</contextPath>
          <tmpDir>target/not/necessary</tmpDir>
          <webDefaultXml>src/main/resources/webdefault.xml</webDefaultXml>
          <overrideWebXml>src/main/resources/override-web.xml</overrideWebXml>
 
          <!-- OR, as of jetty6.1.6rc0, you can use the webAppConfig element instead
          <webAppConfig>
            <contextPath>/test</contextPath>
            <tempDirectory>${project.build.directory}/work</tempDirectory>
            <defaultsDescriptor>src/main/resources/webdefault.xml</defaultsDescriptor>
            <overrideDescriptor>src/main/resources/override-web.xml</overrideDescriptor>
          </webAppConfig>
          -->
 
          <!-- configure the container                 -->
          <jettyConfig>/my/special/jetty.xml</jettyConfig>
         <connectors>
            <connector implementation="org.mortbay.jetty.nio.SelectChannelConnector">
              <port>9090</port>
              <maxIdleTime>60000</maxIdleTime>
            </connector>
          </connectors>
          <userRealms>
            <userRealm implementation="org.mortbay.jetty.security.HashUserRealm">
              <name>Test Realm</name>
              <config>etc/realm.properties</config>
            </userRealm>
          </userRealms>
          <requestLog implementation="org.mortbay.jetty.NCSARequestLog">
            <filename>target/yyyy_mm_dd.request.log</filename>
            <retainDays>90</retainDays>
            <append>true</append>
            <extended>false</extended>
            <logTimeZone>GMT</logTimeZone>
          </requestLog>
        </configuration>
      </plugin>
  </plugins>
</project>
Configuration for the jetty:run Goal
The run goal allows you to deploy your unassembled webapp to jetty, based on the locations of its constituent parts in your pom.xml. The following extra configuration parameters are available:
•	classesDirectory This is the location of your compiled classes for the webapp. You should rarely need to set this parameter. Instead, you should set <build><outputDirectory> in yourpom.xml.
•	webAppSourceDirectory By default, this is set to ${basedir}/src/main/webapp. If your static sources are in a different location, set this parameter accordingly. See also Multiple WebApp Source Directory for how to configure multiple source directories.
•	webXml By default, this is set to either the variable ${maven.war.webxml} or ${basedir}/src/main/webapp/WEB-INF/web.xml, whichever is not null. If neither of these are appropriate, set this parameter.
•	jettyEnvXml Optional. it is the location of a jetty-env.xml file, which allows you to make JNDI bindings that will satisfy <env-entry>, <resource-env-ref> and <resource-ref> linkages in theweb.xml that are scoped only to the webapp and not shared with other webapps that you may be deploying at the same time (eg by using a jettyConfig file).
•	scanTargets Optional.A list of files and directories to also periodically scan in addition to those automatically scanned by the plugin.
•	scanTargetPatterns Optional. If you have a long list of extra files you want scanned, it is more convenient to use pattern matching expressions to specify them instead of enumerating them with the <scanTargets> parameter. This parameter is a list of <scanTargetPattern>s, each consisting of a <directory> and <includes> and/or <excludes> parameters to specify the file matching patterns.
Here's an example of setting all of these parameters:
<project>
  ...
  <plugins>
    ...
      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <configuration>
          <webAppSourceDirectory>${basedir}/src/staticfiles</webAppSourceDirectory>
          <webXml>${basedir}/src/over/here/web.xml</webXml>
          <jettyEnvXml>${basedir}/src/over/here/jetty-env.xml</jettyEnvXml>
          <classesDirectory>${basedir}/somewhere/else</classesDirectory>
          <scanTargets>
            <scanTarget>src/mydir</scanTarget>
            <scanTarget>src/myfile.txt</scanTarget>
          </scanTargets>
          <scanTargetPatterns>
            <scanTargetPattern>
              <directory>src/other-resources</directory>
              <includes>
                <include>**/*.xml</include>
                <include>**/*.properties</include>
              </includes>
              <excludes>
                <exclude>**/myspecial.xml</exclude>
                <exclude>**/myspecial.properties</exclude>
              </excludes>
            </scanTargetPattern>
          </scanTargetPatterns>
        </configuration>
      </plugin>
  </plugins>
</project>
See also the jetty:run parameter reference.
Configuration for the jetty:run-war Goal
This goal will first package your webapp as a war file and then deploy it to Jetty. If you set a non-zero scanInterval Jetty will watch your pom.xml and the war file and if either changes, it will redeploy the war.
The configuration parameters specific to this goal are:
•	webApp The location of the built war file. This defaults to ${project.build.directory}/${project.build.finalName}.war. If this is not sufficient, set it to your custom location.
Here's how you would set it:
<project>
  ...
  <plugins>
    ...
      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <configuration>
          <webApp>${basedir}/target/mycustom.war</webApp>
        </configuration>
      </plugin>
  </plugins>
</project>
See also the jetty:run-war parameter reference.
Configuration for the jetty:run-exploded Goal
This goal first assembles your webapp into an exploded war file and then deploys it to Jetty. If you set a non-zero scanInterval, Jetty will watch your pom.xml, WEB-INF/lib, WEB-INF/classes andWEB-INF/web.xml for changes and redeploy when necessary.
The configuration parameters specific to this goal are:
•	webApp The location of the exploded war. This defaults to ${project.build.directory}/${project.build.finalName} but can be overridden by setting this parameter.
Here's how you would set it:
<project>
  ...
  <plugins>
    ...
      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <configuration>
          <webApp>${basedir}/target/myfunkywebapp</webApp>
        </configuration>
      </plugin>
  </plugins>
</project>
See also the jetty:run-exploded parameter reference.
Configuration for the jetty:deploy-war Goal
This is basically the same as jetty:run-war but without assembling the war of the current module.
Unlike run-war, the phase in which this plugin executes will not be bound to the "package" phase.
For example, you want to start jetty on the test-compile phase and stop jetty on the test-phase.
Here's the configuration:
<project>
  ...
  <plugins>
    ...
      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <configuration>
          <webApp>${basedir}/target/mycustom.war</webApp>
        </configuration>
        <executions>
          <execution>
            <id>start-jetty</id>
            <phase>test-compile</phase>
            <goals>
              <goal>deploy-war</goal>
            </goals>
            <configuration>
              <daemon>true</daemon>
              <reload>manual</reload>
            </configuration>
          </execution>
          <execution>
            <id>stop-jetty</id>
            <phase>test</phase>
            <goals>
              <goal>stop</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
  </plugins>
</project>
Running Multiple Webapps
Sometimes you need to deploy a number of webapps, not just the webapp under development. You can do this with the mvn jetty:run goal by supplying extra contextHandlers in the pom configuration.
Here's an example of setting up an extra webapp to run in the same jetty instance as the webapp under development:
<project>
  ...
  <plugins>
    ...
      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <configuration>
          <webApp>${basedir}/target/myfunkywebapp</webApp>
          <contextHandlers>            
            <contextHandler implementation="org.mortbay.jetty.webapp.WebAppContext">
              <war>${basedir}../../myother.war</war>
              <contextPath>/other</contextPath>
            </contextHandler>
          </contextHandlers>  
        </configuration>
      </plugin>
  </plugins>
</project>
This would deploy both the webapp under development - unassembled - at the context path "/" and a second webapp at the contex path "/other".
Setting System Properties

You may specify property name/value pairs that will be set as System properties for the execution of the plugin. Note that if a System property is found that is already set (eg from the command line or by the JVM itself), then these configured properties DO NOT override them. This feature is useful to tidy up the command line and save a lot of typing. For example, to set up Commons logging you would usually need to type:
mvn -Dorg.apache.commons.logging.Log=org.apache.commons.logging.impl.SimpleLog jetty:run
Using the systemProperty configuration the command line can again be shorted to mvn jetty:run by placing the following in the pom.xml:
<project>
  ...
  <plugins>
    ...
      <plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <configuration>
         ...
         <systemProperties>
            <systemProperty>
              <name>org.apache.commons.logging.Log</name>
               <value>org.apache.commons.logging.impl.SimpleLog</value>
            </systemProperty>
            ...
         </systemProperties>
        </configuration>
      </plugin>
  </plugins>
</project>
Note: You can use either <name> or <key> to specify the name of a <systemProperty>. Use whichever you prefer.
Logging
Jetty itself has no dependencies on a particular logging framework, using a built-in logger which outputs to stderr. However, to allow jetty to integrate with other logging mechanisms, if an SLF4J log implementation is detected in the classpath, it will use it in preference to the built-in logger.
The JSP engine used by jetty does however have logging dependencies. If you are using JSP 2.0 (ie you are running in a JVM version < 1.5), the JSP engine depends on commons-logging. A default commons-logging logger will be provided by the plugin using a combination of the jcl04-over-slf4j and the simple-slf4j implementation, which logs all messages INFO level and above. You can override this and provide your own commons-logging delegated logger by following these steps:
1.	Use plugin <dependencies> add commons-logging and a commons-logging impl such as log4j onto the plugin classpath. Note that if you want the Jetty container log to also be routed to this log, you should also add the slf4j-jcl bridge jar:
<plugin>
        <groupId>org.mortbay.jetty</groupId>
        <artifactId>maven-jetty-plugin</artifactId>
        <version>6.0-SNAPSHOT</version>
        <configuration>
          <scanIntervalSeconds>5</scanIntervalSeconds>
        </configuration>
       <dependencies>
        <dependency>
          <groupId>commons-logging</groupId>
          <artifactId>commons-logging</artifactId>
          <version>1.1</version>
          <type>jar</type>
        </dependency>
        <dependency>
          <groupId>org.slf4j</groupId>
          <artifactId>slf4j-jcl</artifactId>
          <version>1.0.1</version>
          <type>jar</type>
        </dependency>
        <dependency>
          <groupId>log4j</groupId>
          <artifactId>log4j</artifactId>
          <version>1.2.13</version>
          <type>jar</type>
        </dependency>
       </dependencies>
</plugin>
2.	Run the plugin with the system property -Dslf4j=false :
mvn -Dslf4j=false jetty:run
3.	Note: if you are using log4j you will need to tell the log4j discovery mechanism where your configuration properties file is. For example:
mvn -Dslf4j=false -Dlog4j.configuration=file:./target/classes/log4j.properties jetty:run
If you are using JSP2.1 (ie you are running in a JVM >= 1.5), then rejoice because the JSP engine has no particular logging dependencies.
Logback-Classic as the logging backend for the JSP Engine
<project>
... 
      <plugin> 
        <groupId>org.mortbay.jetty</groupId> 
        <artifactId>maven-jetty-plugin</artifactId> 
        <configuration> 
          <systemProperties> 
            <systemProperty> 
              <name>logback.configurationFile</name> 
              <value>./src/etc/logback.xml</value> 
            </systemProperty> 
          </systemProperties> 
        </configuration> 
        <dependencies>
          <dependency> 
            <groupId>ch.qos.logback</groupId> 
            <artifactId>logback-classic</artifactId> 
            <version>0.9.15</version> 
          </dependency> 
        </dependencies> 
      </plugin>
...
<project>
How to enable JSP2.0 with JDK1.5
By default Jetty maven plugin loads JSP2.1 libraries with JDK1.5. But some times you need to test web applications which require JSP2.0 (eg. because you are running it inside old JSP and Servler engine like tomcat 5.5 or weblogic 9.x)
Here are the steps which I did to make it happen:
<plugin>
                <groupId>org.mortbay.jetty</groupId>
                <artifactId>maven-jetty-plugin</artifactId>
                <version>6.1.14</version>
<dependencies>
                    <dependency>
                        <groupId>org.mortbay.jetty</groupId>
                        <artifactId>jsp-api-2.0</artifactId>
                        <version>6.1.14</version>
 
                    </dependency>
                    <dependency>
                        <groupId>tomcat</groupId>
                        <artifactId>jasper-compiler-jdt</artifactId>
                        <version>5.5.15</version>
                    </dependency>
                    <dependency>
                        <groupId>tomcat</groupId>
                        <artifactId>jasper-compiler</artifactId>
                        <version>5.5.15</version>
                    </dependency>
                    <dependency>
                        <groupId>tomcat</groupId>
                        <artifactId>jasper-runtime</artifactId>
                        <version>5.5.15</version>
                    </dependency>
                    <dependency>
                        <groupId>org.mortbay.jetty</groupId>
                        <artifactId>jsp-2.1</artifactId>
                        <version>6.1.14</version>
                        <scope>provided</scope>
                        <exclusions>
                            <exclusion>
                                <groupId>org.mortbay.jetty</groupId>
                                <artifactId>jsp-api-2.1</artifactId>
                            </exclusion>
                            <exclusion>
                                <groupId>org.mortbay.jetty</groupId>
                                <artifactId>start</artifactId>
                            </exclusion>
                            <exclusion>
                                <groupId>org.mortbay.jetty</groupId>
                                <artifactId>jetty-annotations</artifactId>
                            </exclusion>
                        </exclusions>
                    </dependency>
</dependencies>
....
</plugin>

