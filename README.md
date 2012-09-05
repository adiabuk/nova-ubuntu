# What is Nova-ubuntu?
Nova-Ubuntu(Folsom) is a re-mastered Ubuntu 12.04 Server. Unlike
Ubuntu itself, nova-ubuntu  is fully automated using preseed files and
nova install scripts.

# Minimum Requirements:

- 4+GB Memory Free (6+GB recommended)
- 800MB disk space free on /tmp
- 30-100 GB free disk space on /var/lib/libvirt
- Access to the internet (for installation of packages)
- ability to run command via sudo to install libvirt/KVM etc.
- x86_64/amd64 CPU, or able to emulate x86_64/amd64
- nested virtualization capability (otherwise fallback to qemu inside nova-ubuntu)

# Which Hypervisor?

Whilst it is preferable to use KVM as the hypervisor, there are many
circumstances which will not make that possible:

Other virtualization products known to support Nova-Ubuntu: Vmware Workstation,
VirtualBox

# Installation


## KVM Install

The installer assumes you are running from X-Windows. Although it will
work from a text console, the VM will be created in headless mode (i.e.
No virtual graphics card). Using Nova-Ubuntu in headless mode is outside the
scope of this document. For best results perform the following from an
X-Windows session.

Run the installer with bash and use install as the first and only
parameter

This will extract the ISO image, and untar it to /tmp directory (it will
be automatically deleted on reboot) After that it will check for the
existence of packages, available memory, and disk space

For disk space you require at least 30G available in the
/var/lib/libvirt directory, or /var/lib (if libvirt doesn't yet exist on
your system)

You will also need sharutils, virt-viewer, virt-manager and kvm packages
installed. The script will prompt for the sudo password to install this
for you.

Note: If this is installed as port of the process (i.e. Not already
installed) you will need to re-login to the session you will be added to
the newly created libvirt group and this will only be effective on a new
login. If the script fails shortly after this step then log back in (or
reboot) and try again.

Once all dependencies have been satisfied the ISO image will extract and
a KVM VM will be created to boot from this image.

Virt-viewer will launch and you will be presented with the initial boot
menu.

Proceed to section: “Common installation (Hypervisor agnostic)”

## Extract ISO Image (for Non-KVM Installs)

- Instructions based on VMware Workstation 8.0.1 build 528992
- Download file
- On a Linux machine (or Cygwin/OSX terminal/other unix compatible shell)
- Run script as follows:

```
bash nova-ubuntu_installer-2.6.2.bin extract
```

This should output a file: nova-ubuntu-2.6.2.iso

Copy this to the host you will install it to

# VMware Install

- Start Vmware
- Choose “File-New Virtual Machine...”Select “Custom (advanced)” radio box
- Select “Workstation 8.0” from drop down box (Hardware compatibility screen)
- Select “I will install the operating system later”
- Choose Linux=> Ubuntu 64-bit (Guest Operating System Screen)
- Choose name (ensure you put in the version, of nova-ubuntu you are installing)
- Choose minimum 2 cores, 2 CPUs for best results (Processor Configuration screen)
- choose minimum 4GB memory
- Use NAT (network connection screen)

Note: If you have previously installed nova-ubuntu Diablo – you may need to
manually select the virtual interface rather than NAT. Use VMware
Virtual Network Editor to view available networks. You need something
with NATTED connection that must have DHCP. If NAT is not possible
Bridged connections will also work, but ensure that DHCP is available on
the network you are using.

If required use the network editor application to ensure you are using
the correct network:

- leave I/O controller as default recommended option (IO Controller types screen)
- Create New Virtual Disk (Disk screen)
- Choose SCSI – recommended (Virtual disk type screen)
- Choose disk size 100G, single file, do not allocate all disk space
- Click Customize Hardware
- Select Processors
- select CPU
- select Virtualize Intel VT-x/EPT or AMD-V/RVI (if your host CPU supports it)
- Select CD
- Select “Use ISO Image”
- Browse to location of previously extracted ISO Image
- Click Close
- Click Finish
- Power on the virtual Machine

Proceed to section: “Common installation (Hypervisor agnostic)”

## VirtualBox Install

Instructions based on Oracle VirtualBox 4.0.4_OSE

Note: VirtualBox does NOT support nested virtualization so you will will
fall back to QEMU only within nova-ubuntu. It is also known to have issues with
high DiskIO, so may not be ideal for many tasks. Use at your own RISK

- Click “New” to start the “New Virtual Machine Wizard”
- Click next
- Choose name and OS (Ensure you have the version in the VM name)
- Choose Operating System and Version as Linux Ubuntu (64-bit)
- Select memory, 4+GB (4096MB)
- Select Create new hard disk (Virtual Hard Disk screen)
- Choose Dynamically expanding storage (Hard disk storage Type screen)
- Choose Disk size: 100G (Virtual Disk Location and size screen)
- Click Next => Finish => Finish
- Click settings (Settings of the new VM you just created)
- System->Processor
- Enable PAE/NX,
- Processor: 4

acceleration tab:

- enable vt-x/AMD-v
- enable nested paging

- Go to Storage menu option => click on CPU in the tree
- Browse to previously downloaded ISO image
- Click OK
- Start VM

Proceed to section: “Common installation (Hypervisor agnostic)”

## Common installation (Hypervisor agnostic)

This section is common to all methods of installation. Although there
may be some extra steps performed in the background, these are largely
transparent.

Select the option that suits you better (USA, Europe, India, Home) and
press ENTER.

The remainder of the installation should be fully automated and will not
require any interaction. If the process stops for any reason, or prompts
you for any information this could indicate an issue with the network
(DHCP/Proxy etc.), or you have chosen a wrong option in the previous
menu.

The first part of the install process (called phase 1) is installing
some core Ubuntu packages. You will see a purple screen with a red
progress bar.

Although networking is configured here, no packages are downloaded from
the internet at this stage. Everything is installed from the CD/ISO
image.

This process will take approximately 10-20 minutes, depending on the
speed of your hard drive/RAM.

The machine will then reboot to continue installing.

You will see a black screen with script output rushing up the screen.
This installs other required packages, sets up the environment,
configures chef, and installs/configures nova. Due to the amount of
packages required (mainly from upstream Ubuntu repositories) this part
of the process can take anywhere up to 2 hours (depending on the speed
of your network connection, CPU, and Hard drive).

If this process seems to complete sooner that the above estimated time,
it could be that something failed (check log files, discussed later)

Once complete you will be presented with a login screen, which also
displays information about your new environment.

This shows the current IP address of the VM, for SSHing in or
connecting to the services remotely Also the default user name/password
is displayed.

A good test to find out if the installation was successful is to log in
and check for ACTIVE instances as follows:

```
adiab@amrox:~$ ssh default@192.168.122.201

Warning: Permanently added '192.168.122.201' (ECDSA) to the list of
known hosts.

default@192.168.122.201's password:

Welcome to Ubuntu 12.04 LTS (GNU/Linux 3.2.0-23-generic x86_64)


* Documentation: https://help.ubuntu.com/

To run a command as administrator (user "root"), use "sudo <command>".

See "man sudo_root" for details.

default@nova-ubuntu:~$ nova list

+--------------------------------------+--------------+--------+------------------------------+

| ID | Name | Status | Networks |

+--------------------------------------+--------------+--------+------------------------------+

| 2622c579-0f53-4275-a1d6-9dbec8566b62 | at_boot_test | ACTIVE |
private=10.10.0.2, 10.30.0.1 |

+--------------------------------------+--------------+--------+------------------------------+

default@nova-ubuntu:~$
```

By default there should be one running instance after the installation
is complete.

If not see debug section below to try to identify what went wrong.

# Using Nova in a Box

## Navigating around nova-ubuntu 

### Users & Permissions:

You should use the default user for most tasks. This as a default password
of “password”. You have full sudo access with this user to perform other
functions (eg. Restarting services, (re)installing nova or other
packages, viewing log files etc.

The root user is also available for direct log in when sudo is not
sufficient. Default password is also “password”.

Both users are set up to use nova/glance commands – you do NOT need to
source any novarc files, or otherwise as keystone permissions are
granted via the bashrc file on log in.

To run X11 (see below) you need to be logged in as default, not root.

### Files & Functions

All log files relating specifically to nova-ubuntu are placed in the
/var/log/novaubuntu directory.

For boot logs (identifying issues with installation) you will need to
view the following logs:

/var/log/novaubuntu/boo1.log

/var/log/novaubuntu/boot2.log

Other log files will be in the default location in /var/log

Information files:

/etc/novaubuntu (release information of nova-ubuntu – version, release date etc.)

/etc/location.cfg (proxy settings used by build scripts)

All nova-ubuntu specific scripts are location in /usr/local/bin (viewnova-ubuntu 
developers documentation for more details on how/why/when/what they do.
All scripts required for day-to-day running will be displayed on the
Desktop.

### Using the GUI
-------------

By default nova-ubuntu boots into text mode. This is because not
everybody needs/uses the GUI, but it is available for those that do.

To start the GUI log on at the console using the default user and type:
startx

Note: Full screen has been known not to work properly on all
monitors/resolution. You may need to adjust some parameters for this to
work perfectly on your nova-ubuntu instance.

This is the default screen when logging into the GUI.

### Notable features:

Desktop manager: ubuntu-fallback

Icons on the desktop for cleanup/install/other functions (not yet
complete)

Nova-Ubuntu Desktop Dashboard (displaying nova-ubuntu install details)

Nagstmon in status bar (displaying status of nova)

System monitor (top of screen) displaying VM resource status

Common development applications in Ubuntu menu

### Nova-Ubuntu Desktop dashboard.

This displays information about nova, and glance

It also displays information about Nova-Ubuntu itself (the version, when it was
created, installed, and updated)

The VPN available line changes to red if the VPN NOT available. It does
this by checking if a route to KEG is available.

Source modified checks if the nova code has been modifed since it was
installed. It does this by using a package called debsums which compares
the md5sum of each file with the md5sum of the file provided by the
package. This line will also change to red if there have been
modifications. This is useful if you need to know how fresh the
instllation is, or have forgotton if you made any changes, and where
they are. To find out which files have been modified you can simply run
the debsums binary in a terminal.

All these details are updated every minute and will change when the
version is updated.

### Nagstamon

This is a Nagios client set up for Nova-Ubuntu only (ie. It is not related to
Icinga running in production, and other environments.)

Its purpose is to alert the user to services not running, and other
networking issues that may not be otherwise apparent. A red flashing
icon indicates that there is an issue – click on the icon to display
further information. The icon is green if everything is running as
expected.

### System monitor

There are 6 min-graphs displayed at the top of the screen. When running
many instances, or opertaions that use up huge resources its useful to
keep an eye on this display.

From left to right these 6 graphs display the following:

### Restarting Nova-Ubuntu

Using KVM, it is best to keep track of Nova-Ubuntu using virtual machine
manage (command name: virt-manager) . You can also use starndard virsh
commands for starting/stopping/rebooting/deleting instances.


## Fault finding/Debugging

### Installation issues.

Issues with the installer are mainly due to network issues.

The network is configured staright away (DHCP), so a failure here would
be notised straight away. Insure that KVM has a default network which is
configured with NAT and DHCP is available. If you have not used KVM
before on your host this will be setup automatically.

How to re-configure guest networking is outside the scope of this
document. Here is a link which may be useful.
[http://www.linux-kvm.org/page/Networking](http://www.linux-kvm.org/page/Networking)

Other network issues may also be seen at a later stage after the VM has
rebooted for the first time.

If you see many errors related to downloading files, this may indcate
there is an issue with DNS, or routing. If you do find issues after the
installation is complete (eg. Nova doesn't seem to be isntalled) you
should check the boot logs in /var/log/novaubuntu for more explation.
You can then try to reproduce the issue, but running the commands in
these log files that failed....

```
apt-get update, or apt-get install <package-name>
```

If installed you can also use telnet, or nc to see if the ubuntu
repositories (listed in /etc/apt/sources.list) are accessable on port 80

Take a look at /etc/location.cfg and insure that the details (proxy
etc.) listed in there are correct.

From this you should have a better idea of what the issue is.

### Issues with Nova Instances going to ERROR

Occasionally (although quite rarely) after first boot nova list will
display in instance in ERROR status. This could be because of a
race-condition for services starting after chef completes its job of
installing nova.

To check if this is really a problem, try creating a new instance and
ensure it goes to ACTIVE status. Otherwise, the nova logs may provide
some insight.

### No console log output for new instances

This is more an issue encountered while developing, rather than an issue
with Nova-Ubuntu or Nova. With Nova-Ubuntu its much easier to debug why this is
happening.

In te Nova-Ubuntu GUI start virt-manager (or connect to it using virt-manager
remotely using SSH)

May need to run “sudo virt-manager” in a terminal

Often you will see something like “Disk not bootable”, or invalid kernel
etc. which will not show in the console log.
