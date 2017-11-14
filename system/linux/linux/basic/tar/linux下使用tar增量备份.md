

linux下使用tar增量备份 - 聆听未来 - 51CTO技术博客 http://kerry.blog.51cto.com/172631/291580/


linux下使用tar增量备份
使用 tar -g 参数进行增量备份实验
完整备份:
```sh
#建立测试路径与档案
mkdir kerryhu
touch kerryhu/{a,b,c}
在kerryhu下生成三个文件
#执行完整备份
tar -g king -zcvf  kerryhu_full.tar.gz kerryhu
cat king
1270531376
#查看 tarball 内容
tar -ztf kerryhu_full.tar.gz
kerryhu/
kerryhu/a
kerryhu/b
kerryhu/c
增量备份:
#新增一个档案
touch kerryhu/d
#执行第一次的增量备份
tar -g king -zcvf kerryhu_diff_1.tar.gz kerryhu
#查看第一次增量备份的内容
tar -ztf kerryhu_diff_1.tar.gz
kerryhu/
kerryhu/d
#新增一个档案, 并异动一个档案内容
touch kerryhu/e
echo "test" > kerryhu/a
#执行第二次的增量备份
tar -g king -zcvf kerryhu_diff_2.tar.gz kerryhu
cat king
1270532463
#查看第二次增量备份的内容
tar -ztf kerryhu_diff_2.tar.gz
kerryhu/
kerryhu/a
kerryhu/e
还原备份资料:
#清空测试资料
rm -rf #查看第一次增量备份的内容
#开始进行资料还原
tar -zxvf kerryhu_full.tar.gz
tar -zxvf kerryhu_diff_1.tar.gz
tar -zxvf kerryhu_diff_2.tar.gz
#查看测试资料
ls kerryhu
a b c d e
 
cat kerryhu/a
test
```