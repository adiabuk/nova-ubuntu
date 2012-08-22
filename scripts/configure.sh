mypath="`pwd`/.."
master=~/nova-ubuntu_master
output=~/nova-ubuntu_output

function die() {

echo $1
exit 1

}

function check_root() {
  if [[ $UID -eq 0 ]]; then

    die "$0 should not be run as root";
  fi
}
