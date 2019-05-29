FROM centos:7.6.1810
RUN yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo \
    && yum install -y epel-release \
    && yum install -y redis luajit openresty git \
    && git clone https://github.com/SinaMSRE/ABTestingGateway \
    && /bin/cp -rf /usr/local/openresty/lualib/ngx/* /ABTestingGateway/lib/lua-resty-core/lib/ngx/ \
    && /bin/cp -rf /usr/local/openresty/lualib/resty/* /ABTestingGateway/lib/lua-resty-core/lib/resty/ \
    && yum clean all \
    && rm -rf /var/cache/yum \
    && mkdir /ABTestingGateway/utils/logs
ENTRYPOINT [ "/usr/bin/redis-server", "/ABTestingGateway/utils/conf/redis.conf" ]