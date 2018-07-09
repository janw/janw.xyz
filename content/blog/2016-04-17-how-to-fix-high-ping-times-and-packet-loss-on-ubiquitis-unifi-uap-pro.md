---
categories:
- Tutorials
date: '2016-04-17'
id: 39
slug: how-to-fix-high-ping-times-and-packet-loss-on-ubiquitis-unifi-uap-pro
tags:
- ubiquiti
- unifi
- wlan
title: How to fix high ping times and packet loss on Ubiquiti’s UniFi UAP-PRO

---

Recently I noticed connections through my Ubiquiti [UAP-PRO](https://www.ubnt.com/unifi/unifi-ap/) access point would become terribly slow ever so often. At first I put it off as an interference problem but today I could not take it any longer. I took a look into the problem and now present a solution to help other UAP-PRO owners with such periodical slow connections.

<!--more-->

### The problem: horribly flaky WiFi

Full disclosure though—this basically a recap of something that has been solved elsewhere by other people in multiple forum postings. I&#8217;m just trying to distill the information into something others may find easier to read. All sources are of course properly linked.

So far I have been pretty happy with the Ubiquiti hardware, I have never had such good WiFi speeds and strong connections even through multiple concrete walls, and all was well so far. Nonetheless problems started to appear recently. Every once in a while (with seemingly increasing frequency) the connection via WiFi would become terribly slow up to the point were it practically felt like the whole internet connection was down. The slow connection manifested in a tremendous amount of packet loss and ping times of up to multiple seconds. After a few minutes everything would go back to normal without doing anything. I cannot really tell if the problems have been there right from the beginning and I did not notice it before, or if it just came up with a recent firmware update. Just for future reference: my UAP currently runs firmware version 3.3.19.4015.

### The solution: disable power saving features

Googling for high ping times and packet loss in connection with the UAP-PRO brought up more people having the same problem with [threads on the Ubiquiti community forum dating back as far as 2014](https://community.ubnt.com/t5/UniFi-Wireless/UAP-PRO-High-Latency-Packet-loss/td-p/1057541). The problem seems to be with the UAPSD, or Unscheduled Automatic Power Save Delivery, which is used in wireless devices to … well, save power. Obviously that feature is going rogue on some occasions, so it seems to be the best solution for now to just disable the feature. I can do very well without the power savings if instead the WiFi is strong and stable. As a temporary fix, a [user on the forum ran the following commands](https://community.ubnt.com/t5/UniFi-Wireless/UAP-PRO-High-Latency-Packet-loss/m-p/1068449/highlight/true#M79757) on the directly accessed shell of the access point resulting in immediate improvements:

    iwpriv ath2 uapsd 0
    iwpriv ath2 wmm 0


I was able to reproduce the results when applying the settings to `ath0` and `ath1` as well. Great! But manually applied `iwpriv` settings are reset whenever the access point is rebooted or (re)provisioned. So to actually solve the problem long-term, one has to add the corresponding setting to the provisioning profile for the WiFi site. At this point it becomes crutial to have an instance of the Ubiquiti UniFi Controller software running for management and statistics, which provides an easy way to apply custom settings to your access points through the `config.properties` file. And luckily there is a good explanation by Ubiquiti on [how to set up a config.properties file for your UniFi Controller](https://help.ubnt.com/hc/en-us/articles/205146040-OD-UniFi-What-is-the-config-properties-file-). For you FreeBSD admins, running the unifi controller from the ports, the files live under `/usr/local/share/java/unifi/data/sites/<sitename>/config.properties`. Once the file is created you just have to add the following lines to it:

    config.uapsd_enabled=false
    config.wmm_enabled=false


The UniFi controller will pick it up and use the settings whenever an access point is restarted or (re)provisioned, thereby disabling UAPSD for all wireless devices on that specific managed site. So far I can not tell how significant the difference in power consumption is with the UAPSD disabled. I will do some measurements in the next few days and update this post accordingly. Until then have fun with your non-flaky WiFi!