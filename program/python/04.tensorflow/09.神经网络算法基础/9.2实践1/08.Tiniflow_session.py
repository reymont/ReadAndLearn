
def forward_pass(sorted_nodes,debug=True):
    """
    Performs a forward pass through a list of sorted nodes.

    Arguments:

        `output_node`: A node in the graph, should be the output node (have no outgoing edges).
        `sorted_nodes`: A topologically sorted list of nodes.

    Returns the output Node's value
    """

    for n in sorted_nodes:
        if(debug==True):
            print ('\nForward node value:',n.name)
        n.forward()
        if(debug==True):
            print (n.value)

    return 

# Backward propagate, compute gradients       
def backward_pass(sorted_nodes,debug=True):
    """
    Performs a forward pass through a list of sorted nodes.

    Arguments:

        `output_node`: A node in the graph, should be the output node (have no outgoing edges).
        `sorted_nodes`: A topologically sorted list of nodes.

    Returns the output Node's value
    """

    for n in sorted_nodes[::-1]:
        if(debug==True):
            print ('\nBackward node gradients:', n.name)
            if( not n.outbound_nodes and n.endnode==False):
                print ("\n %s has not output, may not do bp correctly\n"%n.name)
        n.backward()
        if(debug==True):
            for t in n.gradients:
                print ('d.'+t.name, n.gradients[t])
    return 

# run 包含 forward 和 backward
def forward_and_backward(sorted_nodes, debug=False):
    """
    Performs a forward pass and a backward pass through a list of sorted Nodes.

    Arguments:

        `graph`: The result of calling `topological_sort`.
    """
    # Forward pass
    for n in sorted_nodes:
        if(debug==True):
            print ('\nForward node value:',n.name)
        n.forward()
        if(debug==True):
            print (n.value)

    # Backward pass
    for n in sorted_nodes[::-1]:
        if(debug==True):
            print ('\nBackward node gradients:', n.name)
            # only EndNode set endnode=True
            if( not n.outbound_nodes and n.endnode==False):
                print ("\n %s has not output, may not do bp correctly\n"%n.name)
        n.backward()
        if(debug==True):
            for t in n.gradients:
                print ('d.'+t.name, n.gradients[t])


       
####################
# Session Class
####################

        
class Session():
    def __init__(self, graph=None, name=None):
        self.value = None
        if(name==None):
            name=self.__class__.__name__
        self.name= name    
        if graph is None:
            graph = default_graph()
        else:
            default_graph(graph)
        if graph.feed_dict is None:
            graph.sort()
            print('sort graph/%s in session/%s'%(graph.name, name))
        print('add graph/%s in session/%s'%(graph.name, name))
        self.graph=graph
        
    def evaluate(self, ops):
        if not ops is None:
            if len(ops)>1:
                return [op.value for op in ops]
            elif len(ops)==1:
                return ops[0].value
        else:
            return None

    def forward(self, ops=None, debug=False):
        forward_pass(self.graph.value, debug=debug)
        if not ops is None:
            if len(ops)>1:
                return [op.value for op in ops]
            elif len(ops)==1:
                return ops[0].value
        else:
            return None
    def backward(self,ops=None, debug=False):     
        backward_pass(self.graph.value, debug=debug)
        if not ops is None:
            if len(ops)>1:
                return [[n.name, [[t.name, n.gradients[t]] for t in n.gradients]] for n in ops]
            elif len(ops)==1:
                n=ops[0]
                return [n.name, [[t.name, n.gradients[t]] for t in n.gradients]] 
        else:
            return None
                
    def optimize(self, optimizer, learning_rate=1e-2, debug=False):
        trainables=self.graph.trainables 
        optimizer(trainables,  learning_rate = learning_rate, debug = debug)
    
    # 最后结果放到 ops 中去
    def run(self, ops=None, feed_dict=None, debug=False):
        if feed_dict:
            for x in feed_dict:
                x.value = feed_dict[x]
        forward_and_backward(self.graph.value, debug=debug)
        if not ops is None:
            if len(ops)>1:
                return [op.value for op in ops]
            elif len(ops)==1:
                return ops[0].value
