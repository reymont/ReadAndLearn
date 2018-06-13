Liquibase：与具体数据库独立的追踪、管理和应用数据库Scheme变化的工具 - 资源 - 伯乐在线 http://hao.jobbole.com/liquibase/

本资源由 伯乐在线 - 唐尤华 整理
liquibase

Liquibase是一个与具体数据库独立的追踪、管理和应用数据库Scheme变化的工具。

主要功能

支持代码分支与合并
支持多人开发
支持多种数据库类型
支持XML、YAML、JSON 与 SQL格式
支持上下文相关逻辑
支持集群安全的数据库升级
生成数据库变更文档
生成数据库“diff”
穿透构建流程，可根据应用需要嵌入到应用中
自动生成SQL脚本，供DBA进行代码审查
Does not require a live database connection
重构数据库

支持像 Create Table 和 Drop Column 这样的简单命令
支持像 Add Lookup Table 和 Merge Columns 这样的复杂命令
执行 SQL
支持生成与管理回滚逻辑
快速上手

下载Liquibase
创建changelog文件，支持XML、YAML、JSON 或 SQL格式
在changelog中添加changeset
执行liquibase更新
提交changelog到源码控制
返回第3步
开发资源

快速上手指南
官方文档
FAQ
支持的数据库
最佳实践
参与贡献
开源与扩展

Liquibase采用Apache 2.0协议开源发布
可以通过Extension支持扩展和重载几乎任何Liquibase功能
调用Java API执行和嵌入
官方网站：http://www.liquibase.org/
开源地址：http://github.com/liquibase/liquibase.