# Variable 继承 Operation 继承 Node
# Operation在 09.Tiniflow_tensor.py 中定义
class Add(Operation):
    def __init__(self, *inputs, name=None):
        Operation.__init__(self, inputs, name)
    def forward(self):
        """
        support more than 2 inputs
        Add(x0,x1,x2,...)
        """
        li=map(lambda x:x.value, self.inbound_nodes)
        self.value=np.array(reduce(lambda x,y:x+y, li))
        #print(self.value)
    def backward(self):
        """
        Calculates the gradient of the cost.
        """
       # Initialize the gradients to 0.
        self.gradients = {n: np.zeros_like(n.value) for n in self.inbound_nodes}
        # Sum the partial with respect to the input over all the outputs.
        for m in self.inbound_nodes:
            for n in self.outbound_nodes:
                grad_cost = n.gradients[self]
                self.gradients[m] += grad_cost



class Linear(Operation):
    """
    Represents a node that performs a linear transform.
    """
    def __init__(self, X, W, b,name=None):
        Operation.__init__(self, [X, W, b],name=name)

    def forward(self):
        """
        Performs the math behind a linear transform.
        """
        X = self.inbound_nodes[0].value
        W = self.inbound_nodes[1].value
        b = self.inbound_nodes[2].value
        self.value = np.dot(X, W) + b

            
    def backward(self):
        """
        Calculates the gradient based on the output values.
        """
        # Initialize a partial for each of the inbound_nodes.
        self.gradients = {n: np.zeros_like(n.value) for n in self.inbound_nodes}
        # Cycle through the outputs. The gradient will change depending
        # on each output, so the gradients are summed over all outputs.
        for n in self.outbound_nodes:
            # Get the partial of the cost with respect to this node.
            grad_cost = n.gradients[self]
            # Set the partial of the loss with respect to this node's inputs.
            self.gradients[self.inbound_nodes[0]] += np.dot(grad_cost, self.inbound_nodes[1].value.T)
            # Set the partial of the loss with respect to this node's weights.
            self.gradients[self.inbound_nodes[1]] += np.dot(self.inbound_nodes[0].value.T, grad_cost)
            # Set the partial of the loss with respect to this node's bias.
            self.gradients[self.inbound_nodes[2]] += np.sum(grad_cost, axis=0, keepdims=False)

