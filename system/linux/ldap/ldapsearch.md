


* [openldap---ldapsearch使用 - ssl vpn ------adito (ssl explorer) (openvpn als)&amp;amp;amp;&amp;amp;amp;网络安全 - CSDN博客 ](http://blog.csdn.net/xubo578/article/details/5097321)
* [LDAP常用命令解析-zhiming.yk-ChinaUnix博客 ](http://blog.chinaunix.net/uid-20690190-id-4085176.html)
* [ldapsearch 的用法 - 考拉先生 - 51CTO技术博客 ](http://koala003.blog.51cto.com/9996246/1663662)
* [ldapsearch(1): LDAP search tool - Linux man page ](https://linux.die.net/man/1/ldapsearch)


# ldapsearch 参数表 
下表描述可以用于 ldapsearch 的区分大小写的参数。

<table border="1">
<tbody>
<tr valign="top">
<td><strong><span style="font-size: x-small;">参数</span>
</strong>
</td>
<td><strong><span style="font-size: x-small;">用途</span>
</strong>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;"> -?</span>
</td>
<td><span style="font-size: x-small;">打印关于使用 ldapsearch 的帮助。 </span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-a deref</span>
</td>
<td><span style="font-size: x-small;">指定别名反向引用。请输入 never、always、search 或 find。如果不使用此参数，缺省为 never。 </span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-A</span>
</td>
<td><span style="font-size: x-small;">只检索属性的名称，而不检索属性的值。 </span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-b base dn</span>
</td>
<td><span style="font-size: x-small;">指定用作搜索起始点的专有名称。使用引号来指定该值，例如："ou=West,o=Acme,c=US"</span>
<p><span style="font-size: x-small;">如果要搜索的服务器需要指定搜索起点，则必须使用此参数。否则此参数是可选的。 </span>
</p>
<p><span style="font-size: x-small;">也可以同时使用 -b 和 -s 来确定搜索范围。没有 –s，-b 就会搜索指定为起始点的项以及该项的所有子项。</span>
</p>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-B</span>
</td>
<td><span style="font-size: x-small;">允许打印非 ASCII 值</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-D bind dn</span>
</td>
<td><span style="font-size: x-small;">指定服务器用于验证您的专有名称。名称必须与目录中的项相符，并且必须拥有搜索目录所需的权限。</span>
<p><span style="font-size: x-small;">请使用引号来指定该名称，例如："cn=Directory Manager,o=Acme,c=US"</span>
</p>
<p><span style="font-size: x-small;">如果不使用此参数，则与服务器的连接是匿名的。如果服务器不允许匿名连接，则必须使用 -D。</span>
</p>
<p><span style="font-size: x-small;">除了 -D，还必须使用 -w 参数来指定与专有名称相关联的口令。</span>
</p>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-f file</span>
</td>
<td><span style="font-size: x-small;">指定包含要使用的搜索过滤器的文件，如 -f 过滤器。请将每个搜索过滤器置于单独的一行。Ldapsearch 会对每一行执行一次搜索。可选择指定过滤模式。例如，指定 -f 过滤 "cn=%s"，并在文件的每一行中输入公用名称的值。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-F sep</span>
</td>
<td><span style="font-size: x-small;">在属性名称和值之间打印 sep 而不是等号 (=)。例如，如果读取 ldapsearch 输出的工具希望使用其他的分隔符时，可以使用此参数。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-h host name</span>
</td>
<td><span style="font-size: x-small;">指定要连接的服务器主机名，如 -h server.acme.com。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-l timelimit</span>
</td>
<td><span style="font-size: x-small;">指定完成搜索的时间限制（秒）。如果没有指定此参数或指定的限制为 0，那么搜索就没有时间限制。但是，ldapsearch 的等待时间决不会超过服务器上设置的搜索时间限制。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-L</span>
</td>
<td><span style="font-size: x-small;">指定以 LDIF 格式输出。LDIF 格式使用冒号 (:) 而不是等号 (=) 作为属性描述符。LDIF 对一次性添加或修改大量目录项很有帮助。例如，可以将输出内容引入兼容 LDAP 的目录中。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-M</span>
</td>
<td><span style="font-size: x-small;">将参考对象作为普通项进行管理，以使 ldapsearch 可返回参考项本身的属性，而不是所参考的项的属性。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-n</span>
</td>
<td><span style="font-size: x-small;">显示如何执行搜索，但不实际执行搜索 </span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-p port</span>
</td>
<td><span style="font-size: x-small;">指定服务器使用的端口。如果没有使用此参数，缺省情况下 ldapsearch 使用 389 端口。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-R</span>
</td>
<td><span style="font-size: x-small;">不自动遵循服务器返回的搜索引用。请注意，Netscape 目录服务器将术语 referrals 用于搜索引用。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-s scope</span>
</td>
<td><span style="font-size: x-small;">指定使用 -b 参数时的搜索范围：</span>

<ul>
<li><span style="font-size: x-small;">base -- 仅搜索 -b 参数指定的项</span>
</li>
<li><span style="font-size: x-small;">onelevel -- 仅搜索 -b 参数指定项的直接子项，而不搜索该项本身</span>
</li>
<li><span style="font-size: x-small;">subtree -- 搜索 -b 参数指定的项以及它的所有子项。这是不带 -s 时使用 -b 的缺省行为。</span>
</li>
</ul>
<span style="font-size: x-small;">指定 -b 和 -s 的顺序并不重要。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-S attribute</span>
</td>
<td><span style="font-size: x-small;">按指定的属性排序结果。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-z sizelimit</span>
</td>
<td><span style="font-size: x-small;">指定返回项的最大数目。如果没有指定此参数或指定的限制为 0，那么返回的项没有数量限制。但是，ldapsearch 返回的项决不会多于服务器允许的数量。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-u</span>
</td>
<td><span style="font-size: x-small;">指定 ldapsearch 以用户友好格式返回专有名称。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-v</span>
</td>
<td><span style="font-size: x-small;">指定 ldapsearch 以详尽模式运行。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">-w password</span>
</td>
<td><span style="font-size: x-small;">指定与 -D 参数一起使用的与专有名称关联的口令。</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">x</span>
</td>
<td><span style="font-size: x-small;">与 -S 一起使用时可指定 LDAP 服务器在将结果返回之前就对它们进行排序。如果使用 -S 而不使用 –x，ldapsearch 将对结果排序。</span>
</td>
</tr>
</tbody>
</table>



# 运算符

|运算符	用途|	样例|
|-|-|
|=	|查找所包含的属性值与指定值相同的项	"cn=JohnBrowning"|
|=\<string\>*\<string\>|	查找所包含的属性值与指定的子字符串相同的项	"cn=John*" \"cn\|=J*Brown\"|
|>=	|查找特定项，该项中包含的属性的数字或字母值大于或等于指定的值。	"cn>=D"|
|<=	|查找特定项，该项中包含的属性的数字或字母值小于或等于指定的值。	"roomNumber<=300"|
|=*	|查找包含特定属性的值的项，而不用管属性的值是什么。	"sn=*"|
|~=	|查找特定项，该项中所含属性的值约等于指定的值。	"sn~=Brning"可能返回sn=Browning|
|&	|查找与所有搜索过滤器中指定的条件相匹配的项	"(&(cn=JohnBrowning)(l=Dallas))"|
|\|	|查找与至少一个搜索过滤器中指定的条件相匹配的项	"(|(cn=JohnBrowning)(l=Dallas))"|
|!	|查找与任何搜索过滤器中指定的条件都不匹配的项	"(!(cn=JohnBrowning)(l=Dallas))"|

## 搜索过滤器的语法

必须使用搜索过滤器指定要搜索的属性。搜索过滤器的语法为：

"\<attribute\> \<operator\> \<value\>"

例如，下面的搜索过滤器可以找到所有的特定项，只要该项中以 Smith 作为 sn（别称）属性的值：

"sn=Smith"

可以在搜索过滤器中指定存储在目录中的任意属性。以下是用来搜索个人项的公用属性：
cn -- 个人的公用名称
sn -- 个人的姓
telephonenumber -- 个人的电话号码
l -- 个人的地理位置

可以在 ldapsearch 命令行中指定搜索过滤器，或在文件中指定它们，并使用 lsearch 参数 -f 引用此文件。如果使用文件，请在单独的行中指定每个搜索过滤器。
请注意：如果 LDAP 目录（如 Domino LDAP 目录）支持语言标记，则可在搜索过滤器中包含它们。例如：

"givenName;lang-fr=Etienne"

## 使用布尔运算符的多个搜索过滤器
您可以使用多个搜索过滤器以及布尔运算符。使用下列语法：
"(operator(filter)(filter))"

例如，使用下面的搜索过滤器查找别称为 Browning、位置为 Dallas 的项。
"(&(sn=Browning)(l=Dallas))"

## 嵌套布尔运算符

布尔运算符可以嵌套。例如，使用下面的搜索过滤器在邮件网络域 MDN 中查找 surname 为 caneel 或 givenname 为 alfred 的项：

"(&(maildomain=MDN)(|(sn=caneel)(givenname=alfred)))"


# 使用 ldapsearch 的样例 
下表提供使用 ldapsearch 实用程序的样例。

<table border="1">
<tbody>
<tr valign="top">
<td><strong><span style="font-size: x-small;">搜索</span>
</strong>
</td>
<td><strong><span style="font-size: x-small;">命令</span>
</strong>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com 上的所有项，并返回所有属性和值</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -h ldap.acme.com "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">同上，但仅返回属性名称</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -A -h ldap.acme.com" objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com 上的所有项，并且反向引用找到的所有别名</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -a always -h ldap.acme.com "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com 上的所有项，并返回 mail、cn、sn 和 givenname 等属性</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -h ldap.acme.com "objectClass=*" mail cn sn givenname</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">在使用端口 389 的主机 ldap.acme.com 上，在 ”ou=West，o=Acme，c=US” 基准下搜索 (cn=Mike*)，并返回所有属性和值</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -b "ou=West,o=Acme,c=US" -h ldap.acme.com "(cn=Mike*)"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com 上的一个级别，并返回所有属性和值</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -s onelevel -h ldap.acme.com "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">同上，但限制基准的范围</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -s base -h ldap.acme.com "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com 上的所有项，并返回所有的属性和值；搜索时间限制为五秒</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -l 5 -h ldap.acme.com "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com 上的所有项，并返回所有的属性和值；大小限制为五</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -z 5 -h ldap.acme.com "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com 上的所有项，捆绑为：用户“cn=John Doe,o=Acme”，口令“password”，并以 LDIF 格式返回所有的属性和值</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -h ldap.acme.com -D "cn=john doe,o=acme" -w password -L "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">使用端口 389 的主机 ldap.acme.com。对“cn=John Doe,o=Acme”项，返回其允许匿名查看的所有属性</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -h ldap.acme.com" -s base -b "cn=john doe,o=acme" objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">配置为在端口 391 上侦听 LDAP 请求的另一台主机 bluepages.ibm.com 上的所有项</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -h bluepages.ibm.com -p 391 "objectClass=*"</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">端口 391 上的
bluepages.ibm.com。对还有与 OR
过滤器中任意一个属性相匹配的属性的任何“个人”对象类型进行子树搜索（缺省），从组织“o=ibm”开始。超时值为 300 秒，返回的最大项数设为
1000。且仅返回 DN（缺省）和 CN（这是 Web 应用程序的公用过滤器）。</span>
</td>
<td><span style="font-size: x-small;">ldapsearch
-h bluepages.ibm.com -p 391 -b "o=ibm" -l 300 -z 1000
"(&amp;(objectclass=Person)(|(cn=jerry seinfeld*)(givenname=jerry
seinfeld*)(sn=jerry seinfeld*)(mail=jerry seinfeld*)))" cn</span>
</td>
</tr>
<tr valign="top">
<td><span style="font-size: x-small;">端口 391 上的 bluepages.ibm.com。以基准项“cn=HR Group,ou=Asia,o=IBM”为起始，时间限制为 300 秒，查询此项的所有成员。（Web 应用程序中用以确定群组成员的另一个公用过滤器）。</span>
</td>
<td><span style="font-size: x-small;">ldapsearch -h bluepages.ibm.com -p 391 -b "cn=HR Group,ou=Asia,o=IBM" -s base -l 300 "(objectclass=*)" member</span>
</td>
</tr>
</tbody>
</table>