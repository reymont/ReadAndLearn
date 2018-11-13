

jenkins2 pipeline插件的10个最佳实践 - iTech - 博客园 https://www.cnblogs.com/itech/p/5678643.html

5. 尽可能地使用parallel来使得任务并行地执行

将任务并行后，使得整个job的流程更够更快地完成，开发人员能够更早地得到结果。

parallel 'shifting':{
    //everything
}, 'left':{
    //I can
}

对于unit的并行执行，可以查看插件Parallel Test Executor plugin，更多详细介绍查看Parallel Test Execution on the CloudBees Blog。

 

6. 并行的任务运行在不同的node上

对于并行的任务使用不同的node，使得并行的任务不相互影响，能够实现真正的并行执行。

parallel 'integration-tests':{
    node('mvn-3.3'){ ... }
}, 'functional-tests':{
    node('selenium'){ ... }
}

 