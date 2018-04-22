---
author: Jan
categories:
- Tinkering
date: '2017-07-28'
guid: http://beta.janw.io/figuring-out-the-whatapp-database-format/
id: 32
slug: figuring-out-the-whatapp-database-format/
tags:
- blobstorage
- database
- sqlite
- whatsapp
title: Figuring out the WhatApp database format

---

I&#8217;m currently fiddling with the WhatsApp `ChatStorage.sqlite` database that I extracted from a recent local iOS backup. I want to parse the contents into properly marked-up <span class="caps">HTML</span> files, and store them outside of the iOS backup. To become more independent from the iOS backup and WhatsApp itself

I already got pretty far (massively improving my SQL skills in the process), but of course I want to add as much context to the messages as possible. WhatsApp saves the metadata for media items (namely links, replies, image thumbnails) for messages in the `ZWAMEDIAITEM.ZMETADATA` column of the database. On iOS this column contains blobs of binary property lists, that can be inspected on MacOS using the `plutil` tool. Still there is some figuring-out for me to do, and I&#8217;d like your help for that.

<!--more--><figure style="width: 658px" class="wp-caption alignnone">

<img src="https://i1.wp.com/blerch.janw.io/images/plutil-output.png?resize=525%2C440&#038;quality=100&#038;strip=all" width="525" height="440" class="size-medium" data-recalc-dims="1" /><figcaption class="wp-caption-text">Output of macOS&#8217; plutil</figcaption></figure>

Among other things, it contains the `senderJID` (JID standing in for Jabber ID since WhatsApp was built on Jabber) of the referenced metadata. The thing that I am really after is the `quotedMessageData` field. It contains a lot more data. For replies for example it contains the text of the message your reply was referring to. When the metadata contained a link, and WhatsApp managed to scrape a link preview of the web, the field contains all stuff you would need to rebuild that preview: the link itself, the contents of the HTML `<title />` tag, and a tiny thumbnail image.

It&#8217;s all clearly visible when viewed in a hex editor, the text, the link, the [magic number](https://en.wikipedia.org/wiki/Magic_number_(programming)) of the thumbnail JPEG (`FF D8`/`0xFF 0xD8`) but even after hours of fiddling and researching binary message and serialization patterns, control characters and the like, I can&#8217;t seem to fully figure it out. After all it&#8217;s the first time I&#8217;m dealing with this sort of things. Things that are quite apparent:

  * The first byte signals how the message will look like.
      * `0x0A` (Line feed): the element is plain text. If this is the very first byte of the blob, there no other control code after the ULEB128 (see below), the element begins right away
      * `0x32`: drop-in for `0x0A`, except there _will_ be more than one element?
      * `0x1A` (Substitute character):
      * `0x7A`: the element is a senderJID
      * There are a few other characters that seem to act as control codes (`0x42`, `0x22`, `0x20`) but I can&#8217;t figure out, _why_ they are used instead of another LF. Probably to distinguish between datatypes or to initiate some sort of nesting?
  * The next _n_ bytes after a control code seem to always belong to a [ULEB128](https://en.wikipedia.org/wiki/LEB128#Unsigned_LEB128) defining the length of the next part. Trying out different positions in different files it almost always matches up towards the next human-differentiable part of the blob. But not _always_ always, so there must be another trick here
  * (Also I guess magic happens?)
  * Whenever the sequence `0x82 0x01` occurs, it marks the beginning of a JPEG image. It&#8217;s length is defined by another ULEB128 following the sequence. Directly after that, the JPEG starts with its magic number. Writing the data out to disk, always results in a properly readable image.
  * `0x22` followed by `0x20` (doublequotes followed by a space) seems to have a special meaning as well. Maybe it ends a section?
  * Now, that I am seeing all this in one place, I realize that looking at bytes might be a bit to coarse. Maybe it would help to check out the nibbles instead?

That&#8217;s all I got so far. Maybe someone else wants to jump in and, help me? I prepared a few binaries, redacted personal info from them and uploaded them [here]({filename}/downloads/whatsapp-blobs.zip). Take a stab at them and message me at <uleb128@janw.io>. I&#8217;ll update this post, as soon as I get new info.