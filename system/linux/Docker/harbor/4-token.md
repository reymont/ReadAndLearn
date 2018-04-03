
# https://github.com/vmware/harbor/wiki/Harbor-FAQs

API

1> how to access Harbor API. [A] First you need to get a token curl -i -k -u admin:Harbor12345 https://10.192.212.107/service/token?account=admin\&service=harbor-registry\&scope=repository:library/mysql/5.6.35:pull,push

possible stop include pull,*, push

Then you can use token to issue registry API( You can refer the registry official document for the api list)

curl -k -v -H "Content-Type: application/json" -H "Authorization: Bearer longlongtokenxxxxx" -X GET https://10.192.212.107/v2/library/mysql/5.6.35/manifests/latest