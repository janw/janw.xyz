---
author: Jan
categories:
- Tutorials
date: '2016-05-25'
guid: http://beta.janw.io/properly-granting-access-to-datasets-in-jails-and-plugins-on-freenas/
id: 36
slug: properly-granting-access-to-datasets-in-jails-and-plugins-on-freenas/
tags:
- freebsd
- freenas
- unix permissions
- zfs
title: Properly granting access to datasets in Jails and Plugins on FreeNAS

---

Recently I wanted a FreeNAS plugin (which are running inside FreeBSD jails) to access data on my storage pool. Reading is generally less of a problem with the default settings but when it comes to writing, problems may occur. By default, my media datasets are running with `775` permissions, therefore:

  * The owner can read-write-execute
  * The group can read-write-execute
  * Others can read-execute.

The owner is `janwillhaus`, since I do all the management of the data and don&#8217;t want to run around sudo-ing all the time. The group on the other hand `media`, which may contain any other user that requires write-permissions to the files. All other users can at least read the files and that is fine.

<!--more-->

So users in the `media` group may also include tools that are installed inside of jails (or even inside FreeNAS plugin-jails, and those use their own groups and usernames, created when the plugin/tool gets installed. Even when you create a new group in the root environment (i.e. &#8216;outside&#8217; the jail) that has the same name as the one inside the jail, _and_ change group ownership of the desired share to _that_ group, it still won&#8217;t inherit the permissions inside of the jail, since it&#8217;s only the group&#8217;s _name_ that matches, but not the GID. The GID (group ID) is the number that the actual matching is done by. So to gain access, there are a few handy solutions that [Joshua shared on the FreeNAS forum](https://forums.freenas.org/index.php?threads/how-to-giving-plugins-write-permissions-to-your-data.27273/). I decided to go with Solution 3 &#8211; Group-writeable, since it makes the most sense for me:

In this case another group has to be create manually, that uses the same GID as the one with the wanted permissions in the root env. The best way to get the GID from the root env is to look it up in the FreeNAS GUI or use `id` in the root env:

    $ id media
    # uid=1006(media) gid=1006(media) groups=1006(media)


Now lets check the media _user_&#8216;s groups in the jail:

    $ sudo warden chroot awesomejail
    # id media
    uid=816(media) gid=816(media) groups=816(media)


As you see, the GIDs don&#8217;t match. So now we create another group inside the jail that actually _does_ match, and add the our &#8216;media&#8217; user to it:

    # pw groupadd -n media_root -g 1006
    # pw groupmod media_root -m media


Done! User &#8216;media&#8217; now inherits the permissions given by group `1006` (the root environment&#8217;s &#8216;media&#8217; group) and `816` (the jail&#8217;s &#8216;media&#8217; group), and therefore inherits write permissions on all shares that belong to the `media` group in the root environment.

Oh, and by the way: this should just as much work on FreeBSD with jails than it does with FreeNAS.