
# 标签传递算法：java版


<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->
<!-- code_chunk_output -->

* [标签传递算法：java版](#标签传递算法java版)
* [java-labelpropagation](#java-labelpropagation)
* [本地测试](#本地测试)
* [数据集](#数据集)
* [LPAlgorithm](#lpalgorithm)
	* [loadJSON](#loadjson)
		* [`vertexAdjMap`和`vertexInAdjMap`的区别在哪里？](#vertexadjmap和vertexinadjmap的区别在哪里)
		* [根据每个节点的权重计算度`vertexDegMap`](#根据每个节点的权重计算度vertexdegmap)
		* [标签](#标签)
			* [TreeSet](#treeset)
			* [构建`vSet`，`lSet`和`labelIndexMap`](#构建vsetlset和labelindexmap)
			* [构建`vertexFMap`](#构建vertexfmap)
	* [showDetail](#showdetail)
* [GFHF](#gfhf)
	* [iter](#iter)
		* [处理未标签的节点`nextVertexFMap`](#处理未标签的节点nextvertexfmap)
			* [value的值](#value的值)
			* [结果`nextVertexFMap`](#结果nextvertexfmap)
		* [将已标签的节点回写到`nextVertexFMap`](#将已标签的节点回写到nextvertexfmap)
		* [循环多次结果](#循环多次结果)
	* [debug](#debug)

<!-- /code_chunk_output -->



原文：[smly/java-labelpropagation: java implementation of labelpropagation ](https://github.com/smly/java-labelpropagation)


# java-labelpropagation

Java implementation of GFHF ([Zhu and Ghahramani, 2002]).

 Iterate
  1. \hat{Y}^{(t+1)} \leftArrow D^{-1} W \hat{Y}^{(t)}
  2. \hat{Y}^{(t+1)}_l \leftArrow Y_l
 until convergence to \hat{Y}^{(\infty)}
Usage

```bash
  $ mvn compile
  $ mvn package
  $ cat data/sample.json
  [2, 1, [[1, 1.0], [3, 1.0]]]
  [3, 0, [[1, 1.0], [2, 1.0], [4, 1.0]]]
  [4, 0, [[3, 1.0], [5, 1.0], [8, 1.0]]]
  [5, 0, [[4, 1.0], [6, 1.0], [7, 1.0]]]
  [6, 2, [[5, 1.0], [7, 1.0]]]
  [7, 0, [[5, 1.0], [6, 1.0]]]
  [8, 0, [[4, 1.0], [9, 1.0]]]
  [9, 2, [[8, 1.0]]]
  $ java -classpath target/labelprop-1.0-SNAPSHOT-jar-with-dependencies.jar \
     org.ooxo.LProp \
     -a GFHF \
     -m 100 \
     -e 10e-5 \
     data/sample.json
  Number of vertices:            9
  Number of class labels:        2
  Number of unlabeled vertices:  6
  Numebr of labeled vertices:    3
  eps:                          1e-5
  max iteration:                100
  .............................
  iter = 29, eps = 9.918212890613898E-5
  [1,1,[1,0.8706],[2,0.1294]]
  [2,1,[1,1.0000],[2,0.0000]]
  [3,1,[1,0.7412],[2,0.2588]]
  [4,2,[1,0.3529],[2,0.6470]]
  [5,2,[1,0.1412],[2,0.8588]]
  [6,2,[1,0.0000],[2,1.0000]]
  [7,2,[1,0.0706],[2,0.9294]]
  [8,2,[1,0.1765],[2,0.8235]]
  [9,2,[1,0.0000],[2,1.0000]]
```
References

Chapelle O, Schölkopf B and Zien A: Semi-Supervised Learning, 508, MIT Press, Cambridge, MA, USA, (2006).
http://mitpress.mit.edu/catalog/item/default.asp?ttype=2&tid=11015


# 本地测试
E:\workspace\java\java-labelpropagation
```bash
git clone https://github.com/smly/java-labelpropagation.git
mvn clean package
java -classpath target/labelprop-1.0-SNAPSHOT-jar-with-dependencies.jar org.ooxo.LProp -a GFHF -m 100 -e 10e-5 data/sample.json
```


# 数据集

[vertexId, vertexLabel, edges[destVertexId, edgeWeight]]
如果`vertexLabel == 0`，则表示未打标签。`destVertexId`连接的另一个节点，`edgeWeight`边的权重。

```json
[1, 0, [[2, 1.0], [3, 1.0]]]
[2, 1, [[1, 1.0], [3, 1.0]]]
[3, 0, [[1, 1.0], [2, 1.0], [4, 1.0]]]
[4, 0, [[3, 1.0], [5, 1.0], [8, 1.0]]]
[5, 0, [[4, 1.0], [6, 1.0], [7, 1.0]]]
[6, 2, [[5, 1.0], [7, 1.0]]]
[7, 0, [[5, 1.0], [6, 1.0]]]
[8, 0, [[4, 1.0], [9, 1.0]]]
[9, 2, [[8, 1.0]]]
```

# LPAlgorithm

```java
void processLine(String line) {
	try {
		// [vertexId, vertexLabel, edges]
		// unlabeled vertex if vertexLabel == 0
		// i.e. [2, 1, [[1, 1.0], [3, 1.0]]]
		JSONArray json = new JSONArray(line);
		Long vertexId = json.getLong(0);
		Long vertexLabel = json.getLong(1);
		JSONArray edges = json.getJSONArray(2);
		ArrayList<Edge> edgeArray = new ArrayList<Edge>();
		vertexLabelMap.put(vertexId, vertexLabel);
		for (int i = 0; i < edges.length(); ++i) {
			JSONArray edge = edges.getJSONArray(i);
			Long destVertexId = edge.getLong(0);
			Double edgeWeight = edge.getDouble(1);
			edgeArray.add(new Edge(vertexId, destVertexId, edgeWeight));
		}
		vertexAdjMap.put(vertexId, edgeArray);
	} catch (JSONException e) {
		throw new IllegalArgumentException(
				"Coundn't parse vertex from line: " + line, e);
	}
}
```

处理一行数据，将标签存到`vertexLabelMap`，将节点和边的情况存到`vertexAdjMap`。

`vertexLabelMap`
> [vertexId, vertexLabel]

`vertexAdjMap`
> [vertexId, [vertexId, destVertexId, edgeWeight]]


## loadJSON

### `vertexAdjMap`和`vertexInAdjMap`的区别在哪里？

掉头
```json
//vertexAdjMap
1:[{"dest":2,"src":1,"weight":1},{"dest":3,"src":1,"weight":1}]
//vertexInAdjMap
1:[{"dest":1,"src":2,"weight":1},{"dest":1,"src":3,"weight":1}]
```

```java
// initialize vertexInAdjMap
for (Long vertexId : vertexAdjMap.keySet()) {
	if (! vertexInAdjMap.containsKey(vertexId)) {
		vertexInAdjMap.put(vertexId, new ArrayList<Edge>());
	}
}
// setup vertexInAdjMap
for (Long vertexId : vertexAdjMap.keySet()) {
	for (Edge e : vertexAdjMap.get(vertexId)) {
		vertexInAdjMap.get(e.getDest()).add(e);
	}
}
```

### 根据每个节点的权重计算度`vertexDegMap`

```java
// setup vertexDegMap
for (Long vertexId : vertexAdjMap.keySet()) {
	double degree = 0;
	if (vertexDegMap.containsKey(vertexId)) {
		degree = vertexDegMap.get(vertexId);
	}
	for (Edge e : vertexAdjMap.get(vertexId)) {
		degree += e.getWeight();
	}
	vertexDegMap.put(vertexId, degree);
}
```

`vertexDegMap`
{1=2.0, 2=2.0, 3=3.0, 4=3.0, 5=3.0, 6=2.0, 7=2.0, 8=2.0, 9=1.0}

### 标签

```java
// setup vertexFMap
Set<Long> vSet = vertexLabelMap.keySet();
Iterator<Long> it = vSet.iterator();
Set<Long> lSet = new TreeSet<Long>();
while (it.hasNext()) {
	
	Long l = vertexLabelMap.get(it.next());
	lSet.add(l);
	vertexSize++;
}
Iterator<Long> lSetIter = lSet.iterator();
int labelEnum = 0;
while (lSetIter.hasNext()) {
	Long l = lSetIter.next();
	if (l.intValue() == 0) continue;
	labelIndexMap.put(l, new Long(labelEnum));
	labelEnum++;
}
labelSize = labelEnum;
it = vSet.iterator();
labeledSize = 0;
while (it.hasNext()) {
	Long v = it.next();
	ArrayList<Double> arr = new ArrayList<Double>(labelEnum);
	Long l = vertexLabelMap.get(v);
	if (l.intValue() == 0) {
		// unlabeled
		for (int i = 0; i < labelSize; ++i) {
			arr.add(0.0);
		}
	} else {
		// labeled
		labeledSize++;
		int ix = labelIndexMap.get(vertexLabelMap.get(v)).intValue();
		for (int i = 0; i < labelSize; ++i) {
			arr.add((i == ix) ? 1.0 : 0.0);
		}
	}
	vertexFMap.put(v, arr);
}
```
#### TreeSet

[Java 集合系列17之 TreeSet详细介绍(源码解析)和使用示例 - 如果天空不死 - 博客园 ](http://www.cnblogs.com/skywang12345/p/3311268.html)
[java TreeSet的使用 - you_off3的专栏 - CSDN博客 ](http://blog.csdn.net/you_off3/article/details/7465919)

`Set<Long> lSet = new TreeSet<Long>();`
TreeSet:它可以给Set集合中的元素进行指定方式的排序。保证元素唯一性的方式：通过比较的结果是否为0。底层数据结构是：二叉树。TreeSet是基于TreeMap实现的。TreeSet中的元素支持2种排序方式：自然排序 或者 根据创建TreeSet 时提供的 Comparator 进行排序。这取决于使用的构造方法。


#### 构建`vSet`，`lSet`和`labelIndexMap`

```java
Set<Long> vSet = vertexLabelMap.keySet();
Iterator<Long> it = vSet.iterator();
Set<Long> lSet = new TreeSet<Long>();
while (it.hasNext()) {
	
	Long l = vertexLabelMap.get(it.next());
	lSet.add(l);
	vertexSize++;
}
Iterator<Long> lSetIter = lSet.iterator();
int labelEnum = 0;
while (lSetIter.hasNext()) {
	Long l = lSetIter.next();
	if (l.intValue() == 0) continue;
	labelIndexMap.put(l, new Long(labelEnum));
	labelEnum++;
}
labelSize = labelEnum;
```

`vSet`
[1, 2, 3, 4, 5, 6, 7, 8, 9]
`lSet`
[0, 1, 2]
`labelIndexMap`是对label进行编号，`1=0`表示`标签1`放在第`0`个位置上。
{1=0, 2=1}

#### 构建`vertexFMap`

```java
it = vSet.iterator();
labeledSize = 0;
while (it.hasNext()) {
	Long v = it.next();
	ArrayList<Double> arr = new ArrayList<Double>(labelEnum);
	Long l = vertexLabelMap.get(v);
	if (l.intValue() == 0) {
		// unlabeled
		for (int i = 0; i < labelSize; ++i) {
			arr.add(0.0);
		}
	} else {
		// labeled
		labeledSize++;
		int ix = labelIndexMap.get(vertexLabelMap.get(v)).intValue();
		for (int i = 0; i < labelSize; ++i) {
			arr.add((i == ix) ? 1.0 : 0.0);
		}
	}
	vertexFMap.put(v, arr);
}
```

`vertexFMap`
{1=[0.0, 0.0], 2=[1.0, 0.0], 3=[0.0, 0.0], 4=[0.0, 0.0], 5=[0.0, 0.0], 6=[0.0, 1.0], 7=[0.0, 0.0], 8=[0.0, 0.0], 9=[0.0, 1.0]}

## showDetail

```java
void showDetail() {
	System.out.println("Number of vertices:            " + vertexSize);
	System.out.println("Number of class labels:        " + labelSize);
	System.out.println("Number of unlabeled vertices:  " + (vertexSize - labeledSize));
	System.out.println("Numebr of labeled vertices:    " + labeledSize);
}
```


# GFHF


## iter

### 处理未标签的节点`nextVertexFMap`

```java
// for all vertex
double diff = 0.0;
for (Long vertexId : vertexFMap.keySet()) {
	if (vertexLabelMap.get(vertexId) != 0) continue; // skip labeled
	// update F(vertexID) ... vetexFMap
	ArrayList<Double> nextFValue = new ArrayList<Double>();
	ArrayList<Double> fValues = vertexFMap.get(vertexId);
	for (int l = 0; l < labelSize; ++l) {
		// update f_l(vertexId)
		double fValue = 0.0;
		for (Edge e : vertexInAdjMap.get(vertexId)) {
			double w = e.getWeight();
			long src = e.getSrc();
			double deg = vertexDegMap.get(vertexId);
			fValue += vertexFMap.get(src).get(l) * (w / deg);
			System.out.println("(src,dst): " + src + "->" + vertexId + ", value = (" + fValue +"), deg = " + deg + ", label = " + l);
		}
		nextFValue.add(fValue);
		if (vertexLabelMap.get(vertexId) == 0) {
			diff += ((fValue > fValues.get(l)) ? fValue - fValues.get(l) : fValues.get(l) - fValue);
		}
	}
	//System.out.println(nextFValue);
	nextVertexFMap.put(vertexId, nextFValue);
	//System.out.println("----");
}
```

#### value的值
> fValue += vertexFMap.get(src).get(l) * (w / deg);

```
(src,dst): 2->1, value = (0.5), deg = 2.0, label = 0
(src,dst): 3->1, value = (0.5), deg = 2.0, label = 0
(src,dst): 2->1, value = (0.0), deg = 2.0, label = 1
(src,dst): 3->1, value = (0.0), deg = 2.0, label = 1
```

#### 结果`nextVertexFMap`
{1=[0.5, 0.0], 3=[0.3333333333333333, 0.0], 4=[0.0, 0.0], 5=[0.0, 0.3333333333333333], 7=[0.0, 0.5], 8=[0.0, 0.5]}


### 将已标签的节点回写到`nextVertexFMap`

```java
// fix labeled vertex
for (Long vertexId : vertexLabelMap.keySet()) {
	if (vertexLabelMap.get(vertexId) == 0) continue; // 0 means unlabeled vertex
	nextVertexFMap.put(vertexId, vertexFMap.get(vertexId));
}
```

最后将`nextVertexFMap`赋值给`vertexFMap`
> vertexFMap = nextVertexFMap;

`nextVertexFMap`
`vertexFMap`
{1=[0.5, 0.0], 2=[1.0, 0.0], 3=[0.3333333333333333, 0.0], 4=[0.0, 0.0], 5=[0.0, 0.3333333333333333], 6=[0.0, 1.0], 7=[0.0, 0.5], 8=[0.0, 0.5], 9=[0.0, 1.0]}

### 循环多次结果

`vertexFMap`
{1=[0.8705767912004067, 0.12939269122146832], 2=[1.0, 0.0], 3=[0.7411612117974713, 0.25880064122987234], 4=[0.3529182882869945, 0.6470206765567554], 5=[0.14116121180087424, 0.8588006412264694], 6=[0.0, 1.0], 7=[0.0705767912042349, 0.92939269121764], 8=[0.1764553294462316, 0.8235065235811121], 9=[0.0, 1.0]}

## debug

```java
void debug() {
	ArrayList<Long> labels = new ArrayList<Long>(labelSize);
	for (Long label : labelIndexMap.keySet()) {
		labels.add(labelIndexMap.get(label).intValue(), label);
	}
	for (Long vertexId : vertexFMap.keySet()){
		ArrayList<Double> arr = vertexFMap.get(vertexId);
		System.out.printf("[%d,", vertexId);
		ByteArrayOutputStream buff = new ByteArrayOutputStream();
		PrintStream ps = new PrintStream(buff);
		double maxFVal = 0.0;
		int maxFValIx = 0;
		for (int i = 0; i < labelSize; ++i) {
			double fval = arr.get(i);
			if (fval > maxFVal) {
				maxFVal = fval;
				maxFValIx = i;
			}
			ps.printf("[%d,%.04f]", labels.get(i), arr.get(i));
			ps.printf(i != labelSize - 1 ? "," : "]\n");
		}
		System.out.print(labels.get(maxFValIx) + "," + buff.toString());
	}
}
```

比较`vertexFMap`中的值。哪个大，则标标记为对应标签。

例如
> 1=[0.8705767912004067, 0.12939269122146832]

输出
> [1,1,[1,0.8706],[2,0.1294]]

最终结果输出
[1,1,[1,0.8706],[2,0.1294]]
[2,1,[1,1.0000],[2,0.0000]]
[3,1,[1,0.7412],[2,0.2588]]
[4,2,[1,0.3529],[2,0.6470]]
[5,2,[1,0.1412],[2,0.8588]]
[6,2,[1,0.0000],[2,1.0000]]
[7,2,[1,0.0706],[2,0.9294]]
[8,2,[1,0.1765],[2,0.8235]]
[9,2,[1,0.0000],[2,1.0000]]

1,2,3标记为1
4,5,6,7,8,9标记为2