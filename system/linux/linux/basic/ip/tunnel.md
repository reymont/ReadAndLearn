

A:
ip tunnel add a2b mode ipip remote 10.1.171.124 local 10.1.171.123
ifconfig a2b 192.168.32.1 netmask 255.255.255.0

B:
ip tunnel add a2b mode ipip remote 10.1.171.123 local 10.1.171.124
ifconfig a2b 192.168.32.2 netmask 255.255.255.0