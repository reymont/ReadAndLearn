

Source Cookbook: How to attach source and javadoc artifacts?

http://maven.apache.org/plugin-developers/cookbook/attach-source-javadoc-artifacts.html

Summary
This recipe describes how to attach source and javadoc artifacts to your build.
Prerequisite Plugins
Here is the list of the plugins used:
Plugin	Version
source
2.0.4
javadoc
2.3
Sample Generated Output
attach-source-javadoc
|-- pom.xml
|-- src\
`-- target
    `-- attach-source-javadoc-1.0-SNAPSHOT.jar
    `-- attach-source-javadoc-1.0-SNAPSHOT-javadoc.jar
    `-- attach-source-javadoc-1.0-SNAPSHOT-sources.jar
Recipe
Configuring Maven Source Plugin
We execute the source:jar goal from the source plugin during the package phase.
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-source-plugin</artifactId>
  <executions>
    <execution>
      <id>attach-sources</id>
      <goals>
        <goal>jar</goal>
      </goals>
    </execution>
  </executions>
</plugin>
Configuring Maven Javadoc Plugin
Same thing for the javadoc:jar goal from the javadoc plugin.
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-javadoc-plugin</artifactId>
  <executions>
    <execution>
      <id>attach-javadocs</id>
      <goals>
        <goal>jar</goal>
      </goals>
    </execution>
  </executions>
</plugin>
Running Maven
Just call Maven to generate the packages:
mvn package
Other Tips
To improve the build time or for a release, you could also define these plugins in a profile.
Resources
	Source code: http://svn.apache.org/repos/asf/maven/sandbox/trunk/site/cookbook/attach-source-javadoc
	Maven Javadoc Plugin
	Maven Source Plugin
