# UML Shell

The usual root images used alongside UML are unsuitable for kernel hacking
because they waste too much time and resources booting up a full Linux system.

All I need is a shell to hack in.

UML shell is a small utility to boot a user mode linux kernel and run a shell (busybox, currently)
inside it. If its built in, hostfs can be used to mount the host filesystem and
use the files from there. 

## Usage

### Build a UML kernel in the usual way.

Eg. `make ARCH=um`

This will build the UML image and modules

### Change into the Kernel directory and run the mkumlfs script

This will generate the initramfs, boot up the kernel and start a busybox shell.

### Access the host filesystem if its available.

`mkdir /mnt`

`mount -t hostfs none /mnt`

## Dependencies

Currently they are fakeroot, busybox-static and cpio
All of them are available as packages of the same name on Debian/Ubuntu.
