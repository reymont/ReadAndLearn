

xargs的一个选项-I，使用-I指定一个替换字符串{}，这个字符串在xargs扩展时会被替换掉，当-I与xargs结合使用，每一个参数命令都会被执行一次：

cat arg.txt | xargs -I {} ./sk.sh -p {} -l

-p aaa -l
-p bbb -l
-p ccc -l
复制所有图片文件到 /data/images 目录下：

ls *.jpg | xargs -n1 -I cp {} /data/images

## 参考

1. http://man.linuxde.net/xargs