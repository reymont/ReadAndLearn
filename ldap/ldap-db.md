
* [OpenLDAP2.4管理员指南 - Jabber/XMPP中文翻译计划 ](http://wiki.jabbercn.org/index.php/OpenLDAP2.4%E7%AE%A1%E7%90%86%E5%91%98%E6%8C%87%E5%8D%97#BDB.E5.92.8CHDB.E6.95.B0.E6.8D.AE.E5.BA.93.E6.8C.87.E4.BB.A4)
* [OpenLDAP Software 2.4 Administrator's Guide: Configuring slapd ](http://www.openldap.org/doc/admin24/slapdconf2.html)

# BDB和HDB数据库指令

5.2.4.1. olcBackend: \<type\>

This directive names a backend-specific configuration entry. \<type\> should be one of the supported backend types listed in Table 5.2.

Table 5.2: Database Backends
Types	Description
bdb	Berkeley DB transactional backend (deprecated)
config	Slapd configuration backend
dnssrv	DNS SRV backend
hdb	Hierarchical variant of bdb backend (deprecated)
ldap	Lightweight Directory Access Protocol (Proxy) backend
ldif	Lightweight Data Interchange Format backend
mdb	Memory-Mapped DB backend
meta	Meta Directory backend
monitor	Monitor backend
passwd	Provides read-only access to passwd(5)
perl	Perl Programmable backend
shell	Shell (extern program) backend
sql	SQL Programmable backend
