#!/bin/bash -x

mkdir /var/log/nova-ubuntu
(
  add_keg_repos
  rm /etc/dpkg/dpkg.cfg.d/multiarch
  mv /usr/local/share /usr/local/share.old
  mv /usr/local/bin  /usr/local/bin.old
  ln -s /opt/nova-ubuntu/share/ /usr/local/share
  ln -s /opt/nova-ubuntu/bin   /usr/local/bin
  source /usr/local/bin/default_functions


  /etc/init.d/rabbitmq-server start
  sudo rabbitmqctl add_vhost /chef
  sudo rabbitmqctl add_user chef password
  sudo rabbitmqctl set_permissions -p /chef chef ".*" ".*" ".*"

  cat > /etc/chef/webui.rb << EOW
  log_level          :info
  log_location       STDOUT
  ssl_verify_mode    :verify_none
  chef_server_url    "http://localhost:4000"
  file_cache_path    "/var/cache/chef"
  openid_store_path  "/var/lib/chef/openid/store"
  openid_cstore_path "/var/lib/chef/openid/cstore"
  Mixlib::Log::Formatter.show_time = true
  signing_ca_cert "/etc/chef/certificates/cert.pem"
  signing_ca_key "/etc/chef/certificates/key.pem"
  signing_ca_user "chef"
  signing_ca_group "chef"
  web_ui_client_name "chef-webui"
  web_ui_admin_user_name "admin"
  web_ui_admin_default_password "password"
  web_ui_key "/etc/chef/webui.pem"
  EOW

  cat  > /root/.xinitrc > /home/default/.xinitrc << EOG
  exec "gnome-session-fallback"
  xrandr --addmode VGA-1 1920x1200
  xrandr --output VGA-1 --mode 1920x1200
  EOG

  cat > /etc/ssh/ssh_config << EOC
  Host 127.0.0.1 localhost
     CheckHostIP no
     StrictHostKeyChecking no
      SendEnv LANG LC_*
      HashKnownHosts no
      GSSAPIAuthentication no
      GSSAPIDelegateCredentials no
  EOC
  mkdir -p /var/www/cloud/nova/virtenv/conf /var/www/cloud/nova/archive

  cat > /var/www/cloud/nova/virtenv/conf/distributions << EOD
  Origin: Cloud Services
  Label: Local Repository
  Suite: precise
  Codename: precise
  Version: 1.0
  Architectures: amd64 source i386
  Components: unstable
  Description: Local development packages
  EOD

  cat > /etc/apt/sources.list.d/localenv.list << EOF
  deb http://127.0.0.1/cloud/nova/virtenv precise unstable 
  EOF


  cat > /etc/chef/solr.rb << EOS
  log_location       STDOUT
  search_index_path    "/var/lib/chef/search_index"
  solr_jetty_path "/var/lib/chef/solr/solr-jetty"
  solr_home_path  "/var/lib/chef/solr"
  solr_data_path  "/var/cache/chef/solr/data"
  solr_heap_size  "256M"
  solr_url        "http://localhost:8983/solr"
  solr_java_opts  "-DSTART=#{solr_jetty_path}/etc/start.config"
  amqp_pass "password"
  Mixlib::Log::Formatter.show_time = true
  EOS
  check_location
  cat > /etc/apt/apt.conf << EOT
  Acquire::http::Proxy "http://${proxy}:${port}";
  Acquire::http::Proxy::127.0.0.1 DIRECT;
  Acquire::http::Proxy::apt.loc DIRECT;
  APT::Get::AllowUnauthenticated 1;
  APT{Ignore {"gpg-pubkey"; }};
  EOT

  cat > /usr/share/gnome-background-properties/ubuntu-wallpapers.xml << EOB
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
  <wallpapers>
    <wallpaper>
      <name>Ubuntu</name>
      <filename>/usr/local/share/Downloads/backdrop-green.jpg</filename>
      <options>zoom</options>
      <pcolor>#2c001e</pcolor>
      <scolor>#2c001e</scolor>
      <shade_type>solid</shade_type>
    </wallpaper>
  </wallpapers>
  EOB

  cp /usr/local/share/Downloads/backdrop.jpg /usr/share/backgrounds/warty-final-ubuntu.png

  echo "root:   /dev/null" >> /etc/aliases
  newaliases

  tar zxvf /opt/nova-ubuntu/share/skel.tar.gz -C /home/default
  chown -R default.default /home/default
  mkdir /var/cache/nova-ubuntu/
  touch /var/cache/nova-ubuntu/install.lck /var/cache/nova-ubuntu/cleanup.lck

  cat > /etc/nova-ubuntu << EOE
  Version: 2.4.1
  Date: 17-July-2012
  EOE


  mkdir /root/.ssh
  cat > /root/.ssh/authorized_keys << EOZ
  ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCy1WdrgaWnhurEyfOEm7vFDmQpbDDJ/iONG9pi08yKPUu8Ql9YGVfhJ44fA5ZqFzqxd9WuWFQRdaCbSUjQx+ph6iPa6sgVrUGn0ARWzK2LxoOW0ksA+cIFhJUukCDLVquNxKuVnrVpR+QS8c+pxu9BM5usYsCmssZQgiIgz9Vy2E8cVy+LwjpchQxJiN7nJGX66FAQ9iwsgc3atBm101/PnZjZdO63NEOh6a/HZeygoeFL/V5fG0FlSUmORfMPKMgHJ62fhE1otXRTODXVgQNqJTcngmQrrnJWhwYjIEPpiaLosHa1wFVmASDzFrBMD7tv5/9u3C2godnjYOLvDj9h root@default-VirtualBox
  EOZ

  mkdir /etc/nova
  cat > /etc/nova/rootwrap.conf << EOR
  [DEFAULT]
  filters_path=/etc/nova/rootwrap.d
  EOR


  cp -rv /opt/nova-ubuntu/gdesklets/IExec /usr/lib/gdesklets/Controls
  cp -rv /opt/nova-ubuntu/gdesklets/Nova-Ubuntu /usr/lib/gdesklets/Displays
  mkdir /home/default/.config/autostart
  cp -rv /opt/nova-ubuntu/gdesklets/gdesklets.desktop /home/default/.config/autostart/
  cp -rv /opt/nova-ubuntu/gdesklets/.gdesklets /home/default
  chown -R default.default /home/default
  rm -rf /etc/nagios3/conf.d
  cp -rv /opt/nova-ubuntu/conf.d /etc/nagios3/

  cat > /etc/nagios3/htpasswd.users << EOP
  nagiosadmin:C9aFcy08CNAt.
  EOP

  ipaddr=`hostname -I|awk {'print $1'}`
  sed -i "s/IPADDR/$ipaddr/g" /etc/nagios3/conf.d/myservices.cfg
  /etc/init.d/nagios3 restart

  echo ". /usr/local/bin/create_user.sh" >> /home/default/.bashrc
  echo ". /usr/local/bin/create_user.sh" >> /root/.bashrc

  cp -rv /usr/local/share/Desktop/* /home/default/Desktop/
  cp -rv /usr/local/share/Downloads/* /home/default/Downloads/
  chown -R default.default /home/default
  groupadd admin
  usermod -a -G admin default
  rm /var/lib/mysql/ib-logfile*

  mv /opt/nova-chef /mnt
  mv /opt/release_train /mnt
  mv /opt/default-nova-buildhelper /mnt
  mv /etc/apt/sources.list /etc/apt/sources.list.d
  apt-get update

)2>&1|tee /var/log/nova-ubuntu/boot1.log
