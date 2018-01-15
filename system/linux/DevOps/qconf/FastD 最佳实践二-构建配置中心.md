https://segmentfault.com/a/1190000010591858


过去专门做了一篇文档来构建配置中心，基于 zookeeper 的配置中心。

环境要求及构建步骤可参考: QConf搭建配置中心

随着业务增长，部署的机器可能会随着增长，增加配置难度和维护难度。配置会因为机器的增多而变得更加容易出错，为了解决这个问题，于是我们引入了 360 开发的 Qconf 来解决这个问题，目前已经稳定用于线上环境当中。

安装 qconf 扩展包

composer require fastd/qconf-service-provider -vvv
扩展包有点特殊，不需要任何的注册操作，当执行完 composer 依赖之后，会自动加载辅助函数，仅需对配置中心进行读取配置即可。

提供两个函数:

qconf_get_value 获取对应节点值

qconf_get_values 获取对应节点值数组

修改配置文件

config/config.php

<?php

return [
    'demo' => qconf_get_value('/demo/test', null, null, 'abc')
];
值得注意的是，如果万一不小心，qconf 出现错误或者异常无法运行的时候，则需要保留一个默认配置项，这个小动作可能会在你系统出现异常的时候救你一命。

测试配置中心

完成基础配置后，需要对配置中心进行简单的测试。

php bin/console config:dump config
结果会将配置文件进行输出，来确认是否可用。

最终架构图如下:



无论扩展多少个业务应用，仅需要一个配置中心即可完成多处配置修改。