
#查询值
ldapsearch -x -D "cn=Manager,dc=openbridge,dc=cn" \
 -W -h 127.0.0.1 -b "dc=openbridge,dc=cn"
cat cn\=config.ldif
ldapsearch -x -D "cn=config"  -W -h 127.0.0.1 -b "dc=openbridge,dc=cn"
123456
#注意：-b后面是两个单引号，用来阻止特殊字符被Shell解析。
ldapsearch -x -b '' -s base '(objectclass=*)'  

ldapsearch -x -D "cn=zhangjinhui,ou=People,dc=openbridge,dc=cn" \
 -W -h 127.0.0.1 -b "dc=openbridge,dc=cn"

ldapsearch -w 123456 -h 127.0.0.1 \
  -b "cn=liyang,ou=People,dc=openbridge,dc=cn"\
  -D "cn=liyang,ou=People,dc=openbridge,dc=cn"

# -s base|one|sub
ldapsearch -w 123456 -h 127.0.0.1\
   -b "dc=openbridge,dc=cn"\
   -D "cn=liyang,ou=People,dc=openbridge,dc=cn"\
   -s base

# filter: (objectclass=*)
ldapsearch -w 123456 -h 127.0.0.1\
   -b "dc=openbridge,dc=cn"\
   -D "cn=liyang,ou=People,dc=openbridge,dc=cn"
# objectClass filter
ldapsearch -w 123456 -h 127.0.0.1\
   -b "dc=openbridge,dc=cn" "objectClass=Person"\
   -D "cn=liyang,ou=People,dc=openbridge,dc=cn"
ldapsearch -w 123456 -h 127.0.0.1\
   -b "dc=openbridge,dc=cn" "objectClass=organizationalRole"\
   -D "cn=liyang,ou=People,dc=openbridge,dc=cn"
ldapsearch -w 123456 -h 127.0.0.1\
   -b "dc=openbridge,dc=cn" "cn=liyang"\
   -D "cn=liyang,ou=People,dc=openbridge,dc=cn"

ldapsearch -x -D "ou=People,dc=openbridge,dc=cn"  -W -h 127.0.0.1 -b "dc=openbridge,dc=cn"