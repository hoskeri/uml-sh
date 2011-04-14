#!/bin/bash
set -eu

# begin
ROOTDIR=`mktemp -d`

# copy modules
make ARCH=um modules_install INSTALL_MOD_PATH=$ROOTDIR

# copy busybox
mkdir $ROOTDIR/bin/
cp /bin/busybox $ROOTDIR/bin/
for c in `busybox --list-full`; do
	mkdir -p $ROOTDIR/`dirname $c`
	ln -s /bin/busybox $ROOTDIR/$c
done

# install init
cat <<END > $ROOTDIR/init
#!/bin/sh

export PS1="\h \w \$ "

mkdir /proc
mount -t proc none /proc
mkdir /sys
mount -t sysfs none /sys

hostname `hostname`-uml
busybox sh

END
chmod +x $ROOTDIR/init

echo "making cpio"
CPIOTMP=`mktemp`
cd $ROOTDIR
fakeroot sh -eu -c 'find . |cpio -o -H newc|gzip -' > $CPIOTMP
cd -
mv $CPIOTMP initramfs.uml.img

# end
rm -rf $ROOTDIR

# boot 
./linux initrd=initramfs.uml.img quiet
