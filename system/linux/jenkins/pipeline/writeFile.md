

http://www.cnblogs.com/itech/p/5646219.html

readFile为groovy的函数用来从workspace里读取文件返回文件的内容，同时还可以使用writeFile来保存内容到文件，fileExists用来判断文件是否存在；

3. 创建多线程

pipeline能够使用parallel来同时执行多个任务。 parallel的调用需要传入map类型作为参数，map的key为名字，value为要执行的groovy脚本。
为了测试parallel的运行，可以安装parallel test executor插件。此插件可以将运行缓慢的测试分割splitTests。

用下面的脚本新建pipeline job：

```groovy
node('remote') {
    git url: 'https://github.com/jenkinsci/parallel-test-executor-plugin-sample.git'
        archive 'pom.xml, src/'
    }
    def splits = splitTests([$class: 'CountDrivenParallelism', size: 2])
    def branches = [:]
    for (int i = 0; i < splits.size(); i++) {
        def exclusions = splits.get(i);
        branches["split${i}"] = {
        node('remote') {
            sh 'rm -rf *'
            unarchive mapping: ['pom.xml' : '.', 'src/' : '.']
            writeFile file: 'exclusions.txt', text: exclusions.join("\n")
            sh "${tool 'M3'}/bin/mvn -B -Dmaven.test.failure.ignore test"
            step([$class: 'JUnitResultArchiver', testResults: 'target/surefire-reports/*.xml'])
        }
    }
}
parallel branches
```