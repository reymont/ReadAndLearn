class Sigmoid(Operation):
    """
    Represents a node that performs the sigmoid activation function.
    """
    def __init__(self, node, name=None):
        # The base class constructor.
        Operation.__init__(self, [node], name=name)

    def _sigmoid(self, x):
        """
        `x`: A numpy array-like object.
        """
        return 1. / (1. + np.exp(-1.*x))

    def forward(self):
        """
        Perform the sigmoid function and set the value.
        """
        input_value = self.inbound_nodes[0].value
        self.value = self._sigmoid(input_value)

    def backward(self):
        """
        Calculates the gradient using the derivative of
        the sigmoid function.
        """
        # Initialize the gradients to 0.
        self.gradients = {n: np.zeros_like(n.value) for n in self.inbound_nodes}
        # Sum the partial with respect to the input over all the outputs.
        for n in self.outbound_nodes:
            grad_cost = n.gradients[self]
            sigmoid = self.value
            self.gradients[self.inbound_nodes[0]] += sigmoid * (1 - sigmoid) * grad_cost

class Tanh(Operation):
    """
    Represents a node that performs the Tanh activation function.
    """
    def __init__(self, node, name=None):
        Operation.__init__(self, [node], name=name)

    def _tanh(self, x):
        """
        `x`: A numpy array-like object.
        """
        return 2. / (1. + np.exp(-2.*x)) - 1.
        #return np.tanh(x)

    def forward(self):
        """
        Perform the sigmoid function and set the value.
        """
        input_value = self.inbound_nodes[0].value
        self.value = self._tanh(input_value)

    def backward(self):
        """
        Calculates the gradient using the derivative of
        the Tanh function.
        """
        # Initialize the gradients to 0.
        self.gradients = {n: np.zeros_like(n.value) for n in self.inbound_nodes}
        # Sum the partial with respect to the input over all the outputs.
        for n in self.outbound_nodes:
            grad_cost = n.gradients[self]
            tanh = self.value
            self.gradients[self.inbound_nodes[0]] += (1 - tanh * tanh) * grad_cost

class RELU (Operation):
    def __init__(self, input, name=None):
        Operation.__init__(self, [input], name=name)
    def forward(self):
        y = self.inbound_nodes[0].value
        a = np.maximum(0.0, y)
        self.value=a
    def backward(self):
        y = self.inbound_nodes[0].value
        a = np.zeros_like(y)
        a[y>0.] = 1.0
        grad_cost=self.outbound_nodes[0].gradients[self]
        self.gradients[self.inbound_nodes[0]] = a * grad_cost
        