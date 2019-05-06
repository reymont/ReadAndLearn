

hudson.cli.CLI


# main

```java
    public static void main(final String[] _args) throws Exception {
        try {
            System.exit(_main(_args));
        } catch (NotTalkingToJenkinsException ex) {
            System.err.println(ex.getMessage());
            System.exit(3);
        } catch (Throwable t) {
            // if the CLI main thread die, make sure to kill the JVM.
            t.printStackTrace();
            System.exit(-1);
        }
    }
```

## _main


### JENKINS_URL的判断



```java
//检查环境变量有没有

        String url = System.getenv("JENKINS_URL");

        if (url==null)
            url = System.getenv("HUDSON_URL");
```

java -jar jenkins-cli.jar -s http://10.31.1.236:8080/ delete-builds job 1-1230

```java
//-s 指定url，剩下的参数存到args
            if(head.equals("-s") && args.size()>=2) {
                url = args.get(1);
                args = args.subList(2,args.size());
                continue;
            }
```

```java
//不设置 mode的话，默认为Mode.HTTP
        if (mode == null) {
            mode = Mode.HTTP;
        }
//HTTP模式下，直接使用httpConnection访问
        if (mode == Mode.HTTP) {
            return plainHttpConnection(url, args, factory);
        }
//发送请求参数 delete-builds java 1-1230
            for (String arg : args) {
                connection.sendArg(arg);
            }
```



## ping请求
https://issues.jenkins-ci.org/browse/JENKINS-46659