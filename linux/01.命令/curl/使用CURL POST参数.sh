

使用CURL POST参数 - CSDN博客 http://blog.csdn.net/fabbychips/article/details/69808619


# Start your cURL command with curl -X POST and then add -F for every field=value you want to add to the POST:
curl -X POST -F 'username=davidwalsh' -F 'password=something' http://domain.tld/post-to-me.php

# If you need to send a specific data type or header with cURL, use -H to add a header:
# -d to send raw data
curl -X POST -H 'Content-Type: application/json' -d '{"username":"davidwalsh","password":"something"}'\
 http://domain.tld/login

# POSTing Files with cURL
# POSTing a file with cURL is slightly different in that you need to add an @ 
# before the file location, after the field name:
curl -X POST -F 'image=@/path/to/pictures/picture.jpg' http://domain.tld/upload

curl -XPOST -H’Content-Type: application/json’ localhost:9200/family_person?pretty -d@data.json