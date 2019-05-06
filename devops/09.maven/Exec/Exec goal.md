Exec goal

http://mojo.codehaus.org/exec-maven-plugin/usage.html


Exec goal
You can formally specify all the relevant execution information in the plugin configuration. Depending on your use case, you can also specify some or all information using system properties.
Command line
Using system properties you would just execute it like in the following example.
mvn exec:exec -Dexec.executable="maven" [-Dexec.workingdir="/tmp"] -Dexec.args="-X myproject:dist"
POM Configuration
Add a configuration similar to the following to your POM:
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>exec-maven-plugin</artifactId>
        <version>1.2.1</version>
        <executions>
          <execution>
            ...
            <goals>
              <goal>exec</goal>
            </goals>
          </execution>
        </executions>
        <configuration>
          <executable>maven</executable>
          <!-- optional -->
          <workingDirectory>/tmp</workingDirectory>
          <arguments>
            <argument>-X</argument>
            <argument>myproject:dist</argument>
            ...
          </arguments>
        </configuration>
      </plugin>
    </plugins>
  </build>
   ...
</project>
Java goal
This goal helps you run a Java program within the same VM as Maven.
Differences compared to plain command line
The goal goes to great length to try to mimic the way the VM works, but there are some small subttle differences. Today all differences come from the way the goal deals with thread management.
command line	Java Mojo
The VM exits as soon as the only remaining threads are daemon threads	By default daemon threads are joined and interrupted once all known non daemon threads have quitted. The join timeout is customisable The user might wish to further cleanup cleanup by stopping the unresponsive threads. The user can disable the full extra thread management (interrupt/join/[stop])
Read the documentation for the java goal for more information on how to configure this behavior.
If you find out that these differences are unacceptable for your case, you may need to use the exec goal to wrap your Java executable.
Command line
If you want to execute Java programs in the same VM, you can either use the command line version
mvn exec:java -Dexec.mainClass="com.example.Main" [-Dexec.args="argument1"] ...
POM Configuration
or you can configure the plugin in your POM:
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>exec-maven-plugin</artifactId>
        <version>1.2.1</version>
        <executions>
          <execution>
            ...
            <goals>
              <goal>java</goal>
            </goals>
          </execution>
        </executions>
        <configuration>
          <mainClass>com.example.Main</mainClass>
          <arguments>
            <argument>argument1</argument>
            ...
          </arguments>
          <systemProperties>
            <systemProperty>
              <key>myproperty</key>
              <value>myvalue</value>
            </systemProperty>
            ...
          </systemProperties>
        </configuration>
      </plugin>
    </plugins>
  </build>
   ...
</project>
Note: The java goal doesn't spawn a new process. Any VM specific option that you want to pass to the executed class must be passed to the Maven VM using the MAVEN_OPTS environment variable. E.g.
MAVEN_OPTS=-Xmx1024m
Otherwise consider using the exec goal.


