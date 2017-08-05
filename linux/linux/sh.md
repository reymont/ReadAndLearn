
* [Shell脚本调试技术 ](https://www.ibm.com/developerworks/cn/linux/l-cn-shell-debug/)

```sh
$ sh –x exp2.sh
+ trap 'echo "before execute line:$LINENO, a=$a,b=$b,c=$c"' DEBUG
++ echo 'before execute line:3, a=,b=,c='
before execute line:3, a=,b=,c=
+ a=1
++ echo 'before execute line:4, a=1,b=,c='
before execute line:4, a=1,b=,c=
+ '[' 1 -eq 1 ']'
++ echo 'before execute line:6, a=1,b=,c='
before execute line:6, a=1,b=,c=
+ b=2
++ echo 'before execute line:10, a=1,b=2,c='
before execute line:10, a=1,b=2,c=
+ c=3
++ echo 'before execute line:11, a=1,b=2,c=3'
before execute line:11, a=1,b=2,c=3
+ echo end
end
```