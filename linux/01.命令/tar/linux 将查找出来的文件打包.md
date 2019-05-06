
http://daniel.leanote.com/post/linux-%E5%B0%86%E6%9F%A5%E6%89%BE%E5%87%BA%E6%9D%A5%E7%9A%84%E6%96%87%E4%BB%B6%E6%89%93%E5%8C%85
http://blog.csdn.net/zz7zz7zz/article/details/46239543
http://bbs.csdn.net/topics/390743328

```sh
tar cvf f.tar $(ll */*810_8* | awk '{print $9}')
#如：当前目录下查找5月25日的文件并打包
ll -lrt  | grep May\ 25 | awk '{print $9}' | xargs  tar -zcvf /home/DexYang/userser0525.tar.gz
find A  -name  "*.h"  |xargs  tar zcvf only.tar
```