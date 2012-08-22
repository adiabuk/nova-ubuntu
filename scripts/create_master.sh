#!/bin/bash

source configure.sh

function usage()
{
cat << EOF
usage: $0 options

This script is used to create an Nova-Ubuntu binary installer from an Ubuntu 12.04 ISO image

OPTIONS:
   -h      Show this message
   -i      full path to ubuntu iso image: (eg. /home/adiab/Downloads/ubuntu-12.04-server-amd64.iso)
   -s      Your SSO username (used to connect to gerrit): (eg. diabamr)
   -t      Name of promotion file from keg archive (eg. promotion_nova_100.2.0.tar.gz)
   -c      chef-client branch (eg. feature/folsom)
   -v      Verbose
EOF
}

function get_args() {

while getopts “h:i:s:t:c:n:d:” OPTION
do
     case $OPTION in
         h)
             usage
             exit 1
             ;;
         i)
             IMAGE=$OPTARG
             ;;
         s)
             SSO=$OPTARG
             ;;
         t)
             TAR=$OPTARG
             ;;
         d)  DIR=$OPTARG
             ;;
         n)  NIAB_BRANCH=$OPTARG
             ;;
         c)  CHEF_REPO=$OPTARG
             ;;
         v)  
             echo "verbose"
             ;;
         ?)
             usage
             exit
             ;;
     esac
done
if [[ -z "$IMAGE" ]] || [[ -z "$SSO" ]] || [[ -z "$TAR" ]]
then
     usage;
     exit 1
fi

[[ ! -f "$IMAGE" ]] && echo "File not found $IMAGE"

}

check_root
get_args $@

rm -rf $master ;mkdir $master &> /dev/null || die "$master already exists, please remove and try again"
sudo umount /mnt &>/dev/null
sudo mount -o loop $IMAGE /mnt || die "/mnt already mounted, please unmount and try again"
echo "Copying files..."
shopt -s dotglob || die "shopt command missing from system, please reinstall and try again"
cp -rv /mnt/* $master >/dev/null|| die "Unable to copy files from ISO image" 
sudo chmod -R 777 $master
cp $mypath/cfg/image_files/isolinux/* $master/isolinux/
cp $mypath/cfg/image_files/preseed/* $master/preseed/
umount /mnt
mkdir $output &>/dev/null
cd $master/
mkdir files;cd files
git clone http://github.com/openstack-dev/devstack.git || die "Unable to clone devstack repo"
cd nova-ubuntu;git checkout $CHEF_REPO;cd ..;
find -type d -name .git | xargs rm -rv
sudo chmod -R 777 $master

