#version=DEVEL
url --mirror=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-rawhide&arch=$basearch
install
network --bootproto=dhcp

bootloader --timeout=1
clearpart --all --initlabel
ignoredisk --drives=sdb
autopart

keyboard us
lang en_US.UTF-8
timezone America/New_York --utc
rootpw testcase
shutdown

%packages
%end

%pre
# Doing all this here is a lot easier than trying to make virt tools do
# what I want on the outside.  Also this'll run before storage.
parted /dev/sdb mklabel msdos
parted --align=none /dev/sdb mkpart primary 0 1G
mkfs.ext4 /dev/sdb1
mkdir /sdb
mount /dev/sdb1 /sdb
echo TEST > /sdb/sentinel
umount /sdb
rmdir /sdb
%end

%post
mkdir /sdb
mount /dev/sdb1 /sdb
if [[ $? != 0 ]]; then
    echo "*** could not mount /dev/sdb1" >> /root/RESULT
else
    if [[ ! -f /sdb/sentinel ]]; then
        echo "*** /sdb/sentinel no longer exists" >> /root/RESULT
    elif [[ "$(cat /sdb/sentinel)" != "TEST" ]]; then
        echo "*** /sdb/sentinel has changed contents" >> /root/RESULT
    fi

    umount /sdb
fi

if [ ! -e /root/RESULT ]; then
    echo SUCCESS > /root/RESULT
fi
%end