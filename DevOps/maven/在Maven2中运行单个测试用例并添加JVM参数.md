
在Maven2中运行单个测试用例并添加JVM参数(转) - Edison的日志 - 网易博客
http://xeseo.blog.163.com/blog/static/56324316201191711823286/

mvn test -Dtest=TestStack -Dmaven.test.jvmargs="-Xss1M"

	<properties>
		<maven.test.jvmargs></maven.test.jvmargs>
	</properties>

	<build>
		<plugins>
			<plugin>
				<groupId>org.apache.maven.plugins</groupId>
				<artifactId>maven-surefire-plugin</artifactId>
				<version>2.6</version>
				<configuration>
					<argLine>${maven.test.jvmargs}</argLine>
				</configuration>
			</plugin>
		</plugins>
	</build>

转自：http://ralf0131.blogbus.com/logs/75672327.html
参考：
http://blog.tfd.co.uk/2007/09/05/surefire-unit-test-arguments-in-maven-2/
http://maven.apache.org/plugins/maven-surefire-plugin/howto.html
http://mavenize.blogspot.com/2007/07/setting-command-line-arguments-for.html
都说Maven2是Ant的替代品，今天稍微使用了下Maven，记录备忘。
通过Maven单独运行一个Junit测试用例（无需配置surefire）：
mvn -Dtest=TestXXX test
为Maven运行添加JVM参数，比如想给运行Maven的JVM分配更多内存，或者进行profiling等。有两种方法，一种是全局方法，即设置一个全局的环境变量MAVEN_OPTS。
linux下可修改.profile或者.bash_profile文件：export MAVEN_OPTS="$MAVEN_OPTS -Xmx1024m"
windows下可以添加环境变量MAVEN_OPTS
这样对于所有的maven进程都会启用这个JVM参数，所以是一个全局变量，具体可在bin\mvn.bat或者mvn.sh文件中找到如下内容：(%MAVEN_OPTS%即为全局JVM参数）
@REM Start MAVEN2
:runm2
%MAVEN_JAVA_EXE% %MAVEN_OPTS% -classpath %CLASSWORLDS_JAR% "-Dclassworlds.conf=%M2_HOME%\bin\m2.conf" "-Dmaven.home=%M2_HOME%" org.codehaus.classworlds.Launcher %MAVEN_CMD_LINE_ARGS%
如果有更加specific的需求，比如要单独运行一个JUnit Testcase，并且要fork出一个新的JVM来运行，还要为这个JVM加上特定的参数，那就需要更改项目的pom.xml文件了。具体方法是，修改 项目的pom.xml在<build>-><plugins>，添加一个plugin，目的是配置surefire，使得 每运行一个testcase，都单独fork出一个新的JVM来运行，若还要添加JVM参数，则可通过maven.test.jvmargs来进行传递:
<plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <configuration>
            <forkMode>pertest</forkMode>
            <argLine>${maven.test.jvmargs}</argLine>
        </configuration>
</plugin>
然后在<properties>标签下加入，这样maven能够知道maven.test.jvmargs这个参数存在，默认值为空，通过运行时命令行传入：
<deploy.target/>
<maven.test.jvmargs></maven.test.jvmargs>
最后通过如下命令来运行，其中-Dtest是需要运行的testcase的名称，-Dmaven.test.jvmargs指需要传入的JVM参数，maven将这个参数传给新的fork出来的JVM运行。
mvn -Dtest=TestXXX -Dmaven.test.jvmargs='-agentlib:xxxagent -Xmx128m' test

