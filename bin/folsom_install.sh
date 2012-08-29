#!/bin/bash
cd /etc/init.d/
for i in `ls chef*`; do echo $i;service $i restart ;done


knife cookbook upload nova repositories -o /mnt/nova-chef/cookbooks:/mnt/release_train/basenode/cookbooks:/mnt/release_train/techops/cookbooks:/mnt/release_train/dbaas/cookbooks:/mnt/release_train/control-services/cookbooks -d

cd /mnt/nova-chef/data_bags
for i in `ls`;do knife data bag create $i;done

for i in `find |grep json$`; do j=`echo $i|awk -F/ {'print $2'}`; knife data bag from file $j $i;done

cd /mnt/nova-chef/roles
knife role from file *.json


