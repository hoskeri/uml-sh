#!/bin/bash

set -eu

#detect installation location
INSTALL_DIR=$(dirname `readlink -f $0`)

#rebuild initramfs
if [ ! -z "${REBUILD:-}" ]
then
  # begin rebuild
  ROOTDIR=`mktemp -d`
  DEB_PACKAGES="libc6 module-init-tools libudev0 dmsetup libdevmapper1.02.1 libselinux1 libncurses5 libtinfo5 bash strace"

  cleanup() {
    set +e
    echo "cleaning up"
    rm -rf $ROOTDIR
    set -e
  }

  # on interrupt, cleanup
  trap cleanup 1 2 3 6

  # copy modules
  make ARCH=um modules_install INSTALL_MOD_PATH=$ROOTDIR

  # copy busybox
  mkdir $ROOTDIR/bin/
  cp /bin/busybox $ROOTDIR/bin/
  for c in `busybox --list-full`; do
    mkdir -p $ROOTDIR/`dirname $c`
    ln -s /bin/busybox $ROOTDIR/$c
  done

  install_package() {
    package=$1
    echo installing package $package from system
    for p in `dpkg -L $package`;
    do
      if [ -f $p ] && [ ! -f $ROOTDIR/$p ]
      then
        dir=`dirname $p`
        mkdir -p $ROOTDIR/$dir
        fakeroot cp -p $p $ROOTDIR/$p
      fi
    done
  }

  for pkg in $DEB_PACKAGES
  do
    install_package $pkg
  done

  # install init
cat <<END > $ROOTDIR/init
#!/bin/sh

mknod /dev/zero c 1 5
mknod /dev/null c 1 3

modprobe loop
modprobe dm_mod
mknod /dev/loop0 b 7 0

mknod /dev/ubda b 98 0

mkdir /proc
mount -t proc none /proc

mkdir /sys
mount -t sysfs none /sys
mount -t hostfs /home/abhijit/play/kernel/sample /root

mkdir /tmp
hostname `hostname`-uml


export PS1="\w \$ "
bash --posix

END
  chmod +x $ROOTDIR/init

  echo "making cpio"
  CPIOTMP=`mktemp`
  cd $ROOTDIR
  fakeroot sh -eu -c 'find . |cpio -o -H newc|gzip -' > $CPIOTMP
  cd -
  mv $CPIOTMP initramfs.uml.img

  # end
  cleanup

fi
# create an extra disk to test code with
if [ ! -f $HOME/.test.disk ]
then
  dd if=/dev/zero of=$HOME/.test.disk bs=1 count=1 seek=4G
fi

# boot
ARGS="./linux mem=512M ubd0=$HOME/.test.disk initrd=initramfs.uml.img $@"
if [ ! -z "${GDB:-}" ]
then
	ARGS="gdb -x $INSTALL_DIR/gdbcommands.txt --args $ARGS"
fi
$ARGS || true # ignore return value to allow cleanup to proceed

# reset terminal
reset
