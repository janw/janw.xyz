---
author: Jan
categories:
- Uncategorized
date: '2015-10-27'
guid: http://beta.janw.io/freenas-9-3-on-vmware-esxi-6-0-guide/
id: 46
slug: freenas-9-3-on-vmware-esxi-6-0-guide/
tags:
- esxi
- freenas
- server
- zfs
title: FreeNAS 9.3 on VMware ESXi 6.0 Guide

---

I am running a fairly decent home server for about a year now. I always struggled with the old out-of-the-box Synology NAS system since it was painfully slow and I didn&#8217;t like the software very much. So I built a server myself (as I built many many computers before) and set it up to run [FreeNAS](http://www.freenas.org/), an open-source NAS operating system based on FreeBSD. I really love the way it just _works_ and the machine it runs on has plenty of processing power to handle even the more elaborate tasks occuring in a small home network.

But that power idles around a lot of the time and even when I finally put some strain on the system, the processor (a XEON E3-1230 v3) barely maxes out. Running some other tasks (that I would normally have my home office&#8217;s computer do) inside of a FreeBSD jail didn&#8217;t turn out to work so well and while FreeNAS is great when it comes to bare storage, it is kind of restricted when you want to go beyond just that. And all that made me a little sad until I finally stumbled upon Ben&#8217;s blog, where he writes about a lot of storage and server related things. And it presented to me the perfect solution to try: [Running FreeNAS virtualized on top of VMware&#8217;s ESXi hypervisor](https://b3n.org/freenas-9-3-on-vmware-esxi-6-0-guide/).

<!--more-->

The setup is quite elaborate (at least in relation to: take a computer, plug some hard drives into it, and done), and requires a dedicated PCIe -RAID- storage controller but after all it&#8217;s really worth the hassle and a small investment! I can now run multiple (otherwise dedicated) systems on ESXi and my server is finally put to _actual_ use.

So if you care about the storage and configurational capabilities of FreeNAS but have a capable machine to run more than just that (or if you are just interested in storagy stuff, take a look at Ben&#8217;s site. I&#8217;ll probably write up something about my current ESXi setup very soon, especially since I got OSX Server running on &#8220;not exactly suitable&#8221; hardware aswell &#8230;