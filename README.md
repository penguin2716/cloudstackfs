# CloudStackFS
This is a FUSE file system for CloudStack VM management.

# Usage
for mount:
```
./cloudstackfs.rb /path/to/mount
```
for unmount:
```
fusermount -u /path/to/mount
```

The structure of the mount path is like VM deployment wizard of CloudStack. If your CloudStack has two zones named `Advanced Zone` and `Basic Zone`, the mount path contains two directories.
```
$ ls -1F /path/to/mount
Advanced Zone/
Basic Zone/
```

Each zone directory contains VM templates.
```
$ cd /path/to/mount/Basic\ Zone
$ ls -1F
CentOS 5.5(64-bit) no GUI (KVM)/
CentOS 6.7 x86_64/
CentOS 7.0 x86_64 minimal/
Debian 7.4 (64bit)/
Ubuntu Server 14.04 LTS (amd64)/
...
```

Each template directory contains ComputingOffering.
```
$ cd CentOS\ 7.0\ x86_64\ minimal/
$ ls -1F
1core,1GB/
1core,512MB/
2core,2GB/
4core,4GB/
```

Each offering directry contains VM directories and special files to kick API to the CloudStack.
```
$ cd 2core,2GB
$ ls -1F
deploy
destroy
reboot
start
stop
testvm01/
testvm02/
```

Writing `testvm03` to `deploy` will create a new VM named `testvm03` with specifications of the current path. Writing the VM name to `start`, `stop`, `reboot`, and `destroy` also works.
```
$ echo testvm03 > deploy
$ ls -1F
deploy
destroy
reboot
start
stop
testvm01/
testvm02/
testvm03/
```

Each VM directories contains files to describe VM's status.
```
$ ls -F testvm01/
account       displayname            name             serviceofferingid
cpunumber     domain                 networkkbsread   serviceofferingname
cpuspeed      domainid               networkkbswrite  state
cpuused       guestosid              nic/             templatedisplaytext
created       haenable               ostypeid         templateid
diskioread    hypervisor             passwordenabled  templatename
diskiowrite   id                     rootdeviceid     zoneid
diskkbsread   isdynamicallyscalable  rootdevicetype   zonename
diskkbswrite  memory                 securitygroup/
$ cat testvm01/created
2016-03-31T04:05:37+0900
% cat testvm01/nic/561833f1-d024-4539-8e97-f306b7610760/ipaddress
10.40.5.202
```

Files and directories will not updated automatically. If you'd like to fetch latest status, `touch` an arbitrary file or directory.
```
$ echo testvm04 > deploy 
$ cd testvm04/nic/dcbeb43a-b0bb-41ec-a7d4-62a7d9aa71b3/
$ ls
id  isdefault  networkid  networkname  traffictype  type
$ touch .
$ ls
broadcasturi  id         isdefault   netmask    networkname  type
gateway       ipaddress  macaddress  networkid  traffictype
$ cat ipaddress 
10.40.7.169
$ ping 10.40.7.169
PING 10.40.7.169 (10.40.7.169) 56(84) bytes of data.
64 bytes from 10.40.7.169: icmp_seq=1 ttl=63 time=2.76 ms
64 bytes from 10.40.7.169: icmp_seq=2 ttl=63 time=1.75 ms
64 bytes from 10.40.7.169: icmp_seq=3 ttl=63 time=2.01 ms
...
```

