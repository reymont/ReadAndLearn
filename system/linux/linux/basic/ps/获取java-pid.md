

ps aux | grep 7000.conf | grep -v grep | awk '{print $2}'

ps -e -o pid,comm

ps -e -o pid,args|grep ec-order|grep -v grep