#!/bin/bash

# 安装paasos-monitor
# wangxinxiang@yihecloud.com
# 2016-08-26

OPTS=$(getopt -o h:P:u:p: --long mail_host:,mail_user:,mail_pswd:,registry:,version:,name:,port:,redis_host:: -- "$@")
if [ $? != 0 ]; then
  echo "[ERROR] 参数错误！"
  usage;
  exit 1
fi

eval set -- "$OPTS"

registry="docker.dev.yihecloud.com"
version="3.0"
name="monitor"
port="8080"
db_port="3306"

db_host=
db_user=
db_pswd=
mail_host=
mail_user=
mail_pswd=


while true; do
  case "$1" in
  -h) db_host=$2; shift 2;;
  -P) db_port=$2; shift 2;;
  -u) db_user=$2; shift 2;;
  -p) db_pswd=$2; shift 2;;
  --mail_host) mail_host=$2; shift 2;;
  --mail_user) mail_user=$2; shift 2;;
  --mail_pswd) mail_pswd=$2; shift 2;;
  --registry) registry=$2; shift 2;;
  --version) version=$2; shift 2;;
  --name) name=$2; shift 2;;
  --port) port=$2; shift 2;;
  --) shift; break;;
  esac
done

function check_opt() {
  arg="\$$1"
  if [ "$(eval echo $arg)"  = "" ]; then
    echo "[ERROR] <$1> 参数缺失！"
    usage;
    exit 1
  fi
}

function usage() {
	echo "
Usage: $0 
  -h <db_host> 
  -P <db port>, default: 3306
  -u <db_user> 
  -p <db_pswd> 
  --registry <docker registry>, default: docker.dev.yihecloud.com
"
}

# check options
check_opt "registry"
check_opt "db_host"
check_opt "db_user"
check_opt "db_port"
check_opt "db_pswd"

# run docker image
docker run -d --name $name \
    --restart=always \
    -e DB_HOST=$db_host \
    -e DB_PORT=$db_port \
    -e DB_USER=$db_user \
    -e DB_PSWD=$db_pswd \
    -e REDIS_HOST=192.168.0.174 \
    -e MAIL_HOST=$mail_host \
    -e MAIL_NAME=$mail_name \
    -e MAIL_PSWD=$mail_pswd \
    -e PREFIX=$name \
    -p $port:8080 \
    $registry/paasos/monitor:$version

# show status
docker ps |grep "monitor"