

grep -o 按照正则表达式只打印匹配的数据

ss -pln|grep 44663|awk '{print $5}'|grep -o '[0-9]*'