Property Special Variables 2012/11/12

http://maven.apache.org/guides/index.html
http://maven.apache.org/guides/introduction/introduction-to-the-pom.html

Project Model Variables
Any field of the model that is a single value element can be referenced as a variable. For example, ${project.groupId}, ${project.version},${project.build.sourceDirectory} and so on. Refer to the POM reference to see a full list of properties.
These variables are all referenced by the prefix "project.". You may also see references with pom. as the prefix, or the prefix omitted entirely - these forms are now deprecated and should not be used.
Special Variables
basedir	The directory that the current project resides in.
project.baseUri	The directory that the current project resides in, represented as an URI. Since Maven 2.1.0
maven.build.timestamp	The timestamp that denotes the start of the build. Since Maven 2.1.0-M1
The format of the build timestamp can be customized by declaring the property maven.build.timestamp.format as shown in the example below:
<project>
  ...
  <properties>
    <maven.build.timestamp.format>yyyyMMdd-HHmm</maven.build.timestamp.format>
  </properties>
  ...
</project>
The format pattern has to comply with the rules given in the API documentation for SimpleDateFormat. If the property is not present, the format defaults to the value already given in the example.
