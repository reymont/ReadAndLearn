#!/bin/bash

# 安装openbridge-falcon
# wangxinxiang <408200339@qq.com>
# 2016-10-13

OPTS=$(getopt -o h:P:u:p: --long registry:,data_dir:,version:,proxy:: -- "$@")
if [ $? != 0 ]; then
  echo "[ERROR] 参数错误！"
  usage;
  exit 1
fi

eval set -- "$OPTS"

registry="docker.dev.yihecloud.com"
version="1.0"
db_port="3306"
data_dir="/data"

db_host=
db_user=
db_pswd=
proxy=

while true; do
  case "$1" in
  -h) db_host=$2; shift 2;;
  -P) db_port=$2; shift 2;;
  -u) db_user=$2; shift 2;;
  -p) db_pswd=$2; shift 2;;
  --registry) registry=$2; shift 2;;
  --data_dir) data_dir=$2;   shift 2;;
  --version)  version=$2;   shift 2;;
  --proxy)    proxy=$2;   shift 2;;
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
  -h *<db_host> 
  -P <db port>, default: 3306
  -u *<db_user> 
  -p *<db_pswd> 
  --proxy *<paasos nginx address>, eg: https://demo.yihecloud.com 
  --registry <docker registry>, default: $registry
  --data_dir <graph data directory>, default: $data_dir
  --version default: $version
"
}

# check options
check_opt "registry"
check_opt "db_host"
check_opt "db_user"
check_opt "db_port"
check_opt "db_pswd"
check_opt "proxy"
check_opt "version"

function deploy() {
  docker pull $registry/openbridge/$1:$2
  docker rm -f $1

  docker run -dti --restart=always --net=host --name=$1 \
    -e DB_HOST=$db_host -e DB_USER=$db_user -e DB_PSWD=$db_pswd \
    -e MONITOR_URI=$proxy \
    -v $data_dir/$1:/data \
    $registry/openbridge/$1:$2
}

apps="graph query transfer judge alarm hbs sender"
function deploy_all() {
  deploy redis 3.0
  for x in alarm hbs; do
    deploy falcon-$x $version
  done
}

#deploy_all
#deploy falcon-alarm 1.0
deploy falcon-hbs 1.0
#deploy falcon-graph 1.1
#deploy falcon-judge 1.1
#deploy falcon-sender 1.0