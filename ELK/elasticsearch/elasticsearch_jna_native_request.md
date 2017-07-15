原文：[Advanced tools: playing with Java Native Access - Layer4](https://layer4.fr/blog/2016/10/17/advanced-tools-playing-with-java-native-access/)

Advanced tools: playing with Java Native Access  
高级工具:使用Java本机访问

By Vincent DEVILLERS  Java  October 17, 2016  
This post results from a recent deep diving in the source code of Elasticsearch, which uses JNA mainly for memory management when configuring the mlockall. I will present you how to use JNA in a very simple example: how to check the user who has launched the JVM.  
这篇文章是最近对Elasticsearch的源代码深入研究的总结，它主要使用JNA进行内存管理。  
这篇文章的结果是最近对Elasticsearch的源代码中进行了深入的研究。在配置mlockall时，Elasticsearch主要使用JNA进行内存管理。这里将向您展示如何在一个简单的示例中使用JNA：如何检查启动JVM的用户。

Note  
Remember that when you are thinking about solution using OS native calls, you must deal and depend with platform librairies. So use it carefully and only for specific needs.  
请记住，当你使用本机操作系统原生调用来考虑解决方案时，必须依赖于平台应用库进行处理，请针对特定的环境谨慎地使用。

First of all, we need JNA:  
首先，需要JNA

    <dependency>
      <groupId>net.java.dev.jna</groupId>
      <artifactId>jna</artifactId>
      <optional>true</optional>
      <version>3.2.3</version>
    </dependency>

Now let’s encapsulate the JNA calls in 2 dedicated classes, a specific JNA class using the C library and a facade for all native calls using JNA:  
现在，将JNA封装在两个专用类中，一个使用C代码库的JNA类，以及一个使用JNA类来触发系统原生调用的门面类（facade）。

    public final class JNANatives {

        /** no instantiation */
        private JNANatives() {}

        /**
         * Returns true if user is root, false if not, or if we don't know
         */
        public static boolean isRunningAsRoot() {
            return getUid() == 0;
        }

        public static int getUid() {
            if (System.getProperty("os.name").startsWith("Windows")) {
                return -1; // don't know
            }
            try {
                return JNACLibrary.geteuid();
            } catch (UnsatisfiedLinkError e) {
                return -1;
            }
        }
    }

    import com.sun.jna.Native;
    import lombok.extern.slf4j.Slf4j;

    @Slf4j
    public static final class JNACLibrary {

        static {
            try {
                Native.register("c");
            } catch (UnsatisfiedLinkError e) {
                log.warn("Unable to link C library, native methods (geteuid) are disabled.", e);
            }
        }

        static native int geteuid();

        private JNACLibrary() {
        }
    }

Now with a simple test:  
简单的测试用例

    public class RootTest {

        @Test
        public void test() {

            System.err.println("Running with uid: " + JNANatives.getUid() + " (is root? -> " + JNANatives.isRunningAsRoot() + ")");
            Assert.assertFalse(JNANatives.isRunningAsRoot());
        }
    }

When running this test with my profile:  
使用devil和root两个用户来执行测试用例

    $ whoami
    devil
    $ cat /etc/passwd | grep devil
    devil:x:1000:1000:devil,,,:/home/devil:/usr/bin/zsh
    the result is:

    Running with uid: 1000 (is root? -> false)
    $ whoami
    root
    $ cat /etc/passwd | grep root
    root:x:0:0:root:/root:/bin/zsh
    the result is:

    Running with uid: 0 (is root? -> true)

Credits:  
– by Markus Spiske, licensed under CC0 1.0