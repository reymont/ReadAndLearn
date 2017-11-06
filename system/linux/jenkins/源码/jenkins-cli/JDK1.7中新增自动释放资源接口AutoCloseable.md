

https://yq.aliyun.com/articles/43519


新增了try-with-resource 异常声明

在JDK7中只要实现了AutoCloseable或Closeable接口的类或接口，都可以使用`try-with-resource`来实现异常处理和资源关闭

异常抛出顺序。在Java se 7中的try-with-resource机制中异常的抛出顺序与Java se 7以前的版本有一点不一样。

`是先声明的资源后关闭`

JDK7以前如果rd.readLine()与rd.close()(在finally块中）都抛出异常则只会抛出finally块中的异常，不会抛出rd.readLine()；中的异常。这样经常会导致得到的异常信息不是调用程序想要得到的。

JDK7及以后版本中如果采用try-with-resource机制，如果在try-with-resource声明中抛出异（可能是文件无法打或都文件无法关闭）同时rd.readLine()；也势出异常，则只会势出rd.readLine（）的异常。


```java
package hudson.cli;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;

public class Main {
    //声明资源时要分析好资源关闭顺序,先声明的后关闭
    //在try-with-resource中也可以有catch与finally块。
    //只是catch与finally块是在处理完try-with-resource后才会执行。
    public static void main(String[] args) {
        try (Resource res = new Resource();
             ResourceOther resOther = new ResourceOther();) {
            res.doSome();
            resOther.doSome();
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }

    //JDK1.7以前的版本，释放资源的写法
    static String readFirstLingFromFile(String path) throws IOException {
        BufferedReader br = null;
        try {
            br = new BufferedReader(new FileReader(path));
            return br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (br != null)
                br.close();
        }
        return null;
    }

    //JDK1.7中的写法，利用AutoCloseable接口
    //代码更精练、完全
    static String readFirstLineFromFile(String path) throws IOException {
        try (BufferedReader br = new BufferedReader(new FileReader(path))) {
            return br.readLine();
        }
    }
}

class Resource implements AutoCloseable {
    void doSome() {
        System.out.println("do something");
    }

    @Override
    public void close() throws Exception {
        System.out.println("resource closed");
    }
}

class ResourceOther implements AutoCloseable {
    void doSome() {
        System.out.println("do something other");
    }

    @Override
    public void close() throws Exception {
        System.out.println("other resource closed");
    }
}
```