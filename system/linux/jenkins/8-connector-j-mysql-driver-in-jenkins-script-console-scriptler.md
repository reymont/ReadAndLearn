https://stackoverflow.com/questions/26614316/connector-j-mysql-driver-in-jenkins-script-console-scriptler

Finaly i figured out how to use MySQL JDBC driver with Scriptler:

Find out the default JAVA classpath dirs (run in Jenkins Script Console):
println System.getProperty("java.ext.dirs")

/usr/lib/jvm/java-7-openjdk-amd64/jre/lib/ext:/usr/java/packages/lib/ext
Download an add mysql-connector-java-*.jar to default Java classpath:
cp mysql-connector-java-*.jar /usr/java/packages/lib/ext/

Restart Jenkins
Jenkins jobs and Scriptler / Groovy scripts should now work without any additional parameter like CLASSPATH.