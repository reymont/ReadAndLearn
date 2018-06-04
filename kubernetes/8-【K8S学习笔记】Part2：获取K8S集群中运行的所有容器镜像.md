【K8S学习笔记】Part2：获取K8S集群中运行的所有容器镜像 - HackHan - 博客园 https://www.cnblogs.com/leejack/p/8319311.html

本文将介绍如何使用kubectl列举K8S集群中运行的Pod内的容器镜像。

注意：本文针对K8S的版本号为v1.9，其他版本可能会有少许不同。

0x00 准备工作

需要有一个K8S集群，并且配置好了kubectl命令行工具来与集群通信。如果未准备好集群，那么你可以使用Minikube创建一个K8S集群，或者你也可以使用下面K8S环境二者之一：

Katacoda
Play with Kubernetes
如果需要查看K8S版本信息，可以输入指令kubectl version。

在本练习中，我们将使用kubectl获取集群中运行的所有Pod，并以指定格式输出各Pod中运行的容器。

0x01 列举所有命名空间中的容器

使用命令kubectl get pods --all-namespaces获取所有命名空间中的所有Pod。
使用-o jsonpath={..image}格式化输出，使其仅仅包含容器镜像名称，这将递归解析返回的json对象中的image字段。
获取更多关于如何使用jsonpath的信息，参见jsonpath reference。
使用标准工具tr、sort和uniq格式化输出。
使用tr以新行替换空格
使用sort对结果排序
使用uniq统计镜像数量
kubectl get pods --all-namespaces -o jsonpath="{..image}" |\
tr -s '[[:space:]]' '\n' |\
sort |\
uniq -c
上述命令会对所有返回的项目，递归地返回所有名为image的字段。

此外，另一种方法是使用image字段在Pod内的绝对路径。这能够保证获取正确的字段，即使该字段名称在Pod中重复多次，例如，在一个给定的项目中，可能会有很多字段名称都是name：

kubectl get pods --all-namespaces -o jsonpath="{.items[*].spec.containers[*].image}"
上述的jsonpath按以下方式解析：

.items[*]：针对每一个返回的值
.spec：获取spec
.containers[*]：针对每个容器
.image：获取镜像
注意：当通过名称获取单个Pod时，例如：kubectl get pod nginx，那么路径中的.items[*]部分将会省略，因为返回的是单个Pod，而不是多个Pod的列表。

0x02 通过Pod列举容器

我们可以使用range操作进一步控制输出格式，以此来逐个迭代每一个元素：

kubectl get pods --all-namespaces -o=jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\
sort
0x03 列举Pod标签过滤的容器

如果目标是那些匹配特定标签的Pod，那么可以使用-l标记。下面指令仅仅匹配含有标签app=nginx的Pod：

kubectl get pods --all-namespaces -o=jsonpath="{..image}" -l app=nginx
0x04 列举Pod命名空间过滤的容器

如果目标是那些匹配特定命名空间的Pod，那么可以使用--namespace标记。下面指令仅仅匹配存在于kube-system命名空间中的Pod：

kubectl get pods --namespace kube-system -o jsonpath="{..image}"
0x05 使用go-template列举容器

作为jsonpath的另一个选择，Kubectl支持使用go-template来格式化输出内容：

kubectl get pods --all-namespaces -o go-template --template="{{range .items}}{{range .spec.containers}}{{.image}} {{end}}{{end}}"
0x06 参考内容

Jsonpath参考指南
Go template参考指南
英文原文：https://kubernetes.io/docs/tasks/access-application-cluster/list-all-running-container-images/

分类: Kubernetes
标签: K8S, kubernetes