class Optimizer():
    def __init__(self, name=None):
        self.learning_rate=1e-2
        pass
    def print_info(self, t):
        if(self.__class__.__name__=='AdamOptimizer'):
            print("\nt,m,v, lr:", t.t,t.m,t.v, t.lr)
        print("\n%s: value:%f, gradient:%f"%(t.name, t.value.reshape(-1)[0], t.gradients[t].reshape(-1)[0]))
        print("\n")
        
    
#DG algorithm
class GradientDescentOptimizer(Optimizer):
    def minimize(self, trainables, learning_rate=1e-2, debug=False):
        """
        Updates the value of each trainable with SGD.

        Arguments:

            `trainables`: A list of `Input` Nodes representing weights/biases.
            `learning_rate`: The learning rate.
        """
        self.learning_rate=learning_rate
        if debug:
            print("%s,learning_rate=%f"%(self.__class__.__name__,self.learning_rate))
        for t in trainables:
            # Change the trainable's value by subtracting the learning rate
            # multiplied by the partial of the cost with respect to this
            # trainable.
            if debug:
                print("\nBefore update:")
                self.print_info(t)
            partial = t.gradients[t]
            t.value -= learning_rate * partial
            if debug:
                print("After update:")
                self.print_info(t)
    def __init__(self, name=None):
        Optimizer.__init__(self,name=name)

#ADAM
class AdamOptimizer(Optimizer):
    def adam_init(self, trainables):
        for t in trainables:
            t.t=0
            t.m=0 #first momentum 
            t.v=0 #second momentum
            t.lr=1e-1
        return
    #1e-8->1e-1
    def minimize(self, trainables, learning_rate=1e-1, beta1=0.9, beta2=0.999, epsilon=1e-1, debug=False):
        self.learning_rate=learning_rate
        if debug:
            print("%s,learning_rate=%f"%(self.__class__.__name__,self.learning_rate))
        for t in trainables:
            if debug:
                print("\nBefore update:")
                self.print_info(t)
            partial = t.gradients[t]
            t.t=t.t+1
            t.lr=learning_rate * np.sqrt(1-np.power(beta2,t.t))/(1-np.power(beta1, t.t))
            t.m=beta1*t.m+(1-beta1)*partial
            t.v=beta2*t.v+(1-beta2)*partial*partial
            t.value-=t.lr*t.m/(np.sqrt(t.v)+epsilon)
            if debug:
                print("After update:")
                self.print_info(t)
        return
    def __init__(self, inputs,name=None):
        self.adam_init(inputs)
        Optimizer.__init__(self,name=name)

#ADAGRAD algorithm
class AdagradOptimizer(Optimizer):
    def adagrad_init(self, trainables):
        for t in trainables:
            #print(t.name,t.value.shape)
            t.mem=np.zeros(t.value.shape)

    def minimize(self, trainables, learning_rate=1e-1, debug=False):
        """
        Updates the value of each trainable with SGD.

        Arguments:
            `trainables`: A list of `Input` Nodes representing weights/biases.
            `learning_rate`: The learning rate.
        """
        self.learning_rate=learning_rate
        if debug:
            print("%s,learning_rate=%f"%(self.__class__.__name__,self.learning_rate))
        for t in trainables:
            # Change the trainable's value by subtracting the learning rate
            # multiplied by the partial of the cost with respect to this
            # trainable.
            if debug:
                print("\nBefore update:")
                self.print_info(t)
            partial = t.gradients[t]
            np.clip(partial, -5,5,out=partial)
            t.mem+=partial*partial
            t.value -= learning_rate * partial/np.sqrt(t.mem+1e-8)
            if debug:
                print("\nAfter update:")
                self.print_info(t)
        return 
    def __init__(self, inputs, name=None):
        self.adagrad_init(inputs)
        Optimizer.__init__(self,name=name)
