dependency下载sources和 javadoc 2012/10/16

mvn dependency:sources 
mvn dependency:resolve -Dclassifier=javadoc
mvn dependency:sources dependency:resolve -Dclassifier=javadoc eclipse:eclipse

