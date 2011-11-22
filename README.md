# UML Shell

The usual root images used alongside UML are unsuitable for kernel hacking
because they waste too much time and resources booting up a full Linux system.

All I need is a shell to hack in.

UML shell is a small utility to boot a user mode linux kernel and run a shell
(busybox, currently) inside it. If its built in, hostfs can be used to mount
the host filesystem and use the files from there. 

## Usage

### Build a UML kernel in the usual way.

Eg. `make ARCH=um`

This will build the UML image and modules. You could use the provided
`kernel-config-example` as your `.config` to have a minimal kernel suitable for
hacking and debugging.

### Change into the Kernel directory and run the mkumlfs script

    REBUILD=1 /path/to/mkumlfs.sh

This will install the modules, packages, initscript, generate the initramfs,
boot up the kernel and start a busybox shell.

### GDB Support

    GDB=1 /path/to/mkumlfs.sh

This will start the kernel under gdb. Set your breakpoints, etc. and the hit
`r`.  Some gdb commands necessary for running UML are read from gdbcommands.txt
in the uml-sh installation directory.

### Access the host filesystem if its available.

mkumlfs.sh will attempt to mount the host filesystem using `hostfs` if
supported by the kernel. You can do it yourself as follows:

    mkdir /mnt
    mount -t hostfs none /mnt

## Dependencies

Currently they are fakeroot, busybox-static and cpio
All of these are available as packages of the same name on Debian/Ubuntu.
