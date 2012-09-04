#!/bin/bash -x

source /usr/local/share/nova-testing/Input_files_to_source_RDE/my3user/novarc

for i in `seq 1 100`; do
nova delete $i;
done

nova-manage project delete my3project
nova-manage project scrub my3project
