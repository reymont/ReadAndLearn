

* [ansible小结（十 二）磁盘使用率筛选 - 运维之路 ](http://www.361way.com/ansible-diskinfo/4995.html)

```sh
df -hP|awk 'NR>1 && $5 > 20'

# ansible all -m shell -a "df -hP|awk 'NR>1 && int($5) > 50'"
ansible all -m shell -a "df -hP|awk 'NR>1 && int(\$5) > 30'"|awk '/success/{ip=$1;next}{print ip,$0}'
```