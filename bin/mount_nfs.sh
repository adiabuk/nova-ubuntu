#!/bin/bash

function die() {

echo $1
exit 1

}


function check_root() {
  [[ $UID -eq 0 ]] || die "$0 needs to be run as root";

}


check_root
share=`/sbin/showmount -e 192.168.122.1 --no-headers| awk {'print $1'}`
mount -t nfs 192.168.122.1:$share /mnt || die "unable to mount NFS share"
echo "192.168.122.1:$share /mnt nfs defaults 0 0" >> /etc/fstab
