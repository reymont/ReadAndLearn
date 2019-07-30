

1. https://github.com/apache/incubator-dubbo
    1. http://dubbo.apache.org/zh-cn/docs/user/quick-start.html
2. https://github.com/dangdangdotcom/dubbox
3. https://github.com/alibaba/dubbo
    1. http://dubbo.apache.org/zh-cn/docs/user/quick-start.html
        1. 路由规则
            1. http://dubbo.apache.org/zh-cn/docs/user/demos/routing-rule.html
            2. http://dubbo.apache.org/zh-cn/docs/user/demos/routing-rule-deprecated.html
        2. 配置规则 http://dubbo.apache.org/zh-cn/docs/user/demos/config-rule.html
            1. 禁用提供者：(通常用于临时踢除某台提供者机器，相似的，禁止消费者访问请使用路由规则) disabled: true
            2. 调整权重：(通常用于容量评估，缺省权重为 200) weight: 200
            3. 调整负载均衡策略：(缺省负载均衡策略为 random) loadbalance: random
            4. 服务降级：(通常用于临时屏蔽某个出错的非关键服务) force: return null
        3. 主机绑定 http://dubbo.apache.org/zh-cn/docs/user/demos/hostname-binding.html
            1. 可以在 /etc/hosts 中加入：机器名 公网 IP，比如：test1 205.182.23.201
            2. 在 dubbo.xml 中加入主机地址的配置：<dubbo:protocol host="205.182.23.201">
            3. 或在 dubbo.properties 中加入主机地址的配置：dubbo.protocol.host=205.182.23.201
        4. 多版本 http://dubbo.apache.org/zh-cn/docs/user/demos/multi-versions.html
            1. 可以按照以下的步骤进行版本迁移：
                1. 在低压力时间段，先升级一半提供者为新版本
                2. 再将所有消费者升级为新版本
                3. 然后将剩下的一半提供者升级为新版本
    2. http://dubbo.apache.org/zh-cn/docs/dev/build.html
    3. http://dubbo.apache.org/zh-cn/docs/admin/install/provider-demo.html
4. 视频 https://www.bilibili.com/video/av47009143/?self