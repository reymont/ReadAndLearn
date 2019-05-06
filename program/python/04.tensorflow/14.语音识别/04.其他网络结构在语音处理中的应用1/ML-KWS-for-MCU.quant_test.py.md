(1条消息)ML-KWS-for-MCU:quant_test.py - xj853663557的博客 - CSDN博客 https://blog.csdn.net/xj853663557/article/details/83688464

目录

简介

初始化

Quantize weights

Quantize activation data

1.training set

3.test set

参考资料

https://github.com/ARM-software/ML-KWS-for-MCU/blob/master/quant_test.py

简介
训练好的模型是浮点型，该脚本把浮点转换为8位定点，旨在减小mcu运算和memory资源。

首先看下main函数

def main(_):
 
  # Create the model, load weights from checkpoint and run on train/val/test
  run_quant_inference(FLAGS.wanted_words, FLAGS.sample_rate,
      FLAGS.clip_duration_ms, FLAGS.window_size_ms,
      FLAGS.window_stride_ms, FLAGS.dct_coefficient_count,
      FLAGS.model_architecture, FLAGS.model_size_info)
调用了run_quant_inference函数，并传递了一些参数。

def run_quant_inference(wanted_words, sample_rate, clip_duration_ms,
                           window_size_ms, window_stride_ms, dct_coefficient_count, 
                           model_architecture, model_size_info):
  """Creates an audio model with the nodes needed for inference.
  Uses the supplied arguments to create a model, and inserts the input and
  output nodes that are needed to use the graph for inference.
  Args:
    wanted_words: Comma-separated list of the words we're trying to recognize.
    sample_rate: How many samples per second are in the input audio files.
    clip_duration_ms: How many samples to analyze for the audio pattern.
    window_size_ms: Time slice duration to estimate frequencies from.
    window_stride_ms: How far apart time slices should be.
    dct_coefficient_count: Number of frequency bands to analyze.
    model_architecture: Name of the kind of model to generate.
    model_size_info: Model dimensions : different lengths for different models
  """
run_quant_inference函数主要作用就是根据提供的参数基于nodes创建一个audio model用于推理。

要想理解这个脚本的运行，首先需理解TensorFlow的运行机制，根据TensorFlow运行把这个脚本分为三个步骤：

1.初始化，包括对输入参数的预处理、为graph用到的变量创建占位符、为graph添加op。

2.Quantize weights，把weights由浮点型转化为8 bit定点，并保存到一个weights.h文件里。

3.Quantize activation data，除了对各个layer的输入和输出进行量化之外，还使用量化后的weights进行一遍train,validation,test操作。

初始化
。。。

Quantize weights
  f = open('weights.h','wb')
  f.close()
 
  for v in tf.trainable_variables():
    var_name = str(v.name)
    var_values = sess.run(v)
    min_value = var_values.min()
    max_value = var_values.max()
    int_bits = int(np.ceil(np.log2(max(abs(min_value),abs(max_value)))))
    dec_bits = 7-int_bits
    # convert to [-128,128) or int8
    var_values = np.round(var_values*2**dec_bits)
    var_name = var_name.replace('/','_')
    var_name = var_name.replace(':','_')
    with open('weights.h','a') as f:
      f.write('#define '+var_name+' {')
    if(len(var_values.shape)>2): #convolution layer weights
      transposed_wts = np.transpose(var_values,(3,0,1,2))
    else: #fully connected layer weights or biases of any layer
      transposed_wts = np.transpose(var_values)
    with open('weights.h','a') as f:
      transposed_wts.tofile(f,sep=", ",format="%d")
      f.write('}\n')
    # convert back original range but quantized to 8-bits or 256 levels
    var_values = var_values/(2**dec_bits)
    # update the weights in tensorflow graph for quantizing the activations
    var_values = sess.run(tf.assign(v,var_values))
    print(var_name+' number of wts/bias: '+str(var_values.shape)+\
            ' dec bits: '+str(dec_bits)+\
            ' max: ('+str(var_values.max())+','+str(max_value)+')'+\
            ' min: ('+str(var_values.min())+','+str(min_value)+')')
Quantize activation data
1.training set
  set_size = audio_processor.set_size('training')
  tf.logging.info('set_size=%d', set_size)
  total_accuracy = 0
  total_conf_matrix = None
  for i in xrange(0, set_size, FLAGS.batch_size):
    training_fingerprints, training_ground_truth = (
        audio_processor.get_data(FLAGS.batch_size, i, model_settings, 0.0,
                                 0.0, 0, 'training', sess))
    training_accuracy, conf_matrix = sess.run(
        [evaluation_step, confusion_matrix],
        feed_dict={
            fingerprint_input: training_fingerprints,
            ground_truth_input: training_ground_truth,
        })
    batch_size = min(FLAGS.batch_size, set_size - i)
    total_accuracy += (training_accuracy * batch_size) / set_size
    if total_conf_matrix is None:
      total_conf_matrix = conf_matrix
    else:
      total_conf_matrix += conf_matrix
  tf.logging.info('Confusion Matrix:\n %s' % (total_conf_matrix))
  tf.logging.info('Training accuracy = %.2f%% (N=%d)' %
                  (total_accuracy * 100, set_size))
2.validation set

  set_size = audio_processor.set_size('validation')
  tf.logging.info('set_size=%d', set_size)
  total_accuracy = 0
  total_conf_matrix = None
  for i in xrange(0, set_size, FLAGS.batch_size):
    validation_fingerprints, validation_ground_truth = (
        audio_processor.get_data(FLAGS.batch_size, i, model_settings, 0.0,
                                 0.0, 0, 'validation', sess))
    validation_accuracy, conf_matrix = sess.run(
        [evaluation_step, confusion_matrix],
        feed_dict={
            fingerprint_input: validation_fingerprints,
            ground_truth_input: validation_ground_truth,
        })
    batch_size = min(FLAGS.batch_size, set_size - i)
    total_accuracy += (validation_accuracy * batch_size) / set_size
    if total_conf_matrix is None:
      total_conf_matrix = conf_matrix
    else:
      total_conf_matrix += conf_matrix
  tf.logging.info('Confusion Matrix:\n %s' % (total_conf_matrix))
  tf.logging.info('Validation accuracy = %.2f%% (N=%d)' %
                  (total_accuracy * 100, set_size))
3.test set
  set_size = audio_processor.set_size('testing')
  tf.logging.info('set_size=%d', set_size)
  total_accuracy = 0
  total_conf_matrix = None
  for i in xrange(0, set_size, FLAGS.batch_size):
    test_fingerprints, test_ground_truth = audio_processor.get_data(
        FLAGS.batch_size, i, model_settings, 0.0, 0.0, 0, 'testing', sess)
    test_accuracy, conf_matrix = sess.run(
        [evaluation_step, confusion_matrix],
        feed_dict={
            fingerprint_input: test_fingerprints,
            ground_truth_input: test_ground_truth,
        })
    batch_size = min(FLAGS.batch_size, set_size - i)
    total_accuracy += (test_accuracy * batch_size) / set_size
    if total_conf_matrix is None:
      total_conf_matrix = conf_matrix
    else:
      total_conf_matrix += conf_matrix
  tf.logging.info('Confusion Matrix:\n %s' % (total_conf_matrix))
  tf.logging.info('Test accuracy = %.2f%% (N=%d)' % (total_accuracy * 100,
                                                           set_size))
--------------------- 
作者：言午三吉 
来源：CSDN 
原文：https://blog.csdn.net/xj853663557/article/details/83688464 
版权声明：本文为博主原创文章，转载请附上博文链接！