
[smly/java-labelpropagation: java implementation of labelpropagation ](https://github.com/smly/java-labelpropagation)


java-labelpropagation

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

# loadJSON

## `vertexAdjMap`和`vertexInAdjMap`的区别在哪里？

掉头
```json
1:[{"dest":2,"src":1,"weight":1},{"dest":3,"src":1,"weight":1}]
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

根据每个节点的权重计算度

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
