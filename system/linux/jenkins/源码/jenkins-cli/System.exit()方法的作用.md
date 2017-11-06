

http://blog.csdn.net/bbirdsky/article/details/46461319

查看java.lang.System的源代码，我们可以看到System.exit()这个方法等价于Runtime.exit()，代码如下：

```java
/** 
 * Terminates the currently running Java Virtual Machine. The 
 * argument serves as a status code; by convention, a nonzero status 
 * code indicates abnormal termination. 
 * <p> 
 * This method calls the <code>exit</code> method in class 
 * <code>Runtime</code>. This method never returns normally. 
 * <p> 
 * The call <code>System.exit(n)</code> is effectively equivalent to 
 * the call: 
 * <blockquote><pre> 
 * Runtime.getRuntime().exit(n) 
 * </pre></blockquote> 
 * 
 * @param      status   exit status. 
 * @throws  SecurityException 
 *        if a security manager exists and its <code>checkExit</code> 
 *        method doesn't allow exit with the specified status. 
 * @see        java.lang.Runtime#exit(int) 
 */  
public static void exit(int status) {  
    Runtime.getRuntime().exit(status);  
}  
```

从方法的注释中可以看出此方法是结束当前正在运行的Java虚拟机，这个status表示退出的状态码，非零表示异常终止。注意：不管status为何值程序都会退出，和return 相比有不同的是：return是回到上一层，而System.exit(status)是回到最上层。

System.exit(0)：不是很常见，做过swing开发的可能用过这方法，一般用于Swing窗体关闭按钮。（重写windowClosing方法时调用System.exit(0)来终止程序，Window类的dispose()方法只是关闭窗口，并不会让程序退出）。
System.exit(1)：非常少见，一般在Catch块中会使用（例如使用Apache的FTPClient类时，源码中推荐使用System.exit(1)告知连接失败），当程序会被脚本调用、父进程调用发生异常时需要通过System.exit(1)来告知操作失败，默认程序最终返回的值返是0，即然发生异常默认还是返回0，因此在这种情况下需要手工指定返回非零。