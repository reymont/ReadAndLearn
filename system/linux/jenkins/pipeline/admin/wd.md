

Pipeline: Nodes and Processes 
https://jenkins.io/doc/pipeline/steps/workflow-durable-task-step/#pipeline-nodes-and-processes

ws: Allocate workspace
Allocates a workspace. Note that a workspace is automatically allocated for you with the node step.
dir
A workspace is automatically allocated for you with the node step, or you can get an alternate workspace with this ws step, but by default the location is chosen automatically. (Something like SLAVE_ROOT/workspace/JOB_NAME@2.)

You can instead specify a path here and that workspace will be locked instead. (The path may be relative to the slave root, or absolute.)

If concurrent builds ask for the same workspace, a directory with a suffix such as @2 may be locked instead. Currently there is no option to wait to lock the exact directory requested; if you need to enforce that behavior, you can either fail (error) when pwd indicates that you got a different directory, or you may enforce serial execution of this part of the build by some other means such as stage name: '…', concurrency: 1.

If you do not care about locking, just use the dir step to change current directory.

Type: String