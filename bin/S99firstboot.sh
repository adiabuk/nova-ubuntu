#!/bin/bash -x

source /usr/local/bin/functions

function disable_chef() {

  sysv-rc-conf chef-client off
  killall -9 chef-client
}


function die() {

  echo $1
  exit 1

}


(

#################################################################
disable_chef
mv /etc/rc2.d/S20chef-server-webui /etc/rc2.d/S91chef-server-webui
mkdir /root/.chef /home/default/.chef
cp /etc/chef/validation.pem /etc/chef/webui.pem /root/.chef 
cp /etc/chef/validation.pem /etc/chef/webui.pem /home/default/.chef
chown -R default.default /home/default/.chef
chmod +r /etc/chef/webui.pem
su default -c "cd ~default;echo |knife configure --initial --defaults -u default"

su root -c "cd /root;echo|knife configure --defaults -u default"
cp -rv /home/default/.chef/default.pem /root/.chef/
#################################################################


cp /opt/nova-ubuntu/bin/issue_cron /etc/cron.hourly/
chmod 755 /etc/cron.hourly/issue_cron
/etc/cron.hourly/issue_cron

export HOME="/root"

prepare_env 
install_nova 

source /usr/local/bin/create_user.sh

setup_nova 

unlink /etc/rc2.d/S14firstboot.sh
unlink /etc/rc2.d/S99firstboot.sh
echo "done"
)2>&1|tee /var/log/nova-ubuntu/boot2.log

