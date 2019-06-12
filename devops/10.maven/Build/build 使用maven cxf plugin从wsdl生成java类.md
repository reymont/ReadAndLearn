build 使用maven cxf plugin从wsdl生成java类 2012/10/18


cxf-codegen-plugin

mvn generate-sources


<build>
		<plugins>
			<plugin>
				<groupId>org.apache.cxf</groupId>
                <artifactId>cxf-codegen-plugin</artifactId>
                <version>2.1.4</version>
                <executions>
                	<execution>
                		<id>generate-sources</id>
                		<phase>generate-sources</phase>
                		<configuration>
<!--                 			<sourceRoot>${basedir}/target/generated-sources/</sourceRoot> -->
							<sourceRoot>${basedir}/src/main/java/</sourceRoot>
                			<wsdlOptions>
                				<wsdlOption>
                					<wsdl>${basedir}/src/main/resources/WebService.wsdl</wsdl>
<!--                 					<extraarg>-client</extraarg> -->
<!--           							<extraarg>-verbose</extraarg>  -->
                				</wsdlOption>
                				<wsdlOption>
                					<wsdl>${basedir}/src/main/resources/OtherWebService.wsdl</wsdl>
<!--                 					<extraarg>-client</extraarg> -->
<!--           							<extraarg>-verbose</extraarg>  -->
                				</wsdlOption>
                			</wsdlOptions>
                		</configuration>
                		<goals>
                            <goal>wsdl2java</goal>
                        </goals>
                	</execution>
                </executions>
                <dependencies>
                    <dependency>
                        <groupId>xerces</groupId>
                        <artifactId>xercesImpl</artifactId>
                        <version>2.9.1</version>
                    </dependency>
                    <dependency>
                        <groupId>org.apache.cxf</groupId>
                        <artifactId>cxf-xjc-ts</artifactId>
                        <version>2.2.3</version>
                    </dependency>
                </dependencies>
			</plugin>
		</plugins>
		<pluginManagement>
			<plugins>
				<!--This plugin's configuration is used to store Eclipse m2e settings only. It has no influence on the Maven build itself.-->
				<plugin>
					<groupId>org.eclipse.m2e</groupId>
					<artifactId>lifecycle-mapping</artifactId>
					<version>1.0.0</version>
					<configuration>
						<lifecycleMappingMetadata>
							<pluginExecutions>
								<pluginExecution>
									<pluginExecutionFilter>
										<groupId>
											org.apache.cxf
										</groupId>
										<artifactId>
											cxf-codegen-plugin
										</artifactId>
										<versionRange>
											[2.1.4,)
										</versionRange>
										<goals>
											<goal>wsdl2java</goal>
										</goals>
									</pluginExecutionFilter>
									<action>
										<ignore></ignore>
									</action>
								</pluginExecution>
							</pluginExecutions>
						</lifecycleMappingMetadata>
					</configuration>
				</plugin>
			</plugins>
		</pluginManagement>
	</build>


1. 执行 mvn generate-sources，就可生成java代码。 

2. error: Plugin execution not 
covered by lifecycle configuration: org.apache.cxf:cxf-codegen- 

plugin:2.1.2:wsdl2java (execution: generate-sources, phase: 
generate-sources). 

出现以上错误，添加<pluginManagement></pluginManagement>里面的内容即可解决 

3. 想多次执行 mvn generate-sources，就要删除cxf-codegen-plugin-markers里的Done文档 

4. 如果访问wsdl需要代理，则执行 mvn generate-sources -Dhttp.proxyHost=host -Dhttp.proxyPort=port。 

注：如果是下载maven相关文件，需要代理时，要在setting.xml中设置，命令行设置没有用。 

5.多个wsdl，只要在wsdlOptions里添加wsdlOption 

6.<extraargs>下的<extraarg>可以选择所需的wsdl2java命令参数使用（http://cxf.apache.org/docs/wsdl-to-java.html） 

参考：http://cxf.apache.org/docs/maven-cxf-codegen-plugin-wsdl-to-java.html

