maven-war-plugin目标路径 targetPath 2012/10/11


<build>
	<filters>
		<!-- 过滤文件,通常是一个属性文件（名值对的形式） -->
		<filter>src/main/webapp/META-INF/auto-config.properties</filter>
		<!--
			<filter>${user.home}/antx.properties</filter>
		-->
	</filters>
	<finalName>communitytag</finalName>
	<plugins>
		<plugin>
			<groupId>org.apache.maven.plugins</groupId>
			<artifactId>maven-war-plugin</artifactId>
			<version>2.1-alpha-1</version>
			<configuration>
				<!--
					打包之前过滤掉不想要被打进 .war包的jar,注意：这个地方，本来路径应该是
					WEB-INF/lib/anaalyzer-2.0.4.jar,但是经过多次试验,不能这样，至于咋回事儿，搞不清楚。。经多方查证均无结果
					暂且这样吧，虽然显得很丑陋，但是总能解决问题吧
				-->
				<warSourceExcludes>*/lib/analyzer-2.0.4.jar</warSourceExcludes>
				<webResources>
					<resource>
						<!-- 元配置文件的目录，相对于pom.xml文件的路径 -->
						<directory>src/main/webapp/WEB-INF</directory>

						<!-- 是否过滤文件，也就是是否启动auto-config的功能 -->
						<filtering>true</filtering>

						<!-- 目标路径 -->
						<targetPath>WEB-INF</targetPath>
					</resource>
				</webResources>
			</configuration>
		</plugin>
	</plugins>
</build>
