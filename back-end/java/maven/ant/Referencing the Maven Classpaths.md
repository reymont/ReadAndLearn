Referencing the Maven Classpaths


http://maven.apache.org/plugins/maven-antrun-plugin/examples/classpaths.html


A property is set in the Ant build for each project dependency. Each property name uses the format groupId:artifactId:type[:classifier]. For example, to show the path to a jar dependency with groupId "org.apache" and artifactId "common-util", the following could be used.
<echo message="${org.apache:common-util:jar}"/>
If the dependency includes a classifier, the classifier is appended to the property name. For example, groupId "org.apache", artifactId "common-util", type "jar", and classifier "jdk14".
<echo message="${org.apache:common-util:jar:jdk14}"/>
Note: the old format "maven.dependency.groupId.artifactId[.classifier].type.path" has been deprecated and should no longer be used.
You can also use these classpath references:
•	maven.compile.classpath
•	maven.runtime.classpath
•	maven.test.classpath
•	maven.plugin.classpath
For example, to display Maven's classpaths using antrun, we can do this
<project>
  <modelVersion>4.0.0</modelVersion>
  <artifactId>my-test-app</artifactId>
  <groupId>my-test-group</groupId>
  <version>1.0-SNAPSHOT</version>

  <build>
    <plugins>

      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-antrun-plugin</artifactId>
        <version>1.7</version>
        <executions>
          <execution>
            <id>compile</id>
            <phase>compile</phase>
            <configuration>
              <target>
                <property name="compile_classpath" refid="maven.compile.classpath"/>
                <property name="runtime_classpath" refid="maven.runtime.classpath"/>
                <property name="test_classpath" refid="maven.test.classpath"/>
                <property name="plugin_classpath" refid="maven.plugin.classpath"/>

                <echo message="compile classpath: ${compile_classpath}"/>
                <echo message="runtime classpath: ${runtime_classpath}"/>
                <echo message="test classpath:    ${test_classpath}"/>
                <echo message="plugin classpath:  ${plugin_classpath}"/>
              </target>
            </configuration>
            <goals>
              <goal>run</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>

or alternatively, we can use an external build.xml.
<project>
  <modelVersion>4.0.0</modelVersion>
  <artifactId>my-test-app</artifactId>
  <groupId>my-test-group</groupId>
  <version>1.0-SNAPSHOT</version>

  <build>
    <plugins>

      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-antrun-plugin</artifactId>
        <version>1.7</version>
        <executions>
          <execution>
            <id>compile</id>
            <phase>compile</phase>
            <configuration>
              <target>
                <property name="compile_classpath" refid="maven.compile.classpath"/>
                <property name="runtime_classpath" refid="maven.runtime.classpath"/>
                <property name="test_classpath" refid="maven.test.classpath"/>
                <property name="plugin_classpath" refid="maven.plugin.classpath"/>

                <ant antfile="${basedir}/build.xml">
                  <target name="test"/>
                </ant>
              </target>
            </configuration>
            <goals>
              <goal>run</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
  </build>
</project>
The build.xml:
<?xml version="1.0"?>
<project name="test6">

    <target name="test">

      <echo message="compile classpath: ${compile_classpath}"/>
      <echo message="runtime classpath: ${runtime_classpath}"/>
      <echo message="test classpath:    ${test_classpath}"/>
      <echo message="plugin classpath:  ${plugin_classpath}"/>

    </target>

</project>
