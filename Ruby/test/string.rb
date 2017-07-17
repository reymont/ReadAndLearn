" now's  the time".split        #=> ["now's", "the", "time"]
" now's  the time".split(' ')   #=> ["now's", "the", "time"]
" now's  the time".split(/ /)   #=> ["", "now's", "", "the", "time"]
"1, 2.34,56, 7".split(%r{,\s*}) #=> ["1", "2.34", "56", "7"]
"hello".split(//)               #=> ["h", "e", "l", "l", "o"]
"hello".split(//, 3)            #=> ["h", "e", "llo"]
"hi mom".split(%r{\s*})         #=> ["h", "i", "m", "o", "m"]

puts "mellow yellow".split("ello")   #=> ["m", "w y", "w"]
"1,2,,3,4,,".split(',')         #=> ["1", "2", "", "3", "4"]
"1,2,,3,4,,".split(',', 4)      #=> ["1", "2", "", "3,4,,"]
"1,2,,3,4,,".split(',', -4)     #=> ["1", "2", "", "3", "4", "", ""]

"".split(',', -1)               #=> []

puts "mellow yellow".split("ello").length
puts "mellow yellow".split("ello")["mellow yellow".split("ello").length-1]

str = "/data/html/www/cloud/webjars/springfox-swagger-ui/lib/backbone-min.js"
puts str.split(".")[str.split(".").length-1]

str = "14/Jul/2017:20:00:11 +0800§|§nginx§|§192.168.31.149§|§65011§|§-§|§'https§|§GET§|§/cloud/api/v1/accounts/cuser§|§/cloud/api/v1/accounts/cuser§|§/data/html/www/cloud/api/v1/accounts/cuser§|§-§|§[Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/59.0.3071.104 Safari/537.36]§|§http://localhost:8888/devops/dashboard§|§-§|§-§|§-§|§388§|§-§|§200§|§192.168.31.210§|§console.cloudos.yihecloud.com§|§443§|§HTTP/1.1§|§0.003§|§0.003§|§192.168.31.149§|§192.168.31.214:18080"
puts str.split("§|§")
