---
categories:
- Tutorials
date: '2016-05-16'
id: 37
slug: finally-some-peace-of-mind-my-2016-storage-and-backup-setup
tags:
- archiving
- backups
- freenas
- server
title: 'Finally some peace of mind: my 2016 storage and backup setup'

---

For many years I have spent quite a lot of time figuring out ways to savely store my data. Many iterations have past by now, but recently I have finally reached a stage that is worthy of talking about.

For a few years I have been running a decent homeserver (a.k.a NAS) handling the heavy lifting when it comes to mass storage. The machine is fairly powerful for what it does; a Xeon E3-1230 v3, 16GB of ECC RAM, and 9TB of raw storage configured as a ZFS pool running in RAIDZ1 (meaning one drive may fail and the pool can still be rebuilt—the superior RAID5 equivalent in ZFS). The server mostly handles SMB shares in my local network. I am not good at deleting stuff, so I rather push stuff from my &#8220;daily driver&#8221; down onto the NAS to free up some space while still keeping an extensive archive of all my files.

<!--more-->

And I _do_ value such an archive. I have had so many situations where access to decade-old data was of (at least sentimentally) priceless value. I would not want to lose that data, which is the reason I spend so much time tinkering with my storage methodology. So far the RAIDZ1 storage pool felt fairly safe: the parity information assures me that I will recover from single-disk failure in a reasonable amount of time without any dataloss. The risk of a second disk failing in that recovery timeframe is still high but surviving a single disk failure is better than surviving none. A more subtle risk though —one that is often forgotten in layman backup scenarios— is a complete system failure. This possibilities are virtually endless, reaching from two disks failing simultaneously to the whole house burning down. The consequences are still the same: complete data loss.

This was the reason for me to implement a second level into my backup stragey: offsite storage. Until today I have used [BitTorrent Sync](https://getsync.com/) as a way to provide multiple levels of redundancy for the most critical data I have. With at least three machines constantly being in sync the tool gives easy access to &#8220;offsite storage for the masses&#8221;, just like Dropbox does for other people. The only (but major) difference being that _I_ do control the servers used to store the data. This works out fairly well for some things but might not always be the most sensible thing. First off it is unwieldy to push around hundreds or just tens of Gigabytes using BTSync. And secondly I don&#8217;t want to have changes synced constantly for backing up data, and with BTSync there are no &#8220;defined states&#8221; of the data, there is just the most current version, and if that changes here, it will change as well for the file stored on the machines in sync. Yes, technically there is an archival functionality in BTSync, that _does_ provide versioning for files. However the versions are too arbitrary for my taste and the integration into the application is not as good and customizable as I&#8217;d like it to be.

Enter ZFS snapshots. ZFS (amongst a _ton_ of other things) implements an extremely powerful paradigm to create a customizable version history of entire storage pools within minutes from figuring out the commands. The snapshots are instantaneous and can be rolled back within seconds if need be. Everything is directly integrated into the file system and therefore entirely agnostic in terms of _what_ is stored. And to put a cherry on top of that huge ice cream cone: snapshots are serializable so that they can be easily transferred over the network. Using a send-receive mechanism, just like any unix admin loves stuff to be handled: Pipes. Pipes everywhere.

Using this strong toolage the entire history of a dataset can be rebuilt on a second device using a `zfs send`-serialized, then piped into ssh, then piped over the internet into an offsite server at my parents house, and finally into `zfs receive`, creating a 1:1 replication mechanism for storage pools. Of course it even supports incremental updates, by which only changes between the two states of the local and remote storage pool are transferred—and since ZFS is that damn smart: doing so on a block-level. Even changing stuff in a virtual machine image will not cause the entire image to be transferred over and over again but only the file system blocks of ZFS underneath. Super simple, super smart.

It took me a while to figure all that out, and how enormously useful this can be in an offsite backup scenario. Sometimes it takes time to widen the horizon. But now it blows me away having it all layed out, deployed, and working flawlessly. Currently my setup looks like this:

  * Most of my data is stored on my onsite storage server. This includes Time Machine backups, my digitalized music collection, document archives, my entire photography library in RAW, etc. First-level data protection is given by the RAIDZ1 with a cron-ed weekly scrub job, and SMART tests every 5 (short) to 14 (long) days.
  * Time Machine backups are enabled on all Macs in the household
  * My laptop has an additional daily rsync job configured for my local home directory, which is pushed to my onsite storage to have a backup that is universally readable (Time Machine on the other hand is based on Apple-developed sparsebundle files, requiring a Mac to extract data).
  * All datasets on ApfelNas are set up for daily snapshots
  * Every night, a replication task creates a 1:1 backup to the offsite server. This only includes content that I consider &#8220;irreplaceable&#8221;: home directories, RAW photography, important documents, etc. Content that can be restored from physical media (such as my digitalized music) is excluded, and so are Time Machine Backups (yet).
  * Offsite storage is equipped with a slightly smaller but mirrored storage pool (so probability-wise even better protection than on my local NAS). The machine is configured to only handle nightly replication, and does nothing except for the regular data integrity checks (SMART checks, scrubs).
  * Both onsite and offsite server are also BTSync nodes to bathe myself in that sweet sweet &#8220;personal cloud storage&#8221; feeling.

All in all I am extremely happy with how—after years of fumbling with the matter—things turned out. The solution is simple, elegant and relatively low on maintenance. In case of disaster on either the onsite or offsite location I can easily regain access to my data, since it&#8217;s stored within an hour driving distance from each other. If a disk fails anywhere I&#8217;ll be emailed by FreeNAS automatically, and the parity on both ends will increase the odds of rebuilding the failing pool before another drive one fails. [FreeNAS](http://www.freenas.org/) in general is quite amazing for all this. All the mechanisms for replication, setting up cron jobs, emailing about errors, etc. are built right in. If you want a server to just handle storage and be stable and of consistent behavior throughout: go for FreeNAS. I am not without experience using and configuring a raw FreeBSD and doing all that by hand. But who doesn&#8217;t like a little help getting things done?

And ultimately this whole post is just the peace of mind talking. Please excuse the self-assured long post but I am proud of the progress, and I love sharing the knowledge earned. If wanted I gladly go into more detail in the comments. By the way: The [HP ProLiant MicroServer](http://www8.hp.com/de/de/products/proliant-servers/index.html#!view=grid&page=2&facet=ProLiant-MicroServer) is the _perfect_ choice for someone just starting out in the personal storage domain. I used it to setup the offsite server unit. Big recommendation for that as well!