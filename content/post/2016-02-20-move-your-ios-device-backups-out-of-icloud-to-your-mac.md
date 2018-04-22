---
author: Jan
categories:
- Tutorials
date: '2016-02-20'
guid: http://beta.janw.io/move-your-ios-device-backups-out-of-icloud-to-your-mac/
id: 41
slug: move-your-ios-device-backups-out-of-icloud-to-your-mac/
tags:
- backups
- itunes
- mac os x
title: Move your iOS device backups out of iCloud to your Mac

---

So you might have heard about how the FBI is currently trying to push Apple to decrypt information on an iOS device owned by one of the San Bernadino terrorists. I&#8217;m not well at explaining such events, but there are lots of reports on the case, and [Gernot Poetsch wrote about the technical side of things](https://medium.com/@gernot/why-tim-cook-is-so-furious-be24163bdfa).

At the end of Gernot&#8217;s article there is a suggestion that privacy advocates have been screaming from the roofs ever since Apple drastically simplified iOS device backups by moving them to iCloud: Don&#8217;t use it. Any iOS device backups in iCloud are subject to any subpoenas or court orders that Apple might receive. And since they are not as encrypted as they are when done locally, they are practically like an open book to anyone holding a (really really big) grudge against you.

<!--more-->

Good news though: iTunes is still here and <strike>while being in generally bad shape</strike> it also still supports local backups for iOS devices. If you configured that instead of iCloud backups: good! Make sure not to miss the &#8220;encrypt local backups&#8221; checkmark as well. If you haven&#8217;t configured, that&#8217;s probably because triggering a new backup always requires you to manually open iTunes, click through to the device info, and hit the &#8220;Backup now&#8221; button. Let&#8217;s change that and move the stuff back to where it belongs: your own local data storage. All it takes is a Mac, and a little bit of scripting magic.

One of the most underrated capabilities of OS X is the rather good integration of Apple&#8217;s own basic scripting language, called Apple Script. With that you can trigger repetitive tasks, simplify workflows and handle applications as if you where clicking through their GUIs, but from the sweet home of your shell. iTunes is one of the applications having great coverage of Apple Script commands, and as you might have guessed, even backing up an iOS device can be done by a script. From that moment on it&#8217;s just a matter of selecting a time for the script to run, and you are basically done (almost) replicating the iCloud device backup experience.

The idea of introducing automation to iTunes syncing is pretty old already. Doug&#8217;s AppleScript Site contains postings from 2011 and 2012 [about how to sync your iPods/iPads/iPhones daily using Apple Script](http://dougscripts.com/itunes/2012/01/sync-a-wi-fi-iphone-follow-up/), and the scripts used down below are only slightly modified versions of his. So Kudos to him, but this deserves reiteration.

### Creating the Apple Script

The first thing you need is the script for handling iTunes. Compared to Doug&#8217;s version I basically added parts where iTunes would be launched when not already open, and a message to the system&#8217;s log. So we&#8217;ll create `/Users/janwillhaus/Library/iTunes/Scripts/Backup All Devices.scpt`. Or you know, rather the same for _your_ username. It will contain the following:

<pre><code class="applescript">do shell script "syslog -s -l notice Start syncing devices in iTunes"

if not checkItunesIsActive() then
    tell application "iTunes" to activate
    tell application "Finder" to set visible of process "iTunes" to false
end if

tell application "iTunes"
    try
        set theSources to (every source whose kind is iPod)
        repeat with src in theSources
            try
                with timeout of 600 seconds
                    if (get name of src) is in {"Jans iPhone", "Jans iPad"} then
                        tell src to update
                    end if
                end timeout
            end try
        end repeat
    end try
end tell

to checkItunesIsActive()
    tell application id "sevs" to return (exists (some process whose name is "iTunes"))
end checkItunesIsActive
</code></pre>

Make sure to add _your_ devices where I entered `"Jans iPhone", "Jans iPad"`. They have to match their name as it shows inside of iTunes. If you just want to backup all of your devices, remove the `if`-clause in

    if (get name of src) is in {"Jans iPhone", "Jans iPad"} then
        tell src to update
    end if


to make it

    tell src to update


The next time you open iTunes you&#8217;ll notice a new icon in the menu bar: The little script icon! Clicking it will reveal all available scripts from your iTunes Scripts directory, and: &#8220;Backup All Devices&#8221;. From this point on, you can initiate a backup of all devices from a single click. **Just make sure to initiate a backup manually once via the &#8220;Back Up Now&#8221; button in the Device Summary view.** It might be necessary to properly set-up the encryption passphrase etc. Moving on to automation!

### Running the Script using Launchd

This is where Launchd comes into play. Launchd is OSX&#8217;s framework for starting, running, supervising, and stopping services. We&#8217;ll use a Launchd agent to automate the execution of our previously created backup script. Each service is based on a launch agent script, which in turn based on a plist file (technically an XML file). That script tells Launchd when to launch the service, and (if needed) a ton more. Our agent `com.janwillhaus.iTunesDeviceBackups.plist` is fairly simple: it will execute the backup script and be done. The launch agent file will be placed in `/Library/LaunchAgents/`, the place for system-wide services. It contains this:

<pre><code class="xml">&lt;?xml version="1.0" encoding="UTF-8"?&gt;
&lt;!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd"&gt;
&lt;plist version="1.0"&gt;
&lt;dict&gt;
        &lt;key&gt;Disabled&lt;/key&gt;
        &lt;false/&gt;
        &lt;key&gt;UserName&lt;/key&gt;
        &lt;string&gt;janwillhaus&lt;/string&gt;
        &lt;key&gt;Label&lt;/key&gt;
        &lt;string&gt;com.janwillhaus.iTunesDeviceBackups&lt;/string&gt;
        &lt;key&gt;Program&lt;/key&gt;
        &lt;string&gt;/usr/bin/osascript&lt;/string&gt;
        &lt;key&gt;ProgramArguments&lt;/key&gt;
        &lt;array&gt;
                &lt;string&gt;osascript&lt;/string&gt;
                &lt;string&gt;/Users/janwillhaus/Library/iTunes/Scripts/Backup All Devices.scpt&lt;/string&gt;
        &lt;/array&gt;
        &lt;key&gt;StartCalendarInterval&lt;/key&gt;
        &lt;dict&gt;
                &lt;key&gt;Hour&lt;/key&gt;
                &lt;integer&gt;3&lt;/integer&gt;
                &lt;key&gt;Minute&lt;/key&gt;
                &lt;integer&gt;0&lt;/integer&gt;
        &lt;/dict&gt;
&lt;/dict&gt;
&lt;/plist&gt;
</code></pre>

This tells Launchd to run the applications `osascript` with the backup script as an argument. As noted by `<key>UserName</key> <string>janwillhaus</string>`, Launchd is actually executing this as if it was run by me. Make sure to replace `janwillhaus` with your own username (at two places), though. The `<dict>` underneath `StartCalendarInterval` tells Launchd when to execute the script. So when your are running iTunes on a home server like I do, it should be fine, to run it at a time when network traffic, and device usage probability is relatively low, for example 3:00 in the morning.

No for activating this, you could just wait for the next reboot of your machine, or initiate loading the launch agent by executing

<pre><code class="sh">launchctl load /Library/LaunchAgents/com.janwillhaus.iTunesDeviceBackups.plist
</code></pre>

at the Terminal: If you modified the launch agent plist and want to reload it simply enter

<pre><code class="sh">launchctl unload /Library/LaunchAgents/com.janwillhaus.iTunesDeviceBackups.plist
launchctl load /Library/LaunchAgents/com.janwillhaus.iTunesDeviceBackups.plist
</code></pre>

&#8220;So you plugged this in and you&#8217;re done!&#8221; If you want to see afterwards if backups have been created, check in iTunes in the iOS device info page, there is a &#8220;Last backup&#8221; reading. Also in Console.app, there will be a line logged stating `Start syncing devices in iTunes` that the backup script created. So there you go. Not that complicated, right? Of course it is not 100% equivalent to the ease-of-use of iCloud backups and it requires you to actually _want_ to use it, since you have to have a Mac running iTunes, only have it working in your home WiFi etc. But if you _do_ care about your privacy, and—in a way—your informational independence, this is the way to go.