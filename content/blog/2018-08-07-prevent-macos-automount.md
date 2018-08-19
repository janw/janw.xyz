---
title: "Prevent macOS from automatically mounting external drives"
date: "2018-08-07T16:06:37+02:00"
---

Just recently I have added an external USB harddisk to my desktop setup. I keep my Lightroom photo library on it, since keeping the photos on my NAS and mounting that to work on the pictures is just too slow.

Obviously I am not spending every day working on those pictures, just every now and then, yet still I'd like to keep the HDD connected to the [OWC USB-C Dock](https://www.owcdigital.com/products/usb-c-dock) that connects all the accessories to my MacBook Adorable (a differentiating phrase initially [coined by David Smith](http://podsearch.david-smith.org/episodes/1143#1108)) when I'm seated. What can I say — I am lazy … and have a second APFS volume on the same HDD that contains a bootable backup of macOS. [Super Duper](https://www.shirt-pocket.com/SuperDuper) creates that backup every other day. And I'd like it to do so even if I forget to attach the HDD. The most simple approach is therefor the leave it attached.

MacOS does not like it though to just randomly pull plugs of external disk drives when, for example, you are quickly unplugging the Mac to head to the next appointment.

Therefore I went about and setup macOS to take note of the HDD but not mount any volumes from it. How? Using good old UNIX magic: `/etc/fstab`. Altough not officially supported, macOS allows users to create an fstab file for custom mounts, for network attached drives for example. But one may also use fstab to customize the automatically mounted volumes of USB drives. The syntax is just the same as it has ever been with fstab; yet the easiest way to prevent automounting your USB hard drives is to use their volume's `LABEL=` or `UUID=`, both of which can be found by consulting `diskutil`:

    $ diskutil list
    …
    /dev/disk2 (external, physical):
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:      GUID_partition_scheme                        *4.0 TB     disk2
    1:                        EFI EFI                     209.7 MB   disk2s1
    2:                 Apple_APFS Container disk4         3.0 TB     disk2s2
    …
    /dev/disk4 (synthesized):
    #:                       TYPE NAME                    SIZE       IDENTIFIER
    0:      APFS Container Scheme -                      +3.0 TB     disk4
                                  Physical Store disk2s2
    1:                APFS Volume Photos                  338.3 GB   disk4s1
    2:                APFS Volume SuperDuper Backup       218.7 GB   disk4s2
    3:                APFS Volume Preboot                 19.5 MB    disk4s3
    4:                APFS Volume Recovery                526.8 MB   disk4s4
    5:                APFS Volume VM                      20.5 KB    disk4s5
    …

Note the output of `diskutil list` contains an APFS container reference to `/dev/disk4` in `/dev/disk2s2`. The more granular approach is now to lookup the `UUID`s of one or more the APFS volumes in disk4:

    $ diskutil info disk4s1
    Device Identifier:        disk4s1
    Device Node:              /dev/disk4s1
    Whole:                    No
    Part of Whole:            disk4
    Volume Name:              Photos
    Mounted:                  No
    …
    Volume UUID:              CD8A004A-295C-4ECF-8A36-8DAD2AF4FA63
    Disk / Partition UUID:    CD8A004A-295C-4ECF-8A36-8DAD2AF4E163
    …

The `Volume UUID` is what we are looking for. Repeat for all volumes of interest, note all `UUID`s, and move on to creating `/etc/fstab` (with superuser privileges) now:

    $ sudo vim /etc/fstab

Now add the volumes to it, with the following fstab parameters:

    # Prevent Photos volume from automounting
    UUID=CD8A004A-295C-4ECF-8A36-8DAD2AF4FA63 none apfs rw,noauto
    # Prevent SuperDuper Backup volume from automounting
    UUID=86C0607D-FFC2-4391-9194-2F04691D3AAF none apfs rw,noauto

`noauto` tells diskarbitrationd (the daemon that handles the … well, the arbitration of attached disks) to not automatically mount the disk. The next time the HDD gets plugged in, the Volume will only be visible inside of Disk Utility, where it can then be manually mounted. If you prefer the way of the command line, `diskutil mount <LABEL>` or `diskutil mount <UUID>` will also mount the drive.

As long as you do not mount the drive manually (see [Caveats below](#caveats)), it is now safe to unplug the HDD at any time without macOS bugging you with "Disk Not Ejected Properly" error notifications.

## Caveats

* Obviously you would want to unmount the volume manually after use. The fstab entry only prevents mounting upon *first* attaching the disk. If you would want to have all disks unmounted automatically when putting your Mac to sleep, take a look at [Jettison](https://www.stclairsoft.com/Jettison/index.html), which not only allows you just that; you'll also have shortcuts for *mounting* disks right in your menubar.
* It is possible to use `LABEL=` instead of `UUID=` to prefix the fstab line (use the volume's name following it, for example "Photos" but, since that is not a unique identifier (other volumes can have the same name), I would advise against that.
* In case you have a "legacy type" volume (i.e. formatted with HFS+ filesystem) that you want to not automount, replace `apfs` with `hfs`.

## Final note for SuperDuper users

If you use Super Duper to create backups on a schedule, preventing automount for it's backup volume will prevent accidental unplugs, but also the backup from being created. I have created tiny bash script to mount the backup volume, and added that in Super Duper's Advanced Options under "Run shell script before copy starts".

    #!/usr/bin/env bash
    diskutil mount "86C0607D-FFC2-4391-9194-2F04691D3AAF"

This should also work for users of [Carbon Copy Cloner](https://bombich.com) and other backup tools that have an option for running a shell script before launching. Also: creating a second shell script for *after* backing up works the same way. Just replace `mount` with `unmount`. 👋
