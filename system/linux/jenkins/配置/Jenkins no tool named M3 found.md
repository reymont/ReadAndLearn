
* [Pipeline Maven Plugin - Jenkins - Jenkins Wiki ](https://wiki.jenkins.io/display/JENKINS/Pipeline+Maven+Plugin)
* [maven - Jenkins: no tool named M3 found - Stack Overflow ](https://stackoverflow.com/questions/39260508/jenkins-no-tool-named-m3-found)

make sure that the maven installation is configured in hudson.tasks.Maven.xml as below with name you want (I have MAVEN3 below),

cat /var/lib/jenkins/hudson.tasks.Maven.xml

```xml
<?xml version='1.0' encoding='UTF-8'?>
<hudson.tasks.Maven_-DescriptorImpl>
  <installations>
    <hudson.tasks.Maven_-MavenInstallation>
      <name>MAVEN3</name>
      <home>/usr/share/apache-maven/</home>
      <properties/>
    </hudson.tasks.Maven_-MavenInstallation>
  </installations>
</hudson.tasks.Maven_-DescriptorImpl>
```
Followed by jenkins restart

systemctl restart jenkins.service
It can be verified in UI as well,

maven installation name

Then, same variable can be used in pipeline script.

```groovy
node {
   def mvnHome
   stage('Preparation') {
      git url: 'https://github.com/prayagupd/eccount-rest.git', branch: 'REST-API-load-balancing'
      mvnHome = tool 'MAVEN3'
   }
   stage('Build') {
      sh "'${mvnHome}/bin/mvn' -Dmaven.test.failure.ignore clean package"
   }
   stage('Results') {
      junit '**/target/surefire-reports/TEST-*.xml'
      archive 'target/*.jar'
   }
}
```