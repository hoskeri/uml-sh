# UML Shell

The usual root images used alongside UML are unsuitable for kernel hacking
because they waste too much time and resources booting up a full Linux system.

All I need is a shell to hack in.

UML shell is a small utility to boot a user mode linux kernel and run a shell (busybox, currently)
inside it. If its built in, hostfs can be used to mount the host filesystem and
use the files from there. 

