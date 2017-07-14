#192.168.0.179
cd /data
tar czvf elk-data-20170104.tar.gzip elasticsearch/
scp ./elk-data-20170104.tar.gzip 192.168.0.191:/data
mkdir data/elasticsearch/config/scripts
#上传文件log4j2.properties和elasticsearch.yml
