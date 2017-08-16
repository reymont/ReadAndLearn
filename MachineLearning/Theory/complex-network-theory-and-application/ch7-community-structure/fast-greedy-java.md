


* [cytoscape/cytoscape-impl: Cytoscape 3 implementation bundles. ](https://github.com/cytoscape/cytoscape-impl)

* [phiradet/gephiSample: Collect many sample code dealing with Gephi Toolkit ](https://github.com/phiradet/gephiSample)

karate.gexf

* [gexf-app/TestBase.java at master · bdemchak/gexf-app ](https://github.com/bdemchak/gexf-app/blob/master/src/test/java/edu/umuc/swen670/gexf/internal/io/TestBase.java)

GEXFNetworkReader -> CyNetworkReader

```java
CyNetworkReader reader = new GEXFNetworkReader(stream, cyNetworkViewFactory, cyNetworkFactory, cyNetworkManager, 
													   cyRootNetworkManager, cyEventHelper, cyGroupFactory, cyGroupManager, 
													   cyGroupSettingsManager, passthroughMapper, visualMappingManager);
		
		
```

* [clusterMaker2/FastGreedyAlgorithm.java at master · RBVI/clusterMaker2 ](https://github.com/RBVI/clusterMaker2/blob/master/src/main/java/edu/ucsf/rbvi/clusterMaker2/internal/algorithms/networkClusterers/GLay/FastGreedyAlgorithm.java)





```java
//\edu\ucsf\rbvi\clusterMaker2\internal\algorithms\networkClusterers\GLay\GLayContext.java
//Tunables
@Tunable(description = "Cluster only selected nodes",groups={"Basic GLay Tuning"},gravity=1.0)
public boolean selectedOnly = false;
@Tunable(description = "Assume edges are undirected", groups={"Basic GLay Tuning"},gravity=2.0)
public boolean undirectedEdges = true;

//\edu\ucsf\rbvi\clusterMaker2\internal\algorithms\networkClusterers\GLay\GLayCluster.java
GSimpleGraphData simpleGraph = new GSimpleGraphData(network, context.selectedOnly, context.undirectedEdges);
		fa = new FastGreedyAlgorithm();
		//fa.partition(simpleGraph);
		fa.execute(simpleGraph, monitor);

//\edu\ucsf\rbvi\clusterMaker2\internal\algorithms\networkClusterers\GLay\GSimpleGraphData.java
public GSimpleGraphData(CyNetwork network, boolean selectedOnly, boolean undirectedEdges){
    this.network = network;
			this.selectedOnly = selectedOnly;
			this.undirectedEdges = undirectedEdges;
			if (!selectedOnly) {
				this.nodeList = (List<CyNode>)network.getNodeList();
			} else {
				this.nodeList = new ArrayList<CyNode>(CyTableUtil.getNodesInState(network, CyNetwork.SELECTED, true));
			}
			this.nodeCount = nodeList.size();
			this.connectingEdges = ModelUtils.getConnectingEdges(network, nodeList);
			this.edgeCount = this.connectingEdges.size();
    this.graphIndices = new CyNode[this.nodeCount];
    this.degree = new int[this.nodeCount];
    this.edgeMatrix = DoubleFactory2D.sparse.make(nodeCount, nodeCount);
    this.simplify();
}
```