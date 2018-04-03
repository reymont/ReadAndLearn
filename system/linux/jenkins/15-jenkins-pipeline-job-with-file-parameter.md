

https://stackoverflow.com/questions/38080876/jenkins-pipeline-job-with-file-parameter

# 批准加载java代码
http://172.20.62.42:8080/scriptApproval/

There is currently an issue with pipeline and file parameter (https://issues.jenkins-ci.org/browse/JENKINS-27413).


Solved it the following way:

node {
    deleteDir()
    stage("upload") {
        def inputFile = input message: 'Upload file', parameters: [file(name: 'data.zip')]
        new hudson.FilePath(new File("$workspace/data.zip")).copyFrom(inputFile)
        inputFile.delete()
    }
    stage("checkout") {
        echo fileExists('data.zip').toString()

    }
}
I know the solution is not that beautiful because the pipeline gets interrupted for the upload but it works.

Further the "copyFrom" is necessary, because the input stores the "data.zip" in the jobs directory and not in the workspace (don't know why)