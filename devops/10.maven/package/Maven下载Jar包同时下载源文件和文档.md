Maven下载Jar包同时下载源文件和文档


Maven下载Jar包同时下载源文件和文档


示例:
mvn eclipse:eclipse -DdownloadSources -DdownloadJavadocs 


参考:
http://stackoverflow.com/questions/310720/get-source-jar-files-attached-to-eclipse-for-maven-managed-dependencies

http://piotrga.wordpress.com/2009/06/25/how-to-download-javadocs-or-sources-in-maven-2/ 
mvn dependency:sources 
mvn dependency:resolve -Dclassifier=javadoc
第一个命令去取所有在POM中的的source code,第二个去取Javadocs


http://stackoverflow.com/questions/2059431/get-source-jars-from-maven-repository


 


