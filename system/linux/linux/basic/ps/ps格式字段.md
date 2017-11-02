
man ps


AIX FORMAT DESCRIPTORS
       This ps supports AIX format descriptors, which work somewhat like the formatting codes of printf(1) and printf(3).
       For example, the normal default output can be produced with this: ps -eo "%p %y %x %c".  The NORMAL codes are
       described in the next section.

       CODE   NORMAL   HEADER
       %C     pcpu     %CPU
       %G     group    GROUP
       %P     ppid     PPID
       %U     user     USER
       %a     args     COMMAND
       %c     comm     COMMAND
       %g     rgroup   RGROUP
       %n     nice     NI
       %p     pid      PID
       %r     pgid     PGID
       %t     etime    ELAPSED
       %u     ruser    RUSER
       %x     time     TIME
       %y     tty      TTY
       %z     vsz      VSZ
