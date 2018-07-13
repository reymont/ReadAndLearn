
Java开源电商项目比較 - mfmdaoyou - 博客园 https://www.cnblogs.com/mfmdaoyou/p/6978370.html


这里比較的都是国外的开源项目，备选项目有：

Smilehouse Workspace、Pulse、Shopizer、ofbiz、bigfish、broadleaf


1、Smilehouse Workspace 是一个採用 Java 开发的电子商务应用程序。用来做产品、定案和客户信息管理。（从官网看，更像是一个管理系统）
2、Pulse没有使用spring，使用了hibernate，不清楚V端用了什么，使用的开源列表例如以下
        http://pulse.torweg.org/site/Pulsar/en_US.CMS.displayCMS.307./third-party-software-included-with-pulse
3、Shopizer基于spring、Spring Security、hibernate、elasticsearch、Spring MVC、jquery、JBoss Infinispan （更偏向CMS系统。文档常常訪问不了。程序不太稳定，网友反映有非常多bug）
        https://github.com/shopizer-ecommerce/shopizer/wiki
        www.shopizer.com/documentation.html
        http://www.shopizer.com/documentation.html#!/?
scrollTo=prepackaged
4、ofbiz类似ESB，要做电商修改比較大，它定义了自己的实体引擎、规则引擎等等，和spring的生态系统不兼容，须要又一次学习（学习曲线比較陡），并且非常多功能和业务对中小企业来说用不上。


5、bigfish是基于ofbiz的电商，实体引擎等是继承自ofbiz，和spring的生态系统不兼容，须要又一次学习
6、broadleaf基于spring、Spring MVC、Spring Security、JPA and Hibernate、Compass andLucene、Quartz、Thymeleaf
        除了免费社区版外。它还有收费企业版。


        目标是开发企业级商务站点，它提供健壮的数据和服务模型、富client管理平台、以及一些核心电子商务有关的工具。如今已经发展到4.x版本号了。社区也非常活跃，而且也有对应的商业版本号。对于有一定开发能力的中小企业来说，BroadleafCommerce是一个不错的电商平台首选，


个人推荐broadleaf

官网 http://www.broadleafcommerce.com/ 
https://github.com/BroadleafCommerce/BroadleafCommerce