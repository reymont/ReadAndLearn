import numpy as np
from typing import Optional, Tuple

import tensorflow as tf
from tensorflow.contrib import rnn

def generate_sample(f: Optional[float] = 1.0, t0: Optional[float] = None, batch_size: int = 1,
                    predict: int = 50, samples: int = 100) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """
    Generates data samples.
    :param f: The frequency to use for all time series or None to randomize.
    :param t0: The time offset to use for all time series or None to randomize.
    :param batch_size: The number of time series to generate.
    :param predict: The number of future samples to generate.
    :param samples: The number of past (and current) samples to generate.
    :return: Tuple that contains the past times and values as well as the future times and values. In all outputs,
             each row represents one time series of the batch.
    """
    Fs = 100

    T = np.empty((batch_size, samples))
    Y = np.empty((batch_size, samples))
    FT = np.empty((batch_size, predict))
    FY = np.empty((batch_size, predict))

    _t0 = t0
    for i in range(batch_size):
        t = np.arange(0, samples + predict) / Fs
        if _t0 is None:
            t0 = np.random.rand() * 2 * np.pi
        else:
            t0 = _t0 + i/float(batch_size)

        freq = f
        if freq is None:
            freq = np.random.rand() * 3.5 + 0.5

        y = np.sin(2 * np.pi * freq * (t + t0))

        T[i, :] = t[0:samples]
        Y[i, :] = y[0:samples]

        FT[i, :] = t[samples:samples + predict]
        FY[i, :] = y[samples:samples + predict]

    return T, Y, FT, FY

import matplotlib.pyplot as plt
def plot_wave(t,y,t_next,y_next):

    n_tests = t.shape[0]
    for i in range(0, n_tests):
        plt.subplot(n_tests, 1, i+1)
        plt.plot(t[i, :], y[i, :])
        plt.plot(np.append(t[i, -1], t_next[i, :]), np.append(y[i, -1], y_next[i, :]), color='red', linestyle=':')

    plt.xlabel('time [t]')
    plt.ylabel('signal')
    plt.show()

t, y, t_next, y_next = generate_sample(f=None, t0=None, batch_size=3, predict=50, samples=25)
plot_wave(t, y, t_next, y_next)


def RNN(x, weights, biases, n_input, n_steps, n_hidden):

    # Prepare data shape to match `rnn` function requirements
    # Current data input shape: (batch_size, n_steps, n_input)
    # Required shape: 'n_steps' tensors list of shape (batch_size, n_input)

    # Permuting batch_size and n_steps
    x = tf.transpose(x, [1, 0, 2])
    # Reshaping to (n_steps*batch_size, n_input)
    x = tf.reshape(x, [-1, n_input])
    # Split to get a list of 'n_steps' tensors of shape (batch_size, n_input)
    # x: [n_steps, batch_size, n_input]
    x = tf.split(x, n_steps, axis=0)

    # Define a lstm cell with tensorflow
    lstm_cell = tf.nn.rnn_cell.BasicRNNCell(n_hidden)

    # Get lstm cell output
    
    outputs, states = rnn.static_rnn(lstm_cell, x, dtype=tf.float32)

    """
    static_rnn(cell, inputs):
        state = cell.zero_state(...)
        outputs = []
        for input_ in inputs:
            output, state = cell(input_, state)
            outputs.append(output)
        return (outputs, state)
    """

    # Linear activation, using rnn inner loop last output
    # Note: use the last step in outputs
    return tf.nn.bias_add(tf.matmul(outputs[-1], weights['out']), biases['out'])

tf.reset_default_graph()
# Parameters
learning_rate = 0.005
training_iters = 5000
batch_size = 100
display_step = 100

# Network Parameters
# 
n_input = 1  # input is sin(x)
n_steps = 25  # timesteps
n_hidden = 150  # hidden layer num of features
n_outputs = 50  # output is sin(x+1)

# tf Graph input
x = tf.placeholder("float", [None, n_steps, n_input])
y = tf.placeholder("float", [None, n_outputs])

# Define weights
weights = {
    'out': tf.Variable(tf.random_normal([n_hidden, n_outputs]))
}
biases = {
    'out': tf.Variable(tf.random_normal([n_outputs]))
}

pred = RNN(x, weights, biases, n_input, n_steps, n_hidden)

# Define loss (Euclidean distance) and optimizer
individual_losses = tf.reduce_sum(tf.squared_difference(pred, y), reduction_indices=1)
loss = tf.reduce_mean(individual_losses)
optimizer = tf.train.AdamOptimizer(learning_rate=learning_rate).minimize(loss)

# Initializing the variables
init = tf.global_variables_initializer()

# Launch the graph
with tf.Session() as sess:
    sess.run(init)
    step = 1
    # Keep training until reach max iterations
    while step < training_iters:
        _, batch_x, __, batch_y = generate_sample(f=None, t0=None, batch_size=batch_size, samples=n_steps,
                                                  predict=n_outputs)

        batch_x = batch_x.reshape((batch_size, n_steps, n_input))
        batch_y = batch_y.reshape((batch_size, n_outputs))

        # Run optimization op (backprop)
        sess.run(optimizer, feed_dict={x: batch_x, y: batch_y})
        if step % display_step == 0:
            # Calculate batch loss
            loss_value = sess.run(loss, feed_dict={x: batch_x, y: batch_y})
            print("Iter " + str(step) + ", Minibatch Loss= " +
                  "{:.6f}".format(loss_value))
        step += 1
    print("Optimization Finished!")

    # Test the prediction
    n_tests = 3
    for i in range(1, n_tests + 1):
        plt.subplot(n_tests, 1, i)
        t, y, next_t, expected_y = generate_sample(f=i, t0=None, samples=n_steps, predict=n_outputs)

        test_input = y.reshape((1, n_steps, n_input))
        prediction = sess.run(pred, feed_dict={x: test_input})

        # remove the batch size dimensions
        t = t.squeeze()
        y = y.squeeze()
        next_t = next_t.squeeze()
        prediction = prediction.squeeze()

        plt.plot(t, y, color='black')
        plt.plot(np.append(t[-1], next_t), np.append(y[-1], expected_y), color='green', linestyle=':')
        plt.plot(np.append(t[-1], next_t), np.append(y[-1], prediction), color='red')
        plt.ylim([-1, 1])
        plt.xlabel('time [t]')
        plt.ylabel('signal')

    plt.show()