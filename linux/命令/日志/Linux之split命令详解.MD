

Linux之split命令详解_linux shell_脚本之家 
http://www.jb51.net/article/73632.htm

命令功能：切割文件，将文件以行为单位或以字节为单位进行切割
命令语法：
split [–help][–version]
split [-<行数>][-l <行数>] [要切割的文件][输出文件名] 
，以行数为单位
split [-b <字节>][-C <字节>] [要切割的文件][输出文件名]，以字节为单位
输出文件名是指切割后的文件会以此为前缀。
1. 以行为单位切割文件
首先创建一个有5行的文件hello，
#cat hello
Hello, World1
Hello, World2
Hello, World3
Hello, World4
Hello, World5
使用命令：
#split -2 hello split1_
split命令会将文件以两行为单位进行切割，每两行组成一个新文件，5行就有三个文件，名称会分别为：
split1_aa , split1_ab , split_ac
2. 以字节为单位的切割
还是文件hello，使用命令ls -l hello 可以看到文件的大小为65字节，以10字节切割文件，会有7个文件
先使用-b命令，如下：
#split -b 10 hello split2_
文件切出来有7个，
split2_aa , split2_ab , split2_ac , split2_ad , split2_ae , split2_af , split2_ag
下面使用-C参数，如下：
#split -C 10 hello split3_
切出了10个文件，用ls -l 命令输出如下：

虽然同样是以字节为单位切割文件，但-C参数会尽量保持每行的完整性，也就是说，一行有13个字节，那么会切割成两个文件，一个10字节，一个3字节，而-b参数会将8字节累计到下一行凑足十字节再切，所以-b参数只有7个文件，而-C参数有10个文件。