maven-war-plugin Adding and Filtering External Web Resources 2012/10/11

http://maven.apache.org/plugins/maven-war-plugin/examples/adding-filtering-webresources.html

Adding web resources
<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-war-plugin</artifactId>
        <version>2.3</version>
        <configuration>
          <webResources>
            <resource>
              <!-- this is relative to the pom.xml directory -->
              <directory>resource2</directory>
            </resource>
          </webResources>
        </configuration>
      </plugin>
    </plugins>
  </build>
  ...
</project>

Configuring web Resources
webResources is a list of resources. All options of resource are supported.
A web resource
•	can have includes/excludes 
•	can be filtered 
•	is not limited to the default destination - the root of the WAR
Includes/Excludes
To include all jpgs in the WAR we can add the following to our POM configuration from above:
        ...
        <configuration>
          <webResources>
            <resource>
              <!-- this is relative to the pom.xml directory -->
              <directory>resource2</directory>
              <!-- the list has a default value of ** -->
              <includes>
                <include>**/*.jpg</include>
              </includes>
            </resource>
          </webResources>
        </configuration>
        ...
To exclude the image2 directory from the WAR add this:
        ...
        <configuration>
          <webResources>
            <resource>
              <!-- this is relative to the pom.xml directory -->
              <directory>resource2</directory>
              <!-- there's no default value for this -->
              <excludes>
                <exclude>**/image2</exclude>
              </excludes>
            </resource>
          </webResources>
        </configuration>
        ...
Be careful when mixing includes and excludes, excludes will have a higher priority. Includes can not override excludes if a resource matches both.
Having this configuration will exclude all jpgs from the WAR:
        ...
        <configuration>
          <webResources>
            <resource>
              <!-- this is relative to the pom.xml directory -->
              <directory>resource2/</directory>
              <!-- the list has a default value of ** -->
              <includes>
                <include>image2/*.jpg</include>
              </includes>
              <!-- there's no default value for this -->
              <excludes>
                <exclude>**/*.jpg</exclude>
              </excludes>
            </resource>
          </webResources>
        </configuration>
        ...
Here's another example of how to specify include and exclude patterns:
        ...
        <configuration>
          <webResources>
            <resource>
              <!-- this is relative to the pom.xml directory -->
              <directory>resource2</directory>
              <!-- the default value is ** -->
              <includes>
                <include>**/pattern1</include>
                <include>*pattern2</include>
              </includes>
              <!-- there's no default value for this -->
              <excludes>
                <exclude>*pattern3/pattern3</exclude>
                <exclude>pattern4/pattern4</exclude>
              </excludes>
            </resource>
          </webResources>
        </configuration>
        ...
Filtering
Using our example above, we can also configure filters for our resources. We will add a hypothetical configurations directory to our project:
 .
 |-- configurations
 |   |-- config.cfg
 |   `-- properties
 |       `-- config.prop
 |-- pom.xml
 |-- resource2
 |   |-- external-resource.jpg
 |   `-- image2
 |       `-- external-resource2.jpg
 `-- src
     `-- main
         |-- java
         |   `-- com
         |       `-- example
         |           `-- projects
         |               `-- SampleAction.java
         |-- resources
         |   `-- images
         |       `-- sampleimage.jpg
         `-- webapp
             |-- WEB-INF
             |   `-- web.xml
             |-- index.jsp
             `-- jsp
                 `-- websource.jsp
To prevent corrupting your binary files when filtering is enabled, you can configure a list of file extensions that will not be filtered.
        ...
        <configuration>
          <!-- the default value is the filter list under build -->
          <!-- specifying a filter will override the filter list under build -->
          <filters>
            <filter>properties/config.prop</filter>
          </filters>
          <nonFilteredFileExtensions>
            <!-- default value contains jpg,jpeg,gif,bmp,png -->
            <nonFilteredFileExtension>pdf</nonFilteredFileExtension>
          </nonFilteredFileExtensions>
          <webResources>
            <resource>
              <directory>resource2</directory>
              <!-- it's not a good idea to filter binary files -->
              <filtering>false</filtering>
            </resource>
            <resource>
              <directory>configurations</directory>
              <!-- enable filtering -->
              <filtering>true</filtering>
              <excludes>
                <exclude>**/properties</exclude>
              </excludes>
            </resource>
          </webResources>
        </configuration>
        ...
config.prop
interpolated_property=some_config_value
config.cfg
<another_ioc_container>
   <configuration>${interpolated_property}</configuration>
</another_ioc_container>
The resulting WAR would be:
documentedproject-1.0-SNAPSHOT.war
 |-- META-INF
 |   |-- MANIFEST.MF
 |   `-- maven
 |       `-- com.example.projects
 |           `-- documentedproject
 |               |-- pom.properties
 |               `-- pom.xml
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           `-- SampleAction.class
 |   |   `-- images
 |   |       `-- sampleimage.jpg
 |   `-- web.xml
 |-- config.cfg
 |-- external-resource.jpg
 |-- image2
 |   `-- external-resource2.jpg
 |-- index.jsp
 `-- jsp
     `-- websource.jsp
and the content of config.cfg would be:
<another_ioc_container>
   <configuration>some_config_value</configuration>
</another_ioc_container>
Note: In versions 2.2 and earlier of this plugin the platform encoding was used when filtering resources. Depending on what that encoding was you could end up with scrambled characters after filtering. Starting with version 2.3 this plugin respects the property project.build.sourceEncoding when filtering resources. One notable exception to this is that .xml files are filtered using the encoding specified inside the xml-file itself.
Overriding the default destination directory
By default web resources are copied to the root of the WAR, as shown in the previous example. To override the default destination directory, specify the target path.
        ...
        <configuration>
          <webResources>
            <resource>
              ...
            </resource>
            <resource>
              <directory>configurations</directory>
              <!-- override the destination directory for this resource -->
              <targetPath>WEB-INF</targetPath>
              <!-- enable filtering -->
              <filtering>true</filtering>
              <excludes>
                <exclude>**/properties</exclude>
              </excludes>
            </resource>
          </webResources>
        </configuration>
        ...
Using the sample project the resulting WAR would look like this:
documentedproject-1.0-SNAPSHOT.war
 |-- META-INF
 |   |-- MANIFEST.MF
 |   `-- maven
 |       `-- com.example.projects
 |           `-- documentedproject
 |               |-- pom.properties
 |               `-- pom.xml
 |-- WEB-INF
 |   |-- classes
 |   |   |-- com
 |   |   |   `-- example
 |   |   |       `-- projects
 |   |   |           `-- SampleAction.class
 |   |   `-- images
 |   |       `-- sampleimage.jpg
 |   |-- config.cfg
 |   `-- web.xml
 |-- external-resource.jpg
 |-- image2
 |   `-- external-resource2.jpg
 |-- index.jsp
 `-- jsp
     `-- websource.jsp





