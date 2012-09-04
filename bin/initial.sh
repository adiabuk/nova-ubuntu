#!/bin/bash

nova-manage user admin nova
nova-manage project create nova nova
nova-manage project quota nova instances 10000
nova-manage project quota nova cores 20000
nova-manage project quota nova ram 512000000
nova-manage project quota nova gigabytes 1000000
nova-manage project quota nova floating_ips 1000
nova-manage project quota nova volumes 1000
mkdir /var/lib/nova/nova-ubuntu
nova-manage project zipfile nova nova /var/lib/nova/nova-ubuntu/nova.zip
cd /var/lib/nova/nova-ubuntu
unzip nova.zip
. /var/lib/nova/nova-ubuntu/novarc

euca-add-keypair novakeypair > /var/lib/nova/nova-ubuntu/keypair.priv
chmod 600 /var/lib/nova/nova-ubuntu/keypair.priv
euca-add-group -d "nova-ubuntu" novagroup1805
euca-authorize -P icmp -t -1:-1 novagroup1805
euca-authorize -P tcp -p 22 novagroup1805
euca-authorize -P tcp -p 8080 novagroup1805 
euca-authorize -P tcp -p 4321  novagroup1805

