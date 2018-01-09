#验证配置
/usr/nginx/sbin/nginx -t
#平滑升级
kill -HUP <pid>
/usr/nginx/sbin/nginx -s reload

#请求总数
less /var/log/nginx/access.log | wc -l
#平均每秒的请求数
less /var/log/nginx/access.log | awk '{sec=substr($4,2,20);reqs++;reqsBySec[sec]++;} END{print reqs/length(reqsBySec)}'
head /var/log/nginx/access.log | awk '{sec=substr($4,2,20);reqs++;reqsBySec[sec]++;print sec, reqs, reqsBySec[sec]} END{print reqs/length(reqsBySec)}'
#峰值每秒请求数
less /var/log/nginx/access.log | awk '{sec=substr($4,2,20);requests[sec]++;} END{for(s in requests){printf("%s %s\n", requests[s],s)}}' | sort -nr | head -n 3

#substr(s,p,n)返回字符串s中从p开始长度为n的后缀部分
head /var/log/nginx/access.log| awk '{print substr($4,2,20)}'

#流量速率分析
less /var/log/nginx/access.log | awk '{url=$7; requests[url]++;bytes[url]+=$10} END{for(url in requests){printf("%sMB %sKB/req %s %s\n", bytes[url] / 1024 / 1024, bytes[url] /requests[url] / 1024, requests[url], url)}}' | sort -nr | head -n 15

head -n 20 /var/log/nginx/access.log | awk '{url=$7; requests[url]++;bytes[url]+=$10;print $7, requests[url], $10, bytes[url]}'
head -n 20 /var/log/nginx/access.log | awk '{print $7, $10}'

#某个URL占用的CPU时间
less /var/log/nginx/access.log | awk '{url=$7; times[url]++} END{for(url in times){printf("%s %s\n", times[url], url)}}' | sort -nr | more

#慢查询
less /var/log/nginx/access.log | awk -v limit=2 '{min=substr($4,2,17);reqs[min] ++;if($11>limit){slowReqs[min]++}} END{for(m in slowReqs){printf("%s  %s %s%s %s\n", m, slowReqs[m]/reqs[m] * 100, "%", slowReqs[m], reqs [m])}}' | more

less /var/log/nginx/access.log | awk -v limit=0.2 '{sec=substr($4,2,20);reqs[sec] ++;if($11>limit){slowReqs[sec]++}} END{for(m in slowReqs){printf("%s  %s %s%s %s\n", m, slowReqs[m]/reqs[m] * 100, "%", slowReqs[m], reqs [m])}}' | more
tail -n 20 /var/log/nginx/access.log | awk '{print $7, $11}'

#爬虫
less /var/log/nginx/access.log | egrep 'spider|bot' | awk '{name=$17;if(index ($15,"spider")>0){name=$15};spiders[name]++} END{for(name in spiders) {printf("%s %s\n",spiders[name], name)}}' | sort -nr







