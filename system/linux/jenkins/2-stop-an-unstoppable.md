
# https://stackoverflow.com/questions/14456592/how-to-stop-an-unstoppable-zombie-job-on-jenkins-without-restarting-the-server

Go to "Manage Jenkins" > "Script Console" to run a script on your server to interrupt the hanging thread.

You can get all the live threads with Thread.getAllStackTraces() and interrupt the one that's hanging.

Thread.getAllStackTraces().keySet().each() {
  t -> if (t.getName()=="YOUR THREAD NAME" ) {   t.interrupt();  }
}

Worked great! For anyone reading, you can view the thread names by first running the above, with the method calling t -> println(t.getName());


# http://172.20.62.42:8080/script

```groovy
Thread.getAllStackTraces().keySet().each() {
  t -> println(t.getId()+ "\t"+t.getName());println(t.getId()+ "\t"+t.getName())
}
```