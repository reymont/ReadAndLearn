
基于 GlusterFS 实现 Docker 集群的分布式存储 
https://www.ibm.com/developerworks/cn/opensource/os-cn-glusterfs-docker-volume/index.html

* 开源的分布式文件系统
  * GFS
  * Ceph
  * HDFS
  * FastDFS
  * GlusterFS

# GlusterFS 分布式文件系统简介

* GlusterFS 概述
  * `横向扩展`，支持PB集存储容量
  * GlusterFS借助`TCP/IP或InfiniBand RDMA网络`将物理分布的存储资源聚集在一起
  * 使用`单一全局命名空间`来管理数据
  * GlusterFS基于`可堆叠`的用户空间设计，为各种不同的数据负载提供优异的性能
* GlusterFS总体架构

# GlusterFS 分布式文件系统安装与配置

# Docker GlusterFS Volume 插件

# GlusterFS REST API 服务搭建

# 基于 GlusterFS 实现数据持久化案例