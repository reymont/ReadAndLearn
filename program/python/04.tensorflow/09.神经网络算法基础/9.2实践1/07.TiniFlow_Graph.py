

### 1. Graph Class

import numpy as np
#from scipy import signal
#from scipy import misc
from functools import reduce

global default_graph_obj

def default_graph(graph=None):
    global default_graph_obj
    if graph is None:
        graph=default_graph_obj
    else:
        default_graph_obj = graph
    return graph

def reset_graph(feed_dict=None, graph=None):
    #rt node id
    if graph is None:
        graph=default_graph()
    graph.init_node()
    graph.out_dict={}
    graph.float_dict={}
    graph.in_dict={}
        
    nodes = graph.node_list

    # Remove nodes in a graph 
    while len(nodes) > 0:
        n = nodes.pop(0)
        for m in n.outbound_nodes:
            nodes.append(m)
        n.outbound_nodes=[]
        #print("all outbound nodes removed from %s"%n.name)
        for m in n.inbound_nodes:
            nodes.append(m)
        n.inbound_nodes=[]

def reset_default_graph():
    reset_graph(graph=default_graph())
 

####################
# Graph Class
####################
class Graph():
    # Graph node sorting function
    # Activate on Vertex Network sorting )(AOV topology algorithm)
    # This algorithm works for a undirectoinal network without circle 
    # 1. Select one input with input degree as 0 (no input), put into output list.
    # 2. Remove this node and the connection with it;
    # 3. Repeat 1,2 until all points are in the output list.
    # The two routines are done in forward and reverse way.
    # INput class shall be defined before this function is called
    # Graph 排序
    def forward_sort(self, feed_dict=None):
        """
        Sort the nodes in topological order using AOV Algorithm.

        `feed_dict`: A dictionary where the key is a `Input` Tensor.

        Returns a list of sorted nodes.
        """
        if feed_dict is None:
            feed_dict = in_dict


        input_nodes = [n for n in feed_dict.keys()]

        # Build a graph starting from all the input nodes
        # 目标是把图 G 转化成线性列表 L
        G = {}
        nodes = [n for n in input_nodes]
        # nodes will be updated dynamicly!
        while len(nodes) > 0:
            n = nodes.pop(0)
            if n not in G:
                G[n] = {'in': set(), 'out': set()}
            for m in n.outbound_nodes:
                if m not in G:
                    G[m] = {'in': set(), 'out': set()}
                G[n]['out'].add(m)
                G[m]['in'].add(n)
                nodes.append(m)

        # 结果存放地点
        L = []
        S = set(input_nodes)
        while len(S) > 0:
            n = S.pop()

            if isinstance(n, Input):
                n.value = feed_dict[n]

            L.append(n)
            for m in n.outbound_nodes:
                G[n]['out'].remove(m)
                G[m]['in'].remove(n)
                # if no other incoming edges add to S
                if len(G[m]['in']) == 0:
                    S.add(m)
        return L
    
    # feed_dict 是 Output List
    def backward_sort(self, feed_dict=None):
        """
        Sort the nodes in topological order using AOV Algorithm.

        `feed_dict`: A dictionary where the key is a `Output` Tensor.

        Returns a list of sorted nodes.
        """

        if feed_dict is None:
            feed_dict = out_dict
        output_nodes = [n for n in feed_dict.keys()]

        # Build a graph starting from all the input nodes
        G = {}
        nodes = [n for n in output_nodes]
        # nodes will be updated dynamicly!
        while len(nodes) > 0:
            n = nodes.pop(0)
            if n not in G:
                G[n] = {'in': set(), 'out': set()}
            for m in n.inbound_nodes:
                if m not in G:
                    G[m] = {'in': set(), 'out': set()}
                G[n]['in'].add(m)
                G[m]['out'].add(n)
                nodes.append(m)

        L = []
        S = set(output_nodes)
        while len(S) > 0:
            n = S.pop()

            L.append(n)
            for m in n.inbound_nodes:
                G[n]['in'].remove(m)
                G[m]['out'].remove(n)
                # if no other incoming edges add to S
                if len(G[m]['out']) == 0:
                    S.add(m)
        # 出输序逆，反向排序过程，例如 n = 12345，str(n)[::-1]，输出54321，[::1]中省略起止位置，步进为-1
        # python中步进为正，从左往右取，步进为负，从右往左取
        # str(n)[::-1]实现字符串翻转
        L=L[::-1] 
        return L

    def sort(self):
        """
        Sort the nodes in topological order using AOV Algorithm.

        `feed_dict`: A dictionary where the key is a `Output` Tensor.

        Returns a list of sorted nodes.
        """


        nodes = self.node_list

        nodes = [n for n in nodes]
        # nodes will be updated dynamicly!
        while len(nodes) > 0:
            n = nodes.pop(0)
            out_degree=len(n.outbound_nodes)
            in_degree=len(n.inbound_nodes)
            if out_degree==0 and in_degree>0:
                self.out_dict[n]=n.value
            if in_degree==0 and out_degree>0:
                self.in_dict[n]=n.value
            if in_degree==0 and out_degree==0:
                self.float_dict[n]=n.value
        out_graph = self.backward_sort(self.out_dict)
        in_graph = self.backward_sort(self.in_dict)
        unused_nodes = list(set(in_graph)-set(out_graph))
        graph = out_graph
        self.trainables=[x for x in out_graph if x.trainable==True]
        print("graph/%s:"%self.name, "node List:", [x.name for x in graph])
        print("Trainable nodes:", [x.name for x in self.trainables])
        print('unused nodes:', unused_nodes)
        self.value = out_graph
        
    def nodes(self):        
        return [x.name for x in self.value]         

    def init_node(self):
        self.node_list=[]
        self.node_id=0
        return 
    
    def __init__(self, feed_dict=None, inputs=True, name=None):
        if name is None:
            name='Graph'
        self.name=name
        self.value=None
        self.init_node()
        self.out_dict={}
        self.float_dict={}
        self.in_dict={}
        self.feed_dict=feed_dict
        default_graph(self)
        print('init graph/%s'%name)
        if feed_dict is None:
            pass
        else:
            if inputs:
                graph = self.forward_sort(feed_dict)
            else: 
                graph = self.backward_sort(feed_dict)
            self.value=graph
            self.trainables=[x for x in graph if x.trainable==True]
            print("graph/%s:"%self.name, "node List:", [x.name for x in graph])
            print("Trainable nodes:", [x.name for x in self.trainables])

   

               