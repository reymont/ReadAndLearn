# https://gitee.com/geek_qi/ace-security/raw/master/README.md

# AG-Admin
AG-Admin是国内首个基于`Spring Cloud`微`服务`化`开发平台`，具有统一授权、认证后台管理系统，其中包含具备用户管理、资源权限管理、网关API管理等多个模块，支持多业务系统并行开发，可以作为后端服务的开发脚手架。代码简洁，架构清晰，适合学习和直接项目中使用。核心技术采用Eureka、Fegin、Ribbon、Zuul、Hystrix、`JWT Token`、Mybatis等主要框架和中间件，前端采用`vue-element-admin`组件。 

- 增加监控模块 

### 2018年1月1日
- ace-auth增加服务注册和授权模块

### 2017年11月17日 v2.2-SNARSHOT

- ace-admin集成`ace-cache`
- ace-auth集成`rabbitmq`


# 模块说明
### 架构详解
#### 服务鉴权
老A独有的通过`JWT`的方式来加强服务之间调度的权限验证，保证内部服务的安全性。
#### 监控
利用Spring Boot Admin 来监控各个独立Service的运行状态；利用Hystrix Dashboard来实时查看接口的运行状态和调用频率等。
#### 负载均衡
将服务保留的rest进行代理和网关控制，除了平常经常使用的node.js、nginx外，Spring Cloud系列的zuul和rebbion，可以帮我们进行正常的网关管控和负载均衡。其中扩展和借鉴国外项目的扩展基于JWT的`Zuul限流插件`，方面进行限流。
#### 服务注册与调用
基于Eureka来实现的服务注册与调用，在Spring Cloud中使用Feign, 我们可以做到使用HTTP请求远程服务时能与调用本地方法一样的编码体验，开发者完全感知不到这是远程方法，更感知不到这是个HTTP请求。
#### 熔断机制
因为采取了服务的分布，为了避免服务之间的调用“雪崩”，采用了`Hystrix`的作为熔断器，避免了服务之间的“雪崩”。

------
# 启动指南
## 须知
因为AG-Admin是一个`前后端分离`的项目，所以后端的服务必须先启动，在后端服务启动完成后，再启动前端的工程。
## 最多人问：代码有漏
下载完后端代码后，记得先安装`lombok插件`，否则你的IDE会报代码缺失。
## 后端工程启动
### 环境须知
- mysql一个，redis一个，rabbitmq一个
- jdk1.8
- IDE插件一个，`lombok插件`，具体百度即可

### 运行步骤
- 运行数据库脚本：依次运行数据库：ace-admin/db/init.sql、ace-auth-server/db/init.sql
- 修改配置数据库配置：ace-admin/src/main/resources/application.yml、ace-gate/src/main/resources/application.yml
- 按`顺序`运行main类：
  1. CenterBootstrap（ace-center）、
  2. ConfigServerBootstrap（ace-config）、
  3. AuthBootstrap（ace-auth-server）、
  4. AdminBootstrap（ace-admin）、
  5. GateBootstrap（ace-gate）

### 项目结构
```
├─ace-security
│  │  
│  ├─ace-admin----------------管理端服务层
│  │ 
│  ├─ace-auth-----------------鉴权中心
│  │ 
│  ├─ace-gate-----------------网关负载中心
│  │ 
│  ├─ace-center---------------服务注册中心
│  │   
│  ├─ace-monitor--------------统一监控中心
│  │
│  ├─ace-config---------------统一配置中心
│  │
│  ├─ace-api------------------公共服务接口包
│  │
│  ├─ace-demo-----------------示例服务代码
│  │
│  └─ace-sidebar--------------调用第三方语言
│
```
----

## 前端工程启动[AG-Admin-UI][地址](https://gitee.com/geek_qi/AG-Admin-v2.0)
### 环境搭建
```
node 版本：v6.11.2
npm 版本：3.10.10
```
### 开发

```bash
    
    # 安装依赖
    npm install
    //or # 建议不要用cnpm  安装有各种诡异的bug 可以通过如下操作解决npm速度慢的问题
    npm install --registry=https://registry.npm.taobao.org

    # 本地开发 开启服务
    npm run dev
```
浏览器访问 http://localhost:9527

### 发布
```bash
    # 发布测试环境 带webpack ananalyzer
    npm run build:sit-preview

    # 构建生成环境
    npm run build:prod
```

### 目录结构
```shell
├── build                      // 构建相关  
├── config                     // 配置相关
├── src                        // 源代码
│   ├── api                    // 所有请求
│   ├── assets                 // 主题 字体等静态资源
│   ├── components             // 全局公用组件
│   ├── directive              // 全局指令
│   ├── filtres                // 全局filter
│   ├── mock                   // mock数据
│   ├── router                 // 路由
│   ├── store                  // 全局store管理
│   ├── styles                 // 全局样式
│   ├── utils                  // 全局公用方法
│   ├── view                   // view
│   ├── App.vue                // 入口页面
│   └── main.js                // 入口 加载组件 初始化等
├── static                     // 第三方不打包资源
│   └── Tinymce                // 富文本
├── .babelrc                   // babel-loader 配置
├── eslintrc.js                // eslint 配置项
├── .gitignore                 // git 忽略项
├── favicon.ico                // favicon图标
├── index.html                 // html模板
└── package.json               // package.json

```
------------
# 功能简介
![img](http://upload-images.jianshu.io/upload_images/5700335-94d83ae2906db34f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
-----

## License

Apache License Version 2.0

