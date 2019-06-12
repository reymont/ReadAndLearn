Build Axis Tools Maven Plugin Simple Configuration Example 2012/10/15

http://mojo.codehaus.org/axistools-maven-plugin/examples/simple.html


<project>
  ...
  <build>
    <plugins>
      <plugin>
        <groupId>org.codehaus.mojo</groupId>
        <artifactId>axistools-maven-plugin</artifactId>
        <version>1.4</version>
        <configuration>
          <urls>
            <url>http://host/server/sample.wsdl</url>
            <url>http://host/server/sample2.wsdl</url>
          </urls>
          <packageSpace>com.company.wsdl</packageSpace>
          <testCases>true</testCases>
          <serverSide>true</serverSide>
          <subPackageByFileName>true</subPackageByFileName>
        </configuration>
        <executions>
          <execution>
            <goals>
              <goal>wsdl2java</goal>
            </goals>
          </execution>
        </executions>
      </plugin>
    </plugins>
    ...
  </build>
  ...
</project>

