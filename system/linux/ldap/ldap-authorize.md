





## 8.2. Access Control via Static Configuration

* [OpenLDAP Software 2.4 Administrator's Guide: Access Control ](http://www.openldap.org/doc/admin24/access-control.html)

```conf
    <access directive> ::= access to <what>
        [by <who> [<access>] [<control>] ]+
    <what> ::= * |
        [dn[.<basic-style>]=<regex> | dn.<scope-style>=<DN>]
        [filter=<ldapfilter>] [attrs=<attrlist>]
    <basic-style> ::= regex | exact
    <scope-style> ::= base | one | subtree | children
    <attrlist> ::= <attr> [val[.<basic-style>]=<regex>] | <attr> , <attrlist>
    <attr> ::= <attrname> | entry | children
    <who> ::= * | [anonymous | users | self
            | dn[.<basic-style>]=<regex> | dn.<scope-style>=<DN>]
        [dnattr=<attrname>]
        [group[/<objectclass>[/<attrname>][.<basic-style>]]=<regex>]
        [peername[.<basic-style>]=<regex>]
        [sockname[.<basic-style>]=<regex>]
        [domain[.<basic-style>]=<regex>]
        [sockurl[.<basic-style>]=<regex>]
        [set=<setspec>]
        [aci=<attrname>]
    <access> ::= [self]{<level>|<priv>}
    <level> ::= none | disclose | auth | compare | search | read | write | manage
    <priv> ::= {=|+|-}{m|w|r|s|c|x|d|0}+
    <control> ::= [stop | continue | break]
```

## 2.4	配置匿名禁读和全局只读用户

* [Openldap服务器日志及权限配置 - 达摩子 - 博客园 ](http://www.cnblogs.com/donneyliu/p/Centos-Openldap-Server-Log-Anon-OlcAccess.html)

```conf
vim olcAccess.ldif

dn: cn=config
changetype: modify
replace: olcDisallows
olcDisallows: bind_anon
-

dn: olcDatabase={-1}frontend,cn=config
changetype: modify
replace: olcRequires
olcRequires: authc
-

dn: olcDatabase={2}bdb,cn=config
changetype: modify
replace: olcAccess
olcAccess: {0}to * by dn="cn=Manager,dc=dcnet,dc=com" write by dn="cn=info,cn=Manager,dc=dcnet,dc=com" read by * auth
```