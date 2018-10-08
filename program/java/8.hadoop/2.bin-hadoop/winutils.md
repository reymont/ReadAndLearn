


Problems running Hadoop on Windows
Hadoop requires native libraries on Windows to work properly -that includes to access the file:// filesystem, where Hadoop uses some Windows APIs to implement posix-like file access permissions.

This is implemented in HADOOP.DLL and WINUTILS.EXE.

In particular, %HADOOP_HOME%\BIN\WINUTILS.EXE must be locatable.

If it is not, Hadoop or an application built on top of Hadoop will fail.


## 参考

1. https://github.com/steveloughran/winutils
2. https://wiki.apache.org/hadoop/WindowsProblems