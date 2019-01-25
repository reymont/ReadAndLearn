// http://crosbymichael.com/creating-containers-part-1.html

#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <sched.h>
#include <sys/wait.h>
#include <errno.h>

#define STACKSIZE (1024*1024)
static char child_stack[STACKSIZE];

struct clone_args {
        char **argv;
};

// child_exec is the func that will be executed as the result of clone
static int child_exec(void *stuff)
{
        struct clone_args *args = (struct clone_args *)stuff;
        if (execvp(args->argv[0], args->argv) != 0) {
                fprintf(stderr, "failed to execvp argments %s\n",
                        strerror(errno));
                exit(-1);
        }
        // we should never reach here!
        exit(EXIT_FAILURE);
}

int main(int argc, char **argv)
{
        struct clone_args args;
        args.argv = &argv[1];

        int clone_flags = SIGCHLD;
        // int clone_flags = CLONE_NEWIPC | SIGCHLD; // ipc

        // the result of this call is that our child_exec will be run in another
        // process returning it's pid
        pid_t pid =
            clone(child_exec, child_stack + STACKSIZE, clone_flags, &args);
        if (pid < 0) {
                fprintf(stderr, "clone failed WTF!!!! %s\n", strerror(errno));
                exit(EXIT_FAILURE);
        }
        // lets wait on our child process here before we, the parent, exits
        if (waitpid(pid, NULL, 0) == -1) {
                fprintf(stderr, "failed to wait pid %d\n", pid);
                exit(EXIT_FAILURE);
        }
        exit(EXIT_SUCCESS);
}