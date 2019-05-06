

Linux下paste命令详解 - CSDN博客 https://blog.csdn.net/andy572633/article/details/7214126

paste单词意思是粘贴。该命令主要用来将多个文件的内容合并，与cut命令完成的功能刚好相反。

粘贴两个不同来源的数据时，首先需将其分类，并确保两个文件行数相同。paste将按行将不同文件行信息放在一行。缺省情况下， paste连接时，用空格或tab键分隔新行中不同文本，除非指定-d选项，它将成为域分隔符。
paste格式为:
paste -d -s -file1 file2
选项含义如下：
-d 指定不同于空格或tab键的域分隔符。例如用@分隔域，使用- d @。
-s 将每个文件合并成行而不是按行粘贴。
- 使用标准输入。例如ls -l |paste ，意即只在一列上显示输出。（这个参数的解释是网上找来的，但从后面的例子来看，应该是对输出的列进行设置。）



例子：
文件： pas1
ID897
ID666
ID982
文件： pg pas2
P.Jones
S.Round
L.Clip
基本paste命令将pas1和pas2两文件粘贴成两列：
> paste pas1 pas2
ID897   P.Jones
ID666   S.Round
ID982   L.Clip
通过交换文件名即可指定哪一列先粘：
> paste pas2 pas1
P.Jones ID897
S.Round ID666
L.Clip ID982
要创建不同于空格或tab键的域分隔符，使用-d选项。下面的例子用冒号做域分隔符。
> paste -d: pas2 pas1
P.Jones:ID897
S.Round:ID666
L.Clip:ID982
要合并两行，而不是按行粘贴，可以使用-s选项。下面的例子中，第一行粘贴为ID号，第二行是名字。
> paste -s pas1 pas2
ID897   ID666   ID982
P.Jones S.Round L.Clip
paste命令还有一个很有用的选项（-）。意即对每一个（-），从标准输入中读一次数据。使用空格作域分隔符，以一个6列格式显示目录列表。方法如下：
> ls /etc | paste -d" " - - - - - -
MANPATH PATH SHLIB_PATH SnmpAgent.d/ TIMEZONE X11/
acct/ aliases@ arp@ audeventstab audomon@ auto_master
auto_parms.log auto_parms.log.old backup@ backup.cfg bcheckrc@ bootpd@
bootpquery@ bootptab btmp@ catman@ checklist@ chroot@
clri@ cmcluster/ cmcluster.conf cmom.conf conf@ convertfs@
copyright cron@ csh.login d.cshrc@ d.exrc@ d.login@
也可以以一列格式显示输出：
wangnc> ls /etc | paste -d"" -
MANPATH
PATH
SHLIB_PATH
SnmpAgent.d/
TIMEZONE
X11/
acct/
aliases@
arp@
audeventstab
audomon@
auto_master
auto_parms.log
auto_parms.log.old
backup@
backup.cfg