---
author: Jan
categories:
- Tutorials
date: '2017-01-31'
guid: http://beta.janw.io/zfs-all-the-things-manually-building-a-zpool-on-linux-from-scratch/
id: 33
slug: zfs-all-the-things-manually-building-a-zpool-on-linux-from-scratch/
tags:
- freebsd
- ubuntu
- zfs
- zfsonlinux
title: ZFS all the things! Manually building a zpool on Linux from scratch

---

Eversince I started building my own [homeserver and backup infrastructure]({filename}2016-05-16_some-peace-of-mind-my-2016-storage-and-backups-setup.md) I&#8217;ve been a huge fan of the Zettabyte Filesystem, ZFS. It has been in development for quite a while, is considered incredibly stable, and offers all the features you&#8217;ll want in a filesystem for long-term file storage: built-in data compression, copy-on-write, snapshots, checksumming, block-level incremental send and receive functionality, etc.

Until recently ZFS was limited to Solaris and FreeBSD almost exclusively, however with the advent of the [OpenZFS project](http://open-zfs.org/wiki/Main_Page) and its intention of bundling efforts to provide stable ZFS support to a variety of operating systems there are more options available. At work I am tied to using Linux, and I recently (after a few months of distro hopping) arrived back at a vanilla Ubuntu, which meant: ZFS support almost out-of-the-box, and I thought I&#8217;d give it a show in favor or my previous thumblings with btrfs. Since I forget quite quickly about how I go about such things, I thought about writing it down for future reference—and yours!

<!--more-->

On my homeserver I run FreeNAS which handles partitioning and volume creation in a neat little assistant. But I&#8217;ve had been forced to go hands-on with partitioning in the past, so I was quite familiar with what to do. I figured, I would aim to replicate the default FreeNAS partitioning, and my personal choice of zpool layouting as close as possible:

  * FreeNAS assigns 2GiB at the beginning of each drive to swap space, and uses the rest exclusively for the actual storage. I won&#8217;t need the swap space on my workstation machine but it keeps the door open for migrating the pool to FreeBSD if I later decide to go distro hopping on the other side (BSD) for a change.
  * After working with a RAIDZ1 for a while I&#8217;ve recently upgraded my servers to run with mirrored-vdev pool for that _extra_ amount of peace of mind in case of drive failure. It seems a little counter-intuitive, but the reasoning behind it is all laid out [here](http://jrs-s.net/2015/02/06/zfs-you-should-use-mirror-vdevs-not-raidz/).

## Installing ZFS

The installation of the necessary ZFS kernelmodules and userland tools is pretty easy starting with Ubuntu 16.04 LTS: you just install via `apt`, do a reboot for good measure, and you&#8217;re basically ready to go.

    sudo apt-get install zfsutils-linux


One step I like to do in addition to that is set an ARC memory limit for ZFS. Otherwise ARC will just continue to aquire more and more RAM, and the memory models of ZFS and the rest of the Kernel don&#8217;t play very nicely with each other. My machine currently has 16GB of memory, so I go with 4GB of maximum ARC size. Just open `/etc/modprobe.d/zfs.conf` in your favorite editor and add the following line:

    options zfs zfs_arc_max=4294967296


## Formatting the drives and creating the pool

Next step I used gdisk to format the disks in alignment with the FreeNAS partitioning scheme. I&#8217;m not going to go into too much detail here but advise you to use the `cgdisk` CLI frontend to go about doing so. Of course the size of partition 2 depends on the total size of the disk you&#8217;re formatting. Disks may be found using `lsblk`.

    Number  Start (sector)  End (sector)  Size        Code  Name
    1            2048           4196351   2.0 GiB     A502
    2         4196352        7814037134   3.6 TiB     A504


After formatting and writing the new partition table (**which will destroy all previous data on the disk**), we finally create our storage pool. You&#8217;ll be working with partition UUIDs from now on. ZFS does not like device identifiers like `/dev/sdb2`. Even tiny things like leaving a USB thumb drive plugged in while rebooting can mess up the ordering of these letters. UUIDs are device-specific (partition specific even), and you should them. You can get them from the (current) device letter à la `sudo blkid /dev/sdX2`, where `X` marks your drive&#8217;s letter. `PARTUUID=` is the property you&#8217;re looking for. With that, I started creating a single drive pool, since I&#8217;ve had only one more SATA port availble. Copy the UUID and use it as a device identifier when creating the pool like so (e6313611-6c4d-4260-9bd6-7856f6c7633c\` denotes my first drive&#8217;s PARTUUID):

    sudo zpool create -f tank /dev/disk/by-partuuid/e6313611-6c4d-4260-9bd6-7856f6c7633c


## Initial custom configuration and copying data

Congratulations, your pool is now live! Next up are some default settings. I carry all mounted drives under `/mnt`, while ZFS mounts directly in `/` by default. This can be changed easily using the handy ZFS `set`/`get` functions. `zfs get all <pool name>` shows you all available settings on a given pool.

    sudo zfs set mountpoint=/mnt/tank tank


Also we want to enable compression. I opted for the default algorithm (lz4), which offers the best balance of compression vs. performance for most scenarios. But your mileage may vary.

    sudo zfs set compression=lz4 tank


Now I split data that will be held on the pool in some datasets for logical separation and reasonable per-datatype snapshot settings later. All datasets we&#8217;re creating are inheriting the mountpoint from the pool, and will be placed thereunder. It&#8217;s _that_ simple.

    sudo zfs create tank/audio
    sudo zfs create tank/backups
    sudo zfs create tank/sync


By now I&#8217;m ready to copy my data over from the previous storage pool (a btrfs mirror) using `rsync`. After that was done I unplugged both the btrfs mirror drives and attached the ZFS drives in the proper place in the case. Now it&#8217;s time to extend our single drive pool into a mirrored one.

## Attaching a mirror to the pool

For that I repeat the formatting/partitioning with the second disk. The command for adding the disk to your pool is rather simple, and basically completes the setup. ZFS requires you to name one disk that already is part of the pool (as the device to attach to), followed by the new disk. Both choices are easy for us:

    sudo zfs attach tank /dev/disk/by-partuuid/e6313611-6c4d-4260-9bd6-7856f6c7633c /dev/disk/by-partuuid/991ce4b0-3223-4d3e-ab0f-01ed052ccb89


Now some mad rattling should be happening inside your hard drive&#8217;s enclosures: ZFS will automatically initiate a scrubbing process, replicating the missing data on the second disk (obviously _all_ of the data that&#8217;s on disk 1). Depending on how much data you already put onto the disk, this might take a while. You can still use the pool though, ZFS will eventually catch up, and you have an intact mirrored set of your storage. Now you may use the pool to its full potential. One thing to remember though, is to configure automatic scrubs every now and then. This is to make sure the data&#8217;s integrity is still given. I&#8217;ll might write another quick tutorial in a few weeks, once first scrub time comes around for me (me calendar is already marked for February 17 to take care of it).