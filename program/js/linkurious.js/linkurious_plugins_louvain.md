

linkurious.js实现Louvain社区发现算法 - sigma.statistics.louvain

原文：[linkurious.js/plugins/sigma.statistics.louvain at linkurious-version · Linkurious/linkurious.js ](https://github.com/Linkurious/linkurious.js/tree/linkurious-version/plugins/sigma.statistics.louvain)

阅读：

* [Louvain社区发现算法 - AllanSpark - 博客园 ](http://www.cnblogs.com/allanspark/p/4197980.html)

* [模块度与Louvain社区发现算法 - CodeMeals - 博客园 ](http://www.cnblogs.com/fengfenggirl/p/louvain.html)
* [community API — Community detection for NetworkX 2 documentation ](http://perso.crans.org/aynaud/communities/api.html)


插件[jLouvain](https://github.com/upphiminn/jLouvain)由Corneliu Sugar开发。[Sébastien Heymann](https://github.com/sheymann)把它移植到[Linkurious](https://github.com/Linkurious)。

Contact: seb@linkurio.us

-----

# 代码说明

完整版的代码在[这里](https://github.com/Linkurious/linkurious.js/blob/linkurious-version/examples/plugin-louvain.html)：

请在这个文件夹下包含所有js文件，然后按如下方式执行。

```js
var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph);
```

你可以提供一个`中介社区划分分配(intermediary community partition assignement)`：

```js
// Object with ids of nodes as properties and community number assigned as value.
var partitions_init = {'n1':0, 'n2':0, 'n3': 1};

var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph, {
  partitions: partitions_init
});
```

# 获取和设置社区

Communities are denoted by numerical identifiers, which are assigned to the nodes at the _louvain key unless an optional setter function is passed:
社区由数字标识，在`_louvain`关键字分配给节点，除非选择setter函数传递：

```js
var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph);

// get community of node 'n0': 
var c = sigmaInstance.graph.nodes('n0')._louvain;
// run with a setter argument:
var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph, {
  setter: function(communityId) { this.my_community = communityId; }
});

// get community of node 'n0': 
var c = sigmaInstance.graph.nodes('n0').my_community;
```

# 执行算法

执行如下代码，调用sigma.plugins.louvain()：
```js
louvainInstance.run();
```
可以提供一个社区划分分配的`媒介(intermediary)`：

```js
// Object with ids of nodes as properties and community number assigned as value.
var partitions_init = {'n1':0, 'n2':0, 'n3': 1};

louvainInstance.run({ partitions: partitions_init });
```
# 计算层次(levels of hierarchy)

The algorithm generates partitions of the graph (i.e. "communities") at multiple levels, with partitions at lower levels being included in partitions of the upper levels to form a dendogram. The higher level in the hierarchy the fewer partitions.
该算法生成的图形分区（即“社区”的多层次分区），在较低的水平，包括在上层隔板形成一个树状图(dendogram)。在层次结构中的更高层次的较少的分区

代码如下:

```js
var nbLevels = louvainInstance.countLevels();
```

# 分区

可以提取在层次结构中指定级别的分区：

```js
// Get partitions at the highest level:
var partitions = louvainInstance.getPartitions();
// equivalent to louvainInstance.getPartitions(louvainInstance.countLevels())

// Get partitions at the lowest level:
var partitions = louvainInstance.getPartitions({level: 1});
```

计算分区的数量
```js
var partitions = louvainInstance.getPartitions();
var nbPartitions = louvainInstance.countPartitions(partitions);
```

# 节点的社区分配

最高级别的社区将自动分配给节点。可以指定一个不同的级别的社区，代码如下：
```js
var nbLevels = louvainInstance.setResults({
  level: 1
});

// using a specific setter function:
var nbLevels = louvainInstance.setResults({
  level: 1
  setter: function(communityId) { this.communityLevel1 = communityId; }
});

// get highest level community of node 'n0': 
var c = sigmaInstance.graph.nodes('n0').my_community;

// get level 1 community of node 'n0': 
var c = sigmaInstance.graph.nodes('n0').communityLevel1;
```
# 小贴士: 怎样给节点添加颜色

* [jacomyal/sigma.js: A JavaScript library dedicated to graph drawing ](https://github.com/jacomyal/sigma.js)

下面的示例演示如何通过社区对颜色节点进行着色，假设有一组颜色：
```js
var colors = ["#D6C1B0", ..., "#9DDD5A"];

// 基于社区的分组进行着色
sigmaInstance.graph.nodes().forEach(function(node) {
  node.color = colors[node.my_community];
});

// 刷新sigma渲染(linkurious.js基于sigma.js开发)
sigmaInstance.refresh({skipIndexation: true});
```

# 注意

该算法通过寻找关键边的权重考虑关系的强度。