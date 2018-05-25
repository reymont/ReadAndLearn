


tcpdump -x -i ens33 port 8080 -w jenkins-cli.pkt

java -jar jenkins-cli.jar -s http://@10.31.1.236:8080/ delete-builds job-name 1-1230