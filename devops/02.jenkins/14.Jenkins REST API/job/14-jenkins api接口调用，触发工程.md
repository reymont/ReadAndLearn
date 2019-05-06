https://blog.csdn.net/huodoubi/article/details/54345293

jenkins常常用于统一调度，针对linux下的jenkins，curl调用api来驱动jenkins工程，使用shell脚本实现（对jenkins的安装，配置，及项目配置不再详述）



1、没有参数的jenkins工程

#! /bin/sh
#无参构建jenkins任务
if [ $# -ne 1 ];then
    echo "Usage:build_without_param.sh <jobName>"
    exit 1
fi
curl -X POST http://ip:port/jenkins/job/$1/build --user username:password



2、有参数的jenkins工程

#! /bin/sh
#含参构建jenkinse任务，设置多个参数
if [ $# -lt 2 ];then
        echo "Usage:build_with_params.sh <jobName> <param_1_name=param_1_value> <param_2_name=param_2_value&> <...>"
        exit 1
fi
#获得jenkins任务的所有参数，并拼接成params
params=$2
for((i=$#;i>2;i--))
    do
        params="$params""&""${!i}"
    done
echo "jenkins job<$1> build with params:<$params>"
curl -X POST "http://ip:port/jenkins/job/$1/buildWithParameters?$params" --user username:password



ip、port、username、password参数，依据jenkins不同配置，灵活配置