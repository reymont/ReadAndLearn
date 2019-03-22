class Node:
    """
    Base class for nodes in the network.

    Arguments:

        `inbound_nodes`: A list of nodes with edges into this node.
    """
    def assign_node(self):
        
        default_graph().node_id+=1
        # 创建一个node的时候会把当前的node放在缺省的node_list中
        default_graph().node_list.append(self)
        
        return default_graph().node_id
    def __init__(self, inbound_nodes=[], name=None):
        """
        Node's constructor (runs when the object is instantiated). Sets
        properties that all nodes need.
        """
        # A list of nodes with edges into this node.
        self.inbound_nodes = inbound_nodes
        # The eventual value of this node. Set by running
        # the forward() method.
        self.value = None
        self.trainable = False
        current_node_id=self.assign_node()
        if(name==None):
            name=self.__class__.__name__+'%d'%current_node_id
        self.name= name
        
        # A list of nodes that this node outputs to.
        self.outbound_nodes = []
        self.endnode=False
        # New property! Keys are the inputs to this node and
        # their values are the partials of this node with
        # respect to that input.
        self.gradients = {}
        # Sets this node as an outbound node for all of
        # this node's inputs.
        # cda/图21.inbound_outbound_nodes.png
        for node in inbound_nodes:
            node.outbound_nodes.append(self)
        
    def forward(self):
        """
        Every node that uses this class as a base class will
        need to define its own `forward` method.
        """
        raise NotImplementedError

    def backward(self):
        """
        Every node that uses this class as a base class will
        need to define its own `backward` method.
        """
        raise NotImplementedError

# Tensor 继承 Node
class Tensor(Node):
    """
    Base class for Tensor in the network.

    Arguments:

        `inbound_nodes`: A list of nodes with edges into this node.
    """
    def __init__(self, init_value=None, name=None):
        Node.__init__(self,name=name)
        if not init_value is None:
            self.value=init_value

    def forward(self):
        """
        Every node that uses this class as a base class will
        need to define its own `forward` method.
        """
        raise NotImplementedError

    def backward(self):
        """
        Every node that uses this class as a base class will
        need to define its own `backward` method.
        """
        raise NotImplementedError

# Operation 继承 Node
class Operation(Node):
    """
    Base class for Operation in the network.

    Arguments:

        `inbound_nodes`: A list of nodes with edges into this node.
    """
    def __init__(self, inbound_nodes=[], name=None):
        Node.__init__(self,inbound_nodes,name=name)
        for m in self.inbound_nodes:
            self.gradients[m] = 0.

    def forward(self):
        """
        Every node that uses this class as a base class will
        need to define its own `forward` method.
        """
        raise NotImplementedError

    def backward(self):
        """
        Every node that uses this class as a base class will
        need to define its own `backward` method.
        """
        raise NotImplementedError

        
# Input 继承 Tensor 继承 Node
class Input(Tensor):
    """
    Base class for Input in the network.
    """
    def __init__(self,name=None,trainable=False):
        # The base class constructor has to run to set all
        # the properties here.
        #
        # The most important property on an Input is value.
        # self.value is set during sort later.
        Tensor.__init__(self,name=name)
        self.trainable = trainable
        
    def forward(self):
        return self.value

    def backward(self):
        # An Input node has no inputs so the gradient (derivative)
        # is zero.
        # The key, `self`, is reference to this object.
        self.gradients = {self: 0}
        # Weights and bias may be inputs, so you need to sum
        # the gradient from output gradients.
        for n in self.outbound_nodes:
            self.gradients[self] += n.gradients[self]

#Output 继承 Tensor 继承 Node
class Output(Tensor):
    def __init__(self, *inputs, cost=0., name=None):
        self.cost=cost
        Tensor.__init__(self,inputs,name=name)
    def forward(self):
        self.value=self.inbound_nodes[0].value
        return self.value
    def backward(self):
        self.gradients[self.inbound_nodes[0]]=self.cost


# Variable 继承 Tensor 继承 Node
class Variable(Tensor):
    """
    Base class for Variable in the network.
    """
    def __init__(self,init_value=None, name=None, trainable=True):
        # The base class constructor has to run to set all
        # the properties here.
        #
        # The most important property on an Input is value.
        # self.value is set during `topological_sort` later.
        Tensor.__init__(self,init_value,name=name)
        self.trainable = False
    def forward(self):
        # Do nothing because nothing is calculated.
        return self.value

    def backward(self):
        # An Input node has no inputs so the gradient (derivative)
        # is zero.
        # The key, `self`, is reference to this object.
        self.gradients = {self: 0}
        # Weights and bias may be inputs, so you need to sum
        # the gradient from output gradients.
        for n in self.outbound_nodes:
            self.gradients[self] += n.gradients[self]