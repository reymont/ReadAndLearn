Tomcat

Build an Executable War/Jar
Since version 2.0 you can now build an executable war/jar with an embedded Apache Tomcat7.
This is only supported with the tomcat7 plugin.

Running
Now you can have fun with tomcat6:run or tomcat7:run
tomcat6:run-war



http://tomcat.apache.org/maven-plugin-2/tomcat6-maven-plugin/run-war-mojo.html



mvn clean package tomcat6:run-war

			<plugin>
				<groupId>org.apache.tomcat.maven</groupId>
				<artifactId>tomcat6-maven-plugin</artifactId>
				<version>2.0-beta-1</version>
				<configuration>
					<warFile>${project.build.directory}/${project.build.finalName}.war</warFile>
				</configuration>
			</plugin>

