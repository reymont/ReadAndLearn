scm Maven结合svn进行版本管理

http://hi.baidu.com/victorlin23/item/2fa37c7d27b924295c178997

svn仓库的根目录下创建三个文件夹：/trunk, branches/, tags/。分别用来存放主干，分支，以及标签。 

Pom.xml 里设置 

<!-- svn --> 

<scm>
<!--connection, developerConnection: 都是连接字符串，其中后者是具有write权限的scm连接 -->
<connection>scm:svn:http://10.123.76.115:8080/svn/bravo2/03 开发区/04 源代码/tags/bravo-2.0</connection>
<developerConnection>scm:svn:http://10.123.76.115:8080/svn/bravo2/03 开发区/04 源代码/tags/bravo-2.0</developerConnection>
</scm>

<distributionManagement>
   <snapshotRepository>
    <id>nexus-snapshots</id>
    <name>Nexus Release Repository</name>
    <url>http://10.123.76.13:8787/nexus/content/repositories/snapshots/
    </url>
   </snapshotRepository>
   <repository>
    <id>nexus-releases</id>
    <name>Nexus Release Repository</name>
    <url>http://10.123.76.13:8787/nexus/content/repositories/releases/
    </url>
   </repository>
</distributionManagement>


<!-- maven-release --> 
<plugin>

<groupId>org.apache.maven.plugins</groupId>

<artifactId>maven-release-plugin</artifactId>

<configuration> 

<tagBase>http://10.123.76.115:8080/svn/bravo2/03 开发区/04 源代码/tags/</tagBase> 

<username>userName</username> 

<password>password</password> 

<releaseProfiles>release</releaseProfiles> 

</configuration> 

</plugin>
.xml的配置：
<!--配置deploy服务器认证的用户名密码-->
    <server>
      <id>nexus-releases</id>
      <username>admin</username>
      <password>travelsky</password>
    </server>
              
    <server>
      <id>nexus-snapshots</id>
      <username>admin</username>
      <password>travelsky</password>
    </server>


发布执行 

执行发布命令前要确保class生成目录不作为svn监管对象，这里是target目录，否则出错。 POM中的版本号要带-SNAPSHOT 

1．   执行命令：mvn release:prepare 

执行过程中，会遇到 发布什么版本号？发布的tag标签名称是什么？主干上新的版本是什么？ 的提问，一般直接默认既可，maven每次会自动加加 

然后，tags里会多出/project-1.0 ，这就是需要发布的版本1.0，同时trunk中的POM，其版本自动升级成了1.1-SNAPSHOT。 

2．    执行命令：mvn release:perform 

maven-release-plugin会自动帮我们签出刚才打的tag，然后打包，分发到远程Maven仓库中，至此，整个版本的升级，打标签，发布等工作全部完成。我们可以在远程Maven仓库 中看到正式发布的版本。 


在执行mvn release:prepare命令出错的时候，MAVEN对中间修改过的pom文件不做会滚，这时候再执行mvn release:prepare的话出错， 

比如pom中的版本号中的-SNAPSHOT没有了，（maven发布时会先把-SNAPSHOT号先去掉，发布完成后再加上版本号添上去），所以万一出错，改好错误后，把POM文件恢复到 

之前的样子，再重新发布。还有执行前要确保：CMD下 svn --version能执行，就是要在PATH中加svn的环境变量，如F:\Program Files\Subversion\bin

