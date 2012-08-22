#!/bin/bash
source configure.sh

function add_payload {


uuencode=1
if [[ "$1" == '--binary' ]]; then
        binary=1
        uuencode=0
        shift
fi
if [[ "$1" == '--uuencode' ]]; then
        binary=0
        uuencode=1
        shift
fi

[[ ! "$1" ]] && die "Usage: $0 [--binary | --uuencode] PAYLOAD_FILE"



if [[ $binary -ne 0 ]]; then
        # Append binary data.
        sed \
                -e 's/uuencode=./uuencode=0/' \
                -e 's/binary=./binary=1/' \
                         $myinput >$myoutput
        echo "PAYLOAD:" >> $myoutput

        cat $1 >>$myoutput
fi
if [[ $uuencode -ne 0 ]]; then
        # Append uuencoded data.
        sed \
                -e 's/uuencode=./uuencode=1/' \
                -e 's/binary=./binary=0/' \
                         $myinput >$myoutput
        echo "PAYLOAD:" >> $myoutput

        cat $1 | uuencode - >>$myoutput
fi




}




myinput="$mypath/cfg/install.sh.in"
myoutput="$output/nova-ubuntu_installer.bin"
check_root
rm $output/nova-ubuntu.iso* -f 2>/dev/null
cd $master
echo "Creating ISO Image..."
mkisofs -D -r -V “nova-ubuntu” -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o $output/nova-ubuntu.iso . &>/dev/null
gzip -c $output/nova-ubuntu.iso > $output/nova-ubuntu.iso.gz
cd $mypath
add_payload --binary $output/nova-ubuntu.iso.gz


function old() {
echo "Starting binary creation..."
cat $mypath/cfg/beg.txt >  $mypath/output/nova-ubuntu_installer.bin 
echo "Encoding ISO Image...."
uuencode nova-ubuntu.iso < $mypath/tmp/nova-ubuntu.iso >> $mypath/output/nova-ubuntu_installer.bin
echo "finishing binary creating...."
cat $mypath/cfg/end.txt >> $mypath/output/nova-ubuntu_installer.bin 
echo
echo "done"

}
