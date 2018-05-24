


# overwrite

> curl http://mysite.com/myfile.jpg > myfile.jpg

* [filenames - How can I specify that curl (via command line) overwrites a file if it already exists? - Unix & Linux Stack Exchange ](https://unix.stackexchange.com/questions/19608/how-can-i-specify-that-curl-via-command-line-overwrites-a-file-if-it-already-e)


* [CURL常用命令 - 张贺 - 博客园 ](http://www.cnblogs.com/gbyukg/p/3326825.html)
通过-o/-O选项保存下载的文件到指定的文件中：
-o：将文件保存为命令行中指定的文件名的文件中
-O：使用URL中默认的文件名保存文件到本地

```sh
# 将文件下载到本地并命名为mygettext.html
curl -o mygettext.html http://www.gnu.org/software/gettext/manual/gettext.html

# 将文件保存到本地并命名为gettext.html
curl -O http://www.gnu.org/software/gettext/manual/gettext.html
```