

Rancher Pipeline发布：开源、极简、强大的CI/CD | Rancher https://www.cnrancher.com/rancher-pipeline-an-open-source-minimalist-powerful-ci-cd/

来自硅谷的企业级容器管理平台提供商Rancher Labs今日正式发布与Rancher企业级容器管理平台集成的Rancher Pipeline，极简的操作体验，强大的功能整合，完全开源，助力CI/CD在企业的真正落地使用。

云计算技术的广泛采用和容器技术的日趋成熟已经改变了传统的IT交付方式，在以快为先的时代，产品快速迭代的重要性不言而喻，完全手动的、基于脚本的任务方式变得越来越繁琐、耗时且易于出错。且因为容器技术被越来越多地用于大型项目之中，如何通过一致的流程和工作流来简化大型项目的部署，亦变得愈发重要。

CI/CD（持续集成与持续交付）敏捷、稳定、可靠的特性，越来越被企业所青睐与需要。然而真正实现CI／CD却并非易事，pipeline搭建工作复杂，平滑升级难以保障，服务宕机难以避免，那该如何真正把CI/CD在企业里落地并最终带来生产运维效率的提升？来自硅谷的企业级容器管理平台提供商Rancher Labs，始终秉承着“让容器在企业落地”的理念，带来了开源、极简、功能强大的Rancher Pipeline解决方案，助力CI/CD在企业的真正落地。

Rancher Pipeline包含的强大功能有：

同时支持多源码管理
市场中大部分的CI/CD工具无法做到同时支持多种源代码管理，甚至暂不支持任何私有仓库。而在Rancher Pipeline中，Rancher创造性地让同一个Rancher用户可以同时使用GitHub与GitLab进行基于OAuth的身份验证，无需插件，即可在单一环境中同时拉取、使用和管理托管在GitHub和GitLab的代码。

图1

一致的用户体验
Rancher Pipeline可以从Rancher Catalog中一键部署，用户再无需自写脚本或受苦于复杂的部署过程。同时，Rancher Pipeline的用户界面与操作体验秉承了Rancher容器管理平台一贯广为用户所喜爱的简洁、友好的优点，将用户从繁琐复杂的代码与命令行中解放出来，一切pipeline配置均已可视化，用户可以轻松快速地以拖拽方式来构建pipeline。

图2

同时，Rancher Pipeline也允许用户将pipeline配置以yml文件的形式导出或导入，将整个配置存储为代码，真正实现“代码配置（Configuration as Code）”。

图3

阶段式和阶梯式pipeline
通过Rancher Pipeline，用户可以在串行或并行这两种任务运行方式中自由选择，且一切都已与Rancher无缝集成。

图4

同时，Rancher Pipeline提供了可自由扩展的步骤系统。用户构建的pipeline中的每个步骤类型都可以自由扩展，每个阶段中的各个步骤都可以自定义，可根据用户后期变化的需求自行选择增添或删减。更重要的是，在Rancher Pipeline中，一切步骤均以容器为基础，这使得每一个步骤都是一个独立的运行环境，不受外界干扰。天然解决了不同pipeline间环境依赖冲突的问题。

图5

灵活的流程控制
Rancher Pipeline中，用户可以在最初的设置阶段配置符合某既定要求的表达式或标签，而系统会在执行阶段根据执行情况自动跳过不符合该表达式或标签的阶段或步骤。如此一来，不同的代码分支可以自动匹配不同的CI流程，从而支持较为复杂的流程控制。

图6

支持多种触发方式
Rancher Pipeline支持多种触发方式，用户可以根据自己的需求自行选择。

Rancher Pipeline支持计划任务的触发，用户可以有两种配置选择：

当计划任务执行时，只有在有新的push时才触发pipeline。
一有计划任务执行时便触发pipeline。
图7

用户还可以选择通过来自GitHub / GitLab的webhook来触发pipeline。CI/CD 会在GitHub/GitLab上建立webhook，当用户push新代码至GitHub或GitLab时，GitHub/GitLab上的webhook会自动触发pipeline运行，完成代码的自动编译。

图8

同时，用户也可以选择手动触发，拥有完全自主权。

图9

更值得一提的是，用户可以通过定制化的开发，实现更多种触发方式的支持。

审批系统
在CI/CD pipeline中，良好集成的审批系统可以很大程度地提高CI/CD pipeline的安全可控性，而这对企业而言十分重要。在Rancher Pipeline中，审批系统已与Rancher用户管理系统集成，拥有极佳的整合性。且用户可以在任意阶段插入断点，自由地对任意阶段进行审批。

图10

灵活的pipeline启停机制
Rancher Pipeline拥有灵活的进度控制功能，任一环节出错，整个进度可以立即停止，而问题解决之后又可以重新运行。

图11-1 图11-2

与其他CI/CD工具的对比
图12

如何使用Rancher Pipeline
使用rancher/server:v1.6.13-rc6以上版本，即可在Rancher Catalog中直接选择并部署Rancher Pipeline。一切开源，源码及更多使用指南请访问Github