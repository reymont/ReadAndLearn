

```groovy
node('master'){
def M3=tool 'M3'
def pomDir=''
def S3=tool 'S3'
def pushDockerImage='docker.cloudos.yihecloud.com/cloudos/ros:5.0-$BUILD_TIMESTAMP'
def scm_git_url='git@git.yihecloud.com:IaaS/res-service-engine.git'
def scm_git_credentialId='credential_1496064914173'
def scm_git_branch='v5-beta'
if (isUnix()) {
stage('更新代码'){
parallel'1_更新代码_git_task_1499745823618': {
def credentialId="credential_1496064914173"
def branch="v5-beta"
def url="git@git.yihecloud.com:IaaS/res-service-engine.git"
checkout([$class: 'GitSCM', branches: [[name: branch]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: credentialId, url: url]]])

}
}
stage('代码编译'){
dir("$pomDir"){
parallel'1_代码编译_all_task_1499745823621': {
def workspace="$pomDir"
def cmd="$M3/bin/mvn -Dmaven.test.failure.ignore clean install cobertura:cobertura -Dcobertura.report.format=xml"
sh cmd
}
}
}
stage('代码检查'){
parallel'1_代码检查_sonar_task_1500609019274': {
def workspace=""
def sonarURL="http://sonar.service.ob.local:9000"
def credentialId="credential_default_01"
sh "$S3/bin/sonar-scanner -Dsonar.host.url=${sonarURL} -X -Dsonar.login=${credentialId} -Dsonar.projectName=${JOB_NAME} -Dsonar.projectVersion='1.0' -Dsonar.projectKey=${JOB_NAME} -Dsonar.sources='.'"
}
}
stage('单元测试'){
parallel'1_单元测试_junit_report_task_1499745989929': {
def testResults="**/surefire-reports/**/*.xml"
junit allowEmptyResults: true, healthScaleFactor: 0.0, testResults: testResults
}
parallel'2_null_null_task_1499745998045': {
def coberturaReportFile="**/target/site/cobertura/coverage.xml"
null
}
}
stage('打包'){
dir("$pomDir"){
parallel'1_打包_docker_task_1499748454044': {
def dockerServer="192.168.31.251:2375"
def resUrl="https://docker.cloudos.yihecloud.com"
def workspace="$pomDir"
def resCredentialsId="credential_1497513358569"
def outPutImage="$pushDockerImage"
withDockerServer([uri: dockerServer]) {
		withDockerRegistry([credentialsId: resCredentialsId, url: resUrl]) {
    		def image = docker.build(outPutImage)
    		image.push();
		}
}
}
}
}
stage('归档'){
parallel'1_归档_all_task_1499745823630': {
def workspace=""
def excludes=""
def includes="**/*.jar"
archiveArtifacts allowEmptyArchive: true, artifacts: includes, excludes: excludes
}
}
stage('部署'){
}
stage('自动测试'){
}
} else {
stage('更新代码'){
parallel'1_更新代码_git_task_1499745823618': {
def credentialId="credential_1496064914173"
def branch="v5-beta"
def url="git@git.yihecloud.com:IaaS/res-service-engine.git"
checkout([$class: 'GitSCM', branches: [[name: branch]], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: credentialId, url: url]]])

}
}
stage('代码编译'){
dir("$pomDir"){
parallel'1_代码编译_all_task_1499745823621': {
def workspace="$pomDir"
def cmd="$M3/bin/mvn -Dmaven.test.failure.ignore clean install cobertura:cobertura -Dcobertura.report.format=xml"
bat cmd
}
}
}
stage('代码检查'){
parallel'1_代码检查_sonar_task_1500609019274': {
def workspace=""
def sonarURL="http://sonar.service.ob.local:9000"
def credentialId="credential_default_01"
bat "$S3/bin/sonar-scanner -Dsonar.host.url=${sonarURL} -X -Dsonar.login=${credentialId} -Dsonar.projectName=${JOB_NAME} -Dsonar.projectVersion='1.0' -Dsonar.projectKey=${JOB_NAME} -Dsonar.sources='.'"
}
}
stage('单元测试'){
parallel'1_单元测试_junit_report_task_1499745989929': {
def testResults="**/surefire-reports/**/*.xml"
junit allowEmptyResults: true, healthScaleFactor: 0.0, testResults: testResults
}
parallel'2_null_null_task_1499745998045': {
def coberturaReportFile="**/target/site/cobertura/coverage.xml"
null
}
}
stage('打包'){
dir("$pomDir"){
parallel'1_打包_docker_task_1499748454044': {
def dockerServer="192.168.31.251:2375"
def resUrl="https://docker.cloudos.yihecloud.com"
def workspace="$pomDir"
def resCredentialsId="credential_1497513358569"
def outPutImage="$pushDockerImage"
withDockerServer([uri: dockerServer]) {
		withDockerRegistry([credentialsId: resCredentialsId, url: resUrl]) {
    		def image = docker.build(outPutImage)
    		image.push();
		}
}
}
}
}
stage('归档'){
parallel'1_归档_all_task_1499745823630': {
def workspace=""
def excludes=""
def includes="**/*.jar"
archiveArtifacts allowEmptyArchive: true, artifacts: includes, excludes: excludes
}
}
stage('部署'){
}
stage('自动测试'){
}
}
}

```