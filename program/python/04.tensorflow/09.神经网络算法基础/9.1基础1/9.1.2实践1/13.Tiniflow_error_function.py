# Reference
# https://deepnotes.io/softmax-crossentropy
class CrossEntropy(Operation):
    def __init__(self, *inputs,name=None):
        Operation.__init__(self,inputs,name=name)

    def forward(self):
        """
        """
        x = self.inbound_nodes[0].value
        label = self.inbound_nodes[1].value
        label = np.reshape(label, -1)
        #softmax_data = np.exp(x) / np.sum(np.exp(x), axis=1, keepdims=True)
        #A better way to avoid overflow
        exps=np.exp(x - np.max(x))
        softmax_data = exps/np.sum(exps, axis=1, keepdims=True)
        num_sample=softmax_data.shape[0]
        log_prob = -np.log(softmax_data)
        pred = np.argmax(softmax_data, axis=1)
        self.softmax_data =softmax_data
        self.accuracy = np.mean(pred==label)
        
        one_hot_data = np.zeros_like(x)
        one_hot_data[range(num_sample),label]=1.0
        self.one_hot_data = one_hot_data
        
        #cross_entropy_value = np.sum(log_prob*one_hot_data,axis=1)
        #identical to above 3 lines
        cross_entropy_value = log_prob[range(num_sample),label]
        loss=np.mean(cross_entropy_value, axis=0)
        self.loss=loss
        self.pred=pred
        #for pr in (x,label,softmax_data,log_prob,cross_entropy_value, loss):
        #    print (pr.shape, pr)
        self.value=loss
        
    def backward(self):
        #dloss/dlogits=(softmax_data-1.0/0.0)
        """Compute softmax values for each sets of scores in x."""
        softmax_data=self.softmax_data
        num_sample=softmax_data.shape[0]
        label=self.inbound_nodes[1].value
        label=np.reshape(label, -1)
        probs=np.copy(softmax_data)
        #MxK
        probs[range(num_sample),label]-=1.0
        #identical to below three lines
        #one_hot_label=np.zeros_like(softmax_data)
        #one_hot_label[range(num_sample),label]=1.0
        #probs-=one_hot_label
        
        probs/= num_sample
        self.probs=probs
        self.gradients[self.inbound_nodes[0]] = probs     
        self.gradients[self.inbound_nodes[1]] = 0     
        
class L2_Loss(Operation):
    def __init__(self, *x, alpha=1e-2, name=None):
        """
        The mean squared error cost function.
        Should be used as the last node for a network.
        """
        Operation.__init__(self, x, name=name)
        self.alpha=alpha
        
    def forward(self):
        """
        Calculates the mean squared error.
        """
        x_value=np.array(list(map(lambda x:x.value, self.inbound_nodes)))
        #print(x_value)
        mse = [0.5 * self.alpha * np.sum(y*y) for y in x_value]
        number = np.sum([y.reshape(-1).shape[0] for y in x_value])
        self.number = number
        self.value = np.sum(mse)*1.0/self.number

    def backward(self):
        """
        Calculates the gradient of the cost.
        """
        for i in self.inbound_nodes:
            self.gradients[i] = self.alpha * i.value


class MSE(Operation):
    def __init__(self, y, a, name=None):
        """
        The mean squared error cost function.
        Should be used as the last node for a network.
        """
        Operation.__init__(self, [y, a], name=name)

    def forward(self):
        """
        Calculates the mean squared error.
        """
        y = self.inbound_nodes[0].value
        a = self.inbound_nodes[1].value

        self.m = self.inbound_nodes[0].value.shape[0]
        # Save the computed output for backward.
        self.diff = y - a
        self.value = np.mean(self.diff**2)

    def backward(self):
        """
        Calculates the gradient of the cost.
        """
        self.gradients[self.inbound_nodes[0]] = 2./self.m * self.diff
        self.gradients[self.inbound_nodes[1]] = -2./self.m * self.diff

