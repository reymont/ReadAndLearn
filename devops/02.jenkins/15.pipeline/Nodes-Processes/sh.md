

https://jenkins.io/doc/pipeline/steps/workflow-durable-task-step/#-sh- shell script

sh: Shell Script
script
Runs a Bourne shell script, typically on a Unix node. Multiple lines are accepted.

An interpreter selector may be used, for example: #!/usr/bin/perl

Otherwise the system default shell will be run, using the -xe flags (you can specify set +e and/or set +x to disable those).

Type: String
encoding (optional)
Encoding of standard output, if it is being captured.
Type: String
returnStatus (optional)
Normally, a script which exits with a nonzero status code will cause the step to fail with an exception. If this option is checked, the return value of the step will instead be the status code. You may then compare it to zero, for example.
Type: boolean
returnStdout (optional)
If checked, standard output from the task is returned as the step value as a String, rather than being printed to the build log. (Standard error, if any, will still be printed to the log.) You will often want to call .trim() on the result to strip off a trailing newline.
Type: boolean