

- [graph - How to visualize a large network in R? - Stack Overflow ](https://stackoverflow.com/questions/22453273/how-to-visualize-a-large-network-in-r)

Network visualizations become common in science in practice. But as networks are increasing in size, common visualizations become less useful. There are simply too many nodes/vertices and links/edges. Often visualization efforts end up in producing "hairballs".

Some new approaches have been proposed to overcome this issue, e.g.:

Edge bundling:
http://vis.stanford.edu/papers/divided-edge-bundling or
https://gephi.org/tag/edge-bundling/
Hierarchial edge bundling:
http://graphics.cs.illinois.edu/sites/graphics.dev.engr.illinois.edu/files/edgebundles.pdf
Group Attributes Layout:
http://wiki.cytoscape.org/Cytoscape_3/UserManual
How to make grouped layout in igraph?
I am sure that there are many more approaches. Thus, my question is: How to overcome the hairball issue, i.e. how to visualize large networks by using R?

Here is some code that simulates an exemplary network:

# Load packages
lapply(c("devtools", "sna", "intergraph", "igraph", "network"), install.packages)
library(devtools)
devtools::install_github(repo="ggally", username="ggobi")
lapply(c("sna", "intergraph", "GGally", "igraph", "network"), 
       require, character.only=T)

# Set up data
set.seed(123)
g <- barabasi.game(1000)

# Plot data
g.plot <- ggnet(g, mode = "fruchtermanreingold")
g.plot
enter image description here

This questions is related to Visualizing Undirected Graph That's Too Large for GraphViz?. However, here I am searching not for general software recommendations but for concrete examples (using the data provided above) which techniques help to make a good visualization of a large network by using R (comparable to the examples in this thread: R: Scatterplot with too many points).

r graph visualization social-networking graph-visualization
shareedit
edited May 23 at 11:47

Community♦
11
asked Mar 17 '14 at 11:35

majom
3,22423060
2	 	
I fear this might get closed as too broad, but I like the effort and care you have put into this question and I actually think with some well-crafted answers this could be a useful resource. +1 from me (and no close-vote). – Simon O'Hanlon Mar 17 '14 at 11:46
2	 	
All the approaches you described above try to handle the issue given an higher focus to specific details of the network. So, the question becomes: which aspect of the network to visualize are you interested? From this it's possible to start a discussion to find the right way to handle your problem. – MarcoL Mar 17 '14 at 12:13
  	 	
@ MarcoCI: I was looking for rather general advices/best practices, which are applicable to many different networks. For sure, it would be possible to add an additional randomly generated atttribute on node- or edge-level - if necessary. – majom Mar 17 '14 at 12:27
  	 	
A general advice is always to remove/reduce the noise in the network: remove non-connected nodes, fade/ghost/filter nodes with a lower index for a particular score (SNA metrics, Klout score, usually...). In case you need the aggregated value of the information, than you can group nodes/links together to minimize the noise as well: at this point an on demand inspection it's useful. – MarcoL Mar 17 '14 at 13:53
  	 	
But, most of the time, focus your "visualization question" drives you to useful and more creative approaches that might solve your problem. – MarcoL Mar 17 '14 at 13:56
show 1 more comment


I've been dealing with this problem recently. As a result, I've come up with another solution. Collapse the graph by communities/clusters. This approach is similar to the third option outlined by the OP above. As a word of warning, this approach will work best with undirected graphs. For example:

library(igraph)

set.seed(123)
g <- barabasi.game(1000) %>%
  as.undirected()

#Choose your favorite algorithm to find communities.  The algorithm below is great for large networks but only works with undirected graphs
c_g <- fastgreedy.community(g)

#Collapse the graph by communities.  This insight is due to this post http://stackoverflow.com/questions/35000554/collapsing-graph-by-clusters-in-igraph/35000823#35000823

res_g <- simplify(contract(g, membership(c_g))) 
The result of this process is the below figure, where the vertices' names represent community membership.

plot(g, margin = -.5)
enter image description here

The above is clearly nicer than this hideous mess

plot(r_g, margin = -.5)
enter image description here

To link communities to original vertices you will need something akin to the following

mem <- data.frame(vertices = 1:vcount(g), memeber = as.numeric(membership(c_g)))
IMO this is a nice approach for two reasons. First, it can in theory deal with any size graph. The process of finding communities can be continuously repeated on collapsed graphs. Second, adopting a interactive approach would yield very readable results. For example, one can imagine the user being able to click on a vertex in the collapsed graph to expand that community revealing all of its original vertices.

shareedit
edited Jan 26 '16 at 0:53
answered Jan 25 '16 at 20:33

Jacob H
1,817823
add a comment
up vote
1
down vote
Yet another interesting package is networkD3. There are a myriad of means of representing graphs within this library. In particular, I find the forceNetwork an interesting option. It is interactive and therefore allows you to really explore your network. It is great for EDA, but it maybe too "wiggly" for final work.

shareedit
answered Jan 22 '16 at 22:42

Jacob H
1,817823
add a comment
up vote
10
down vote
That's an interesting question, I didn't know most of the tools you listed, so thanks. You can add HivePlot to the list. It's a deterministic method consisting in projecting nodes on a fixed number of axes (usually 2 or 3). Look a the linked page, there're many visual examples.

enter image description here

It works better if you have a categorical nodal attribute in your dataset, so that you can use it to select which axis a node goes to. For instance, when studying the social network of a university: students on one axis, teachers on another and administrative staff on the third. But of course, it can also work with a discretized numerical attribute (eg. young, middle-aged and older people on their respective axes).

Then you need another attribute, and it has to be numerical (or at least ordinal) this time. It is used to determine the position of a node on its axis. You can also use some topological measure, such as degree or transitivity (clustering coefficient).

How to build a hiveplot http://www.hiveplot.net/img/hiveplot-undirected-01.png

The fact the method is deterministic is interesting, because it allows comparing different networks representing distinct (but comparable) systems. For example, you can compare two universities (provided you use the same attributes/measures to determine axes and position). It also allows describing the same network in various ways, by choosing different combinations of attributes/measures to generate the visualization. This is the recommanded way of visualizing a network, actually, thanks to a so-called hive panel.

Several softwares able of generating those hive plots are listed in the page I mentioned at the beginning of this post, including implementations in Java and R.

shareedit
edited Jun 26 '15 at 16:38
answered Mar 18 '14 at 5:29

Vincent Labatut
1,18611327
add a comment
up vote
15
down vote
Another way to visualize very large networks is with BioFabric (www.BioFabric.org), which uses horizontal lines instead of points to represent the nodes. Edges are then shown using vertical line segments. A quick D3 demo of this technique is shown at: http://www.biofabric.org/gallery/pages/SuperQuickBioFabric.html.

BioFabric is a Java application, but a simple R version is available at: https://github.com/wjrl/RBioFabric.

Here is a snippet of R code:

 # You need 'devtools':
 install.packages("devtools")
 library(devtools)

 # you need igraph:
 install.packages("igraph")
 library(igraph)

 # install and load 'RBioFabric' from GitHub
 install_github('RBioFabric',  username='wjrl')
 library(RBioFabric)

 #
 # This is the example provided in the question:
 #

 set.seed(123)
 bfGraph = barabasi.game(1000)

 # This example has 1000 nodes, just like the provided example, but it 
 # adds 6 edges in each step, making for an interesting shape; play
 # around with different values.

 # bfGraph = barabasi.game(1000, m=6, directed=FALSE)

 # Plot it up! For best results, make the PDF in the same
 # aspect ratio as the network, though a little extra height
 # covers the top labels. Given the size of the network,
 # a PDF width of 100 gives us good resolution.

 height <- vcount(bfGraph)
 width <- ecount(bfGraph)
 aspect <- height / width;
 plotWidth <- 100.0
 plotHeight <- plotWidth * (aspect * 1.2)
 pdf("myBioFabricOutput.pdf", width=plotWidth, height=plotHeight)
 bioFabric(bfGraph)
 dev.off()
Here is a shot of the BioFabric version of the data provided by the questioner, though networks created with values of m > 1 are more interesting. The inset detail shows a close-up of the upper left corner of the network; node BF4 is the highest-degree node in the network, and the default layout is a breadth-first search of the network (ignoring edge directions) starting from that node, with neighboring nodes traversed in order of decreasing node degree. Note that we can immediately see that, for example, about 60% of node BF4's neighbors are degree 1. We can also see from the strict 45-degree lower edge that this 1000-node network has 999 edges, and is therefore a tree.

BioFabric presentation of example data

Full disclosure: BioFabric is a tool that I wrote.