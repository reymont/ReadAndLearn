再转一篇：linux命令之sed, awk, grep, cut篇_大小孩_新浪博客 http://blog.sina.com.cn/s/blog_61c006ea0100nf1g.html

linux命令之sed, awk, grep, cut篇
用下来感觉这4个命令比较常用，功能也比较强大，等我有时间了要好好整理一下。
首先介绍一下cut，之前有文章已经讲过它的用法了，这次连带cut的死对头paste，一起拎出来讲讲。
第一篇 cut
常用参数：
-c 根据字符，用法：cut -cnum1-num2 filename 截取num1～num2之间的字符，字符从1开始记。
-f 根据域，默认为tab分隔
-d 定义域分隔符
范例：
shell> cat example
test2
this is test1
shell> cut -c1-6 example ## print 开头算起前 6 个字元
test2
this i
-c m-n 表示显示每一行的第m个字元到第n个字元。例如：
---------file-----------
liubi 23 14000
---------file-----------
# cut -c 1-5,10-14 file
liubi 14000
-f m-n 表示显示第m栏到第n栏(使用tab分隔)。例如：
---------file-----------
liubi 23 14000
---------file-----------
# cut -f 1,3 file
liubi 14000
-c 和 －f 参数可以跟以下子参数：
m 第m个字符或字段
m- 从第m个字符或字段到文件结束
m-n 从第m个到第n个字符或字段
-n 从第1个到第n个字符或字段
我们经常会遇到需要取出分字段的文件的某些特定字段，例如 /etc/password就是通过":"分隔各个字段的。可以通过cut命令来实现。例如，我们希望将系统账号名保存到
特定的文件，就可以：
cut -d: -f 1 /etc/passwd > /tmp/users
-d用来定义分隔符，默认为tab键，-f表示需要取得哪个字段
如：
使用|分隔
cut -d'|' -f2 1.test>2.test
使用:分隔
cut -d':' -f2 1.test>2.test
这里使用单引号或双引号皆可。
对于特殊字符用\来转义（以“-”为分隔符切割后，要第一个字段）：
BGIOSGA005099-TA
BGIOSGA005310-TA
cut -d\- -f 1 file >out
或者：cut "\-" -f 1 file >out
cut的死对头：paste
paste file1 file2 >file3
把文件1与文件2按列合并（有没有发现跟cut正好相反呢？）
$ less 111
abc ddd eee
$ less 222
123 444 555
$ paste 111 222 >333
$ less 333
abc ddd eee     123 444 555
用-d参数可以自定义分隔符
$ paste -d: 111 222 >444
$ less 444
abc ddd eee:123 444 555
paste命令还有一个很有用的选项"-"。意即对每一个"-"，从标准输入中读一次数据。-d参数来定义分隔符。以一个3列格式显示目录列表。方法如下：
$ ls |paste -d: - - -     #注意，"-"和"-"之间有空格
block_info_down_1000:block_info_down_3000:sv_test
block_info_up1000:block_info_up3000:module_indel_sv
module_test:old:regulation_region_down.pl
sample.Q20.down1000:sample.Q20.down3000:sample.Q20.up1000
sample.Q20.up3000:sample_to_9311.snp.Q20.filter.sort:sample_to_test
第二篇 awk
awk 用法：awk ' pattern {action} '
a w k语言的最基本功能是在文件或字符串中基于指定规则浏览和抽取信息
变量名 含义
ARGC 命令行变元个数
ARGV 命令行变元数组
FILENAME 当前输入文件名
FNR 当前文件中的记录号
FS 输入域分隔符，默认为一个空格
RS 输入记录分隔符
NF 当前记录里域个数
NR 到目前为止记录数
OFS 输出域分隔符
ORS 输出记录分隔符
用法介绍：
1,模式匹配
awk '/zqy/' fileA #寻找出fileA中含有zqy的行 等同于awk '$0~/zqy/' fileA
awk '$1~/88/' fileA #找出第一个域里面包含88的行
awk '$1~/88/{print $2}' fileA #找出第一个域里面包含88的行后，只打印该行的第二个域
2,对不同的域进行操作
awk '$2 >25 && $2<=55' fileA #找出第二个域里面满足条件的行，可以加上{print $n}来打印任意域
############### fileB #################
884     46      1       8       5       944
734     41      0       10      2       787
647     29      1       8       1       686
536     26      1       9       0       572
############### fileB #################
$ less fileB
884     46      1       8       5       944
734     41      0       10      2       787
647     29      1       8       1       686
536     26      1       9       0       572
$awk '{print NR,NF,$NF}' fileB # NR:文件当前记录号(在这里可以理解为行数); NF:总的域的个数(可以理解为列数); $NF:想一想是什么东西吧？再不知道就撞墙去吧。
1 6 944
2 6 787
3 6 686
4 6 572
3,通过-F参数来改变域分隔符，FS设置输入分隔符,OFS设置输出分隔符，awk所有操作都支持管道。如：
df | awk '$4>1000000 '          通过管道符获得输入，如：显示第4个域满足条件的行。
awk -F "|" '{print $1}' file 按照新的分隔符“|”进行操作。
awk 'BEGIN { FS="[: \t|]"}{print $1,$2,$3}' file 通过设置输入分隔符（FS="[: \t|]"）修改输入分隔符。BEGIN 表示在处理任意行之前进行的操作。
awk 'BEGIN { OFS="%"} {print $1,$2,$3}' file 通过设置输出分隔符（OFS="%"）修改输出格式。
Sep="|"
awk -F $Sep '{print $1}' file 按照环境变量Sep的值做为分隔符。   
awk -F '[ :\t|]' '{print $1}' file 按照正则表达式的值做为分隔符，这里代表空格、:、TAB、|同时做为分隔符。
awk -F '[][]' '{print $1}' file 按照正则表达式的值做为分隔符，这里代表[、]
4、
awk -f awkfile file 通过文件awkfile的内容依次进行控制。
cat awkfile
/101/{print "\047 Hello! \047"} --遇到匹配行以后打印 ' Hello! '.\047代表单引号。
{print $1,$2}                    --因为没有模式控制，打印每一行的前两个域。
5、
awk 'BEGIN { max=100 ;print "max=" max} {max=($1 >max ?$1:max); print $1,"Now max is "max}' file 取得文件第一个域的最大值。
awk '{print ($1>4 ? "high "$1: "low "$1)}' file

6、
awk '{$1 == 'Chi' {$3 = 'China'; print}' file 找到匹配行后先将第3个域替换后再显示该行（记录）。
awk '{$7 %= 3; print $7}' file 将第7域被3除，并将余数赋给第7域再打印。

7、
awk '/tom/ {wage=$2+$3; printf wage}' file 找到匹配行后为变量wage赋值并打印该变量。

8、
awk '/tom/ {count++;} END {print "tom was found "count" times"}' file #END表示在所有输入行处理完后进行处理。
9、awk 'gsub(/\$/,"");gsub(/,/,""); cost+=$4;END {print "The total is $" cost>"filename"}' file   gsub函数用空串替换$和,再将结果输出到filename中。
     1 2 3 $1,200.00
     1 2 3 $2,300.00
     1 2 3 $4,000.00
     awk '{gsub(/\$/,"");gsub(/,/,"");
     if ($4>1000&&$4<2000) c1+=$4;
     else if ($4>2000&&$4<3000) c2+=$4;
     else if ($4>3000&&$4<4000) c3+=$4;
     else c4+=$4; }
     END {printf   "c1=[%d];c2=[%d];c3=[%d];c4=[%d]\n",c1,c2,c3,c4}"' file
     通过if和else if完成条件语句
     awk '{gsub(/\$/,"");gsub(/,/,"");
     if ($4>3000&&$4<4000) exit;
     else c4+=$4; }
     END {printf   "c1=[%d];c2=[%d];c3=[%d];c4=[%d]\n",c1,c2,c3,c4}"' file
     通过exit在某条件时退出，但是仍执行END操作。
     awk '{gsub(/\$/,"");gsub(/,/,"");
     if ($4>3000) next;
     else c4+=$4; }
     END {printf   "c4=[%d]\n",c4}"' file
     通过next在某条件时跳过该行，对下一行执行操作。

10、awk '{ print FILENAME,$0 }' file1 file2 file3>fileall 把file1、file2、file3的文件内容全部写到fileall中，并前置文件名。

11、awk ' $1!=previous { close(previous); previous=$1 } {print substr($0,index($0," ") +1)>$1}' fileall 把合并后的文件重新分拆为3个文件。并与原文件一致。
12、awk 'BEGIN {"date"|getline d; print d}'          通过管道把date的执行结果送给getline，并赋给变量d，然后打印。
13、awk 'BEGIN {system("echo \"Input your name:\\c\""); getline d;print "\nYour name is",d,"\b!\n"}'
     通过getline命令交互输入name，并显示出来。
     awk 'BEGIN {FS=":"; while(getline< "/etc/passwd" >0) { if($1~"050[0-9]_") print $1}}'
     打印/etc/passwd文件中用户名包含050x_的用户名。
14、awk '{ i=1;while(i<NF) {print NF,$i;i++}}' file 通过while语句实现循环。
     awk '{ for(i=1;i<NF;i++) {print NF,$i}}'    file 通过for语句实现循环。    
     type file|awk -F "/" '
     { for(i=1;i<NF;i++)
     { if(i==NF-1) { printf "%s",$i }
     else { printf "%s/",$i } }}'                显示一个文件的全路径。
     用for和if显示日期
     awk   'BEGIN {
for(j=1;j<=12;j++)
{ flag=0;
   printf "\n%d月份\n",j;
         for(i=1;i<=31;i++)
         {
         if (j==2&&i>28) flag=1;
         if ((j==4||j==6||j==9||j==11)&&i>30) flag=1;
         if (flag==0) {printf "dd ",j,i}
         }
}
}'
15、在awk中调用系统变量必须用单引号，如果是双引号，则表示字符串
Flag=abcd
awk '{print '$Flag'}'    结果为abcd
awk '{print   "$Flag"}'    结果为$Flag
awk的用法
a w k语言的最基本功能是在文件或字符串中基于指定规则浏览和抽取信息
 
调用awk
有三种方式调用a w k，
第一种是命令行方式，如：
     awk –F : ‘commands’ input-files
    第二种方法是将所有a w k命令插入一个文件，并使a w k程序可执行，然后用a w k命令作为脚本的首行，以便通过键入脚本名称来调用它。
第三种方式是将所有的a w k命令插入一个单独文件，然后调用：
awk –f awk-script-file input-files
 
awk脚本
模式和动作
在命令中调用a w k时，a w k脚本由各种操作和模式组成。模式包括两个特殊字段B E G I N和E N D。
使用B E G I N语句设置计数和打印头。B E G I N语句使用在任何文本浏览动作之前。E N D语句用来在a w k完成文本浏览动作后打印输出文本总数和结尾状态标志。
实际动作在大括号{ }内指明。
 
域和记录
$ 0，意即所有域
 
• 确保整个a w k命令用单引号括起来。
• 确保命令内所有引号成对出现。
• 确保用花括号括起动作语句，用圆括号括起条件语句。
 
awk中的正则表达式
+ 使用+匹配一个或多个字符。
？ 匹配模式出现频率。例如使用/X Y?Z/匹配X Y Z或Y Z。
 
awk '{if($4~/Brown/) print $0}' tab2
等效于
awk '$0 ~ /Brown/' tab2
 
内置变量
awk '{print NF,NR,$0}END{print FILENAME}' tab1
NF 域的总数
NR已经读取的记录数
FILENAME
 
awk '{if(NR>0 && $2~/JLNQ/) print $0}END{print FILENAME}' tab1
 
显示文件名
echo "/app/oracle/ora_dmp/lisx/tab1" | awk -F/ '{print $NF}'
 
定义域名
awk '{owner=$2;number=$3;if(owner~/SYSADMIN/ && number!=12101)print $0}END{print FILENAME}' tab1
 
awk 'BEGIN{NUM1=7}{if($1<=NUM1) print $0}END{print FILENAME}' tab1
 
当在a w k中修改任何域时，重要的一点是要记住实际输入文件是不可修改的，修改的只是保存在缓存里的a w k复本
awk 'BEGIN{NUM1=7}{if($1<=NUM1) print $1+2,$2,$3+100}END{print FILENAME}' tab1
 
只打印修改部分：用{}
awk 'BEGIN{NUM1=7}{if($1<=NUM1){$2="ORACLE"; print $0}}END{print "filename:"FILENAME}' tab1
 
 可以创建新的域
awk 'BEGIN{NUM1=7;print "COL1"tCOL2"tCOL3"tCOL4"}{if($1<=NUM1){$4=$1*$3;$2="ORACLE"; print $0}}END{print "filename:"FILENAME}' tab1
 
打印总数：
awk 'BEGIN{NUM1=7;print "COL1"tCOL2"tCOL3"tCOL4"}{if($1<=NUM1){tot+=$3;$4=$1*$3;$2="ORACLE"; print $0}}END{print "filename:"FILENAME "total col3:" tot}' tab1
 
使用此模式打印文件名及其长度，然后将各长度相加放入变量t o t中。
ls -l | awk '/^[^d]/ {print$9""t"$5} {tot+=$5}END{print "total KB:" tot}'
 
内置字符串函数
gsub 字符要用引号，数字不用
awk 'gsub(/12101/,"hello") {print $0} END{print FILENAME}' tab1
awk 'gsub(/12101/,3333) {print $0} END{print FILENAME}' tab1
 
index
awk '{print index($2,"D")""t";print $0}' tab1
awk '{print index($2,"D")""t" $0}' tab1
 
length
awk '{print length($2)""t" $0}' tab1
 
ma
awk '{print match($2,"M")""t" $0}' tab1
 
split
awk '{print split($2,new_array,"_")""t" $0}' tab1
 
sub 替换成功返回1,失败返回0
awk '{print sub(/SYS/,"oracle",$2)""t" $0}' tab1
 
substr
awk '{print substr($2,1,3)""t" $0}' tab1
 
从s h e l l中向a w k传入字符串
echo "Stand-by" | awk '{print length($0)""t"$0}'
8                                 Stand-by
 
file1="tab1"
cat $file1 | awk '{print sub(/ADMIN/,"sss",$2)""t"$0}'
 
字符串屏蔽序列
" b 退格键      " t t a b键
" f 走纸换页    " d d d 八进制值
" n 新行         " c 任意其他特殊字符，例如" "为反斜线符号
" r 回车键
 
awk printf修饰符
- 左对齐
Wi d t h 域的步长，用0表示0步长
. p r e c 最大字符串长度，或小数点右边的位数
 
如果用格式修饰输出，要指明具体的域，程序不会自动去分辨
awk '{printf "%-2d %-10s %d"n", $1,$2,$3}' tab1
输出结果
9 SYSADMIN   12101
9 SYSADMIN   12101
14 SYSADMIN   121010000012002
9 SYSADMIN   12101
2 JLNQ       12101
2 JLNQ       12101
7 SYSADMIN   12101
7 SYSADMIN   12101
6 ac_ds_e_rr_mr 13333
 
向一行a w k命令传值
awk 'BEGIN{SYS="SYSADMIN"}{if($2==SYS) printf "%-2d %-10s %d"n", $1,$2,$3}' tab1
在动作后面传入
awk '{if($2==SYS) printf "%-2d %-10s %d"n", $1,$2,$3}' SYS="SYSADMIN" tab1
 
awk脚本文件
 
 
SED用法
sed怎样读取数据
s e d从文件的一个文本行或从标准输入的几种格式中读取数据，将之拷贝到一个编辑缓冲区，然后读命令行或脚本的第一条命令，并使用这些命令查找模式或定位行号编辑它。重复此过程直到命令结束。
 
调用s e d有三种方式
使用s e d命令行格式为：
sed [选项]  s e d命令   输入文件。
记住在命令行使用s e d命令时，实际命令要加单引号。s e d也允许加双引号。
使用s e d脚本文件，格式为：
sed [选项] -f    sed脚本文件   输入文件
要使用第一行具有s e d命令解释器的s e d脚本文件，其格式为：
s e d脚本文件 [选项]   输入文件
使用s e d在文件中定位文本的方式
x             x为一行号，如1
x , y         表示行号范围从x到y，如2，5表示从第2行到第5行
/ p a t t e r n / 查询包含模式的行。例如/ d i s k /或/[a-z]/
/ p a t t e r n / p a t t e r n / 查询包含两个模式的行。例如/ d i s k / d i s k s /
p a t t e r n / , x 在给定行号上查询包含模式的行。如/ r i b b o n / , 3
x , / p a t t e r n / 通过行号和模式查询匹配行。3 , / v d u /
x , y ! 查询不包含指定行号x和y的行。1 , 2 !
 
sed编辑命令
p  打印匹配行
=  显示文件行号
a"  在定位行号后附加新文本信息
i"  在定位行号后插入新文本信息
d  删除定位行
c"  用新文本替换定位文本
s 使用替换模式替换相应模式
r 从另一个文件中读文本
w 写文本到一个文件
q 第一个模式匹配完成后推出或立即推出
l 显示与八进制A S C I I代码等价的控制字符
{ } 在定位行执行的命令组
n 从另一个文件中读文本下一行，并附加在下一行
g 将模式2粘贴到/pattern n/
y 传送字符
n 延续到下一输入行；允许跨行的模式匹配语句
 
sed编程举例
打印单行     sed -n '2p' quo*
打印范围    sed -n '1,3p' quote.txt
打印有此模式的行    sed -n '/disco/'p quote.txt
使用模式和行号进行查询  sed -n '4,/The/'p quote.txt  
sed -n '1,/The/'p quote.txt 会打印所有记录？
用.*代表任意字符   sed -n '/.*ing/'p quote.txt
打印行号 sed -e '/music/'= quote.txt 或sed -e '/music/=' quote.txt
如果只打印行号及匹配行，必须使用两个s e d命令，并使用e选项。
第一个命令打印模式
匹配行，第二个使用=选项打印行号，格式为sed -n -e /pattern/p -e /pattern/=。
sed -n -e '/music/p' -e '/music/'= quote.txt
 
先打印行号，再打印匹配行
sed -n -e '/music/=' -e '/music/'p quote.txt
 
替换
sed 's/The/Wow!/' quote.txt
 
保存到文件
sed '1,2 w filedt' quote.txt
 
读取文件，在第一行后面读取
sed '1 r sedex.txt' quote.txt
 
替换字符系列
如果变量x含有下列字符串：
x="Department+payroll%Building G"
要实现以下转换：
+ to 'of'  
% to located
语句： echo $x | sed 's/"+/ of /g' | sed 's/"%/ located /g'