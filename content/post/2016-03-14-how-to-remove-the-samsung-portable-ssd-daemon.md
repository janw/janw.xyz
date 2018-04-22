---
categories:
- Tutorials
date: '2016-03-14'
id: 40
slug: how-to-remove-the-samsung-portable-ssd-daemon
tags:
- samsung
- ssd
- t1
title: How to remove the Samsung Portable SSD Daemon

---

I recently got myself a Samsung Portable SSD T1. Basically a fantastic product, finally some SSD-based storage for even the tiniest pockets. I really like carrying like 3-4 USB thumb drives with me when I&#8217;m on the go, since there is _always_ something to copy, and or reinstall or whatever.

Anyhow, after unpacking the T1, the first thing you need to do is set it up. It comes with some <strike>fucked-up</strike> proprietary encryption software that is (of course) only compatible with the proprietary two of popular operating systems (Windows and Mac). So it&#8217;s the first thing I get rid of. But even if you _don&#8217;t_ want to use the encryption you still have to click through some weird setup assistant, and only after that will you be able to actually _use_ the drive.

What you might not notice is the setup assistant instatiating a daemon for handling the encryption. Yes, even though you selected _not_ to encrypt the drive. And—as you&#8217;d expect proper bloatware to behave—it doesn&#8217;t come with an uninstaller or other removal tool. I still managed to remove that thing and here is how:

<!--more-->

### Windows

Open the taskmanager, and kill the &#8220;Samsung Portable SSD Daemon.exe&#8221; task. Now run &#8220;Taskschd.msc&#8221; via WIN+R or the &#8220;Run &#8230;&#8221; menu in the start menu to open the task scheduler. Inside the library that opens up look for &#8220;Samsung\_PSSD\_Registration&#8221; and delete the entry. Finally open Windows Explorer, navigate to `C:\ProgramData` and delete the &#8220;SamsungApps&#8221; subdirectory. Congratulations, you removed that sonbitch!

### Mac OS X

On OSX, Samsung even installs something that looks like a SMART driver for the SSD. Don&#8217;t get me started. To remove it, open &#8220;Terminal.app&#8221; (in `/Applications/Utilities/` folder, or via Spotlight), and paste the following two lines:

    sudo rm -r /System/Library/Extensions/SATSMARTDriver.kext
    sudo rm -r /System/Library/Extensions/SATSMARTLib.plugin


That should remove the kernel extension. Now for that stupid daemon: first unload and remove the daemon&#8217;s launcher:

    launchctl unload ~/Library/LaunchDaemons/com.srib.pssddaemon.plist
    launchctl remove ~/Library/LaunchDaemons/com.srib.pssddaemon.plist


And finally, remove the Daemon itself:

    rm ~/Library/PortableSSD/Samsung\ Portable\ SSD


### Conclusion

You should now be freed of what Samsung deems the right amount of annoyance when buying their products. I mean seriously, their hardware quality and design speak for themselves, and do not require poorly implemented and probably never updated software components. Cobbler, stick to your last, godammit!