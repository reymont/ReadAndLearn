

https://stackoverflow.com/questions/14456592/how-to-stop-an-unstoppable-zombie-job-on-jenkins-without-restarting-the-server

### http://172.20.62.100:8080/script
### 脚本命令行
```groovy
Thread.getAllStackTraces().keySet().each() {
  t -> println t
}
Jenkins.instance.getItemByFullName("talent").getBuildByNumber(59).finish(hudson.model.Result.ABORTED, new java.io.IOException("Aborting build"));
```

Go to "Manage Jenkins" > "Script Console" to run a script on your server to interrupt the hanging thread.

You can get all the live threads with Thread.getAllStackTraces() and interrupt the one that's hanging.

Thread.getAllStackTraces().keySet().each() {
  t -> if (t.getName()=="YOUR THREAD NAME" ) {   t.interrupt();  }
}
UPDATE:

The above solution using threads may not work on more recent Jenkins versions. To interrupt frozen pipelines refer to this solution (by alexandru-bantiuc) instead and run:

`Jenkins.instance.getItemByFullName("JobName").getBuildByNumber(JobNumber).finish(hudson.model.Result.ABORTED, new java.io.IOException("Aborting build"));`

Worked great! For anyone reading, you can view the thread names by first running the above, with the method calling 

`t -> println(t.getName());`

Go to "Manage Jenkins" > "Script Console" and run a script:

`Jenkins.instance.getItemByFullName("JobName").getBuildByNumber(JobNumber).finish(hudson.model.Result.ABORTED, new java.io.IOException("Aborting build")); `
You'll have just specify your JobName and JobNumber.