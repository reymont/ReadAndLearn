

* [初试Jenkins2.0 Pipeline持续集成 - CSDN博客 ](http://blog.csdn.net/aixiaoyang168/article/details/72818804)

* Pipeline
  * 一套运行与Jenkins上的工作流框架
  * 单个或多个节点的任务连接起来
  * Groovy DSL实现
  * Pipelinie as Code
* 基本概念
  * Stage阶段
    * 一个Pipeline可划分为若干个Stage
    * 一个Stage代表一组操作
    * Stage是一个逻辑分组的概念，可以跨多个Node
  * Node节点：执行Step的具体运行环境，Master或者Agent
  * Step步骤：最基本的操作单元
* pipeline定义
  * pipeline scripts：直接输入Scripts
  * pipeline Scripts: 配置SCM代码存储Git地址