

* [Community Detection · Linkurious/linkurious.js Wiki ](https://github.com/Linkurious/linkurious.js/wiki/Community-Detection)

The Louvain community detection algorithm looks for the nodes that are more densely connected together than to the rest of the network.

Learn the API here

Formally, a community detection aims to partition a graph's nodes in subsets, such that there are many edges connecting between nodes of the same sub-set compared to nodes of different sub-sets; in essence, a community has many more ties between each constituent part than with outsiders. There are numerous algorithms present in the literature for solving this problem, a complete survey can be found in [1].
形式上，社区发现的目的是在一个图中按子集划分节点，使得同一个子集的节点之间有许多边连接到不同子集的节点。本质上，一个社区在每个组成部分中与局外人之间有更多的联系。在文献中有许多解决这个问题的算法，可以在论文[1]中阅读。

The Louvain community detection algorithm, one of the popular algorithms, is presented in [2]. This algorithm separates the network in communities by optimizing greedily a modularity score after trying various grouping operations on the network. By using this simple greedy approach the algorithm is computationally very efficient.
Louvain的社区发现算法，一个流行的算法，是在[2]。该算法通过在网络上尝试各种分组操作后，贪婪地优化模块化得分，从而在社区中分离网络。通过使用这种简单的贪婪方法，该算法在计算上非常有效。

[1] Fortunato, Santo. "[Community detection in graphs.](http://cs.ndsu.edu/~perrizo/saturday/Community%20Detection%20in%20Graphs%20Santo%20Fortunato.pdf)" Physics Reports 486, no. 3-5 (2010).

[2] V.D. Blondel, J.-L. Guillaume, R. Lambiotte, E. Lefebvre. "[Fast unfolding of communities in large networks.](https://arxiv.org/abs/0906.0612v2)" J. Stat. Mech., 2008: 1008.

Before After


* [Louvain社区发现算法 - AllanSpark - 博客园 ](http://www.cnblogs.com/allanspark/p/4197980.html)

* [模块度与Louvain社区发现算法 - CodeMeals - 博客园 ](http://www.cnblogs.com/fengfenggirl/p/louvain.html)
* [community API — Community detection for NetworkX 2 documentation ](http://perso.crans.org/aynaud/communities/api.html)

* [linkurious.js/plugins/sigma.statistics.louvain at linkurious-version · Linkurious/linkurious.js ](https://github.com/Linkurious/linkurious.js/tree/linkurious-version/plugins/sigma.statistics.louvain)


sigma.statistics.louvain

Plugin developed by Corneliu Sugar as jLouvain and ported as a Sigma plugin by Sébastien Heymann for Linkurious.

Contact: seb@linkurio.us

General

Formally, a community detection aims to partition a graph’s vertices in subsets, such that there are many edges connecting between vertices of the same sub-set compared to vertices of different sub-sets; in essence, a community has many more ties between each constituent part than with outsiders. There are numerous algorithms present in the literature for solving this problem, a complete survey can be found in [1].

One of the popular community detection algorithms is presented in [2]. This algorithm separates the network in communities by optimizing greedily a modularity score after trying various grouping operations on the network. By using this simple greedy approach the algorithm is computationally very efficient.

[1] Fortunato, Santo. "Community detection in graphs." Physics Reports 486, no. 3-5 (2010).

[2] V.D. Blondel, J.-L. Guillaume, R. Lambiotte, E. Lefebvre. "Fast unfolding of communities in large networks." J. Stat. Mech., 2008: 1008.

Before After

Usage

See the following example code for full usage.

To use, include all .js files under this folder, then execute it as follows.

var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph);
You can optionally provide an intermediary community partition assignement as follows:

// Object with ids of nodes as properties and community number assigned as value.
var partitions_init = {'n1':0, 'n2':0, 'n3': 1};

var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph, {
  partitions: partitions_init
});
Get and set communities

Communities are denoted by numerical identifiers, which are assigned to the nodes at the _louvain key unless an optional setter function is passed:

var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph);

// get community of node 'n0': 
var c = sigmaInstance.graph.nodes('n0')._louvain;
// run with a setter argument:
var louvainInstance = sigma.plugins.louvain(sigmaInstance.graph, {
  setter: function(communityId) { this.my_community = communityId; }
});

// get community of node 'n0': 
var c = sigmaInstance.graph.nodes('n0').my_community;
Re-run the algorithm

Execute the algorithm again after calling sigma.plugins.louvain() as follows:

louvainInstance.run();
You can optionally provide an intermediary community partition assignement as follows:

// Object with ids of nodes as properties and community number assigned as value.
var partitions_init = {'n1':0, 'n2':0, 'n3': 1};

louvainInstance.run({ partitions: partitions_init });
Count levels of hierarchy

The algorithm generates partitions of the graph (i.e. "communities") at multiple levels, with partitions at lower levels being included in partitions of the upper levels to form a dendogram. The higher level in the hierarchy the fewer partitions.

Count levels of hierarchy as follows:

var nbLevels = louvainInstance.countLevels();
Partitions

You may extract partitions at a specified level of hierarchy as follows:

// Get partitions at the highest level:
var partitions = louvainInstance.getPartitions();
// equivalent to louvainInstance.getPartitions(louvainInstance.countLevels())

// Get partitions at the lowest level:
var partitions = louvainInstance.getPartitions({level: 1});
It may be useful to count the number of partitions:

var partitions = louvainInstance.getPartitions();
var nbPartitions = louvainInstance.countPartitions(partitions);
Assign communities to the nodes

Communities at the highest level are automatically assigned to the nodes. You may assign communities of a different level as follows:

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
Tip: How to color the nodes

The following example shows how to color nodes by community, assuming an array of colors:

var colors = ["#D6C1B0", ..., "#9DDD5A"];

// Color nodes based on their community
sigmaInstance.graph.nodes().forEach(function(node) {
  node.color = colors[node.my_community];
});

// refresh sigma renderers:
sigmaInstance.refresh({skipIndexation: true});
Notes

The algorithm takes strength of ties into account by looking for the weight key in edges.