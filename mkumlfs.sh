#!/bin/bash
set -eu

# begin
ROOTDIR=`mktemp -d`

# copy modules
make ARCH=um modules_install INSTALL_MOD_PATH=$ROOTDIR

# copy busybox
mkdir $ROOTDIR/bin/
cp -v /bin/busybox $ROOTDIR/bin/
for c in `busybox --list-full`; do
	mkdir -p $ROOTDIR/`dirname $c`
	ln -v -s /bin/busybox $ROOTDIR/$c
done

# install init
cat <<END > $ROOTDIR/init
#!/bin/sh

mkdir /proc
mount -t proc none /proc

hostname `hostname`-uml
busybox sh

END
chmod +x $ROOTDIR/init

echo "making cpio"
CPIOTMP=`mktemp`
cd $ROOTDIR
fakeroot sh -c 'find . |cpio -ov -H newc|gzip -' > $CPIOTMP
cd -
mv -v $CPIOTMP initramfs.uml.img

# end
rm -rf $ROOTDIR

# boot 
./linux initrd=initramfs.uml.img
