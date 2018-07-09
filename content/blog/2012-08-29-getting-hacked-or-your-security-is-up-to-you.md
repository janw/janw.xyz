---
categories:
- Op-Ed
date: '2012-08-29'
id: 57
slug: getting-hacked-or-your-security-is-up-to-you
tags:
- logins
- passwords
- social hacking
title: 'Getting hacked, or: Your security is up to you'

---

Yesterday I stumbled upon a [series](http://www.wired.com/2012/08/apple-amazon-mat-honan-hacking/) [of](http://www.slate.com/articles/technology/technology/2012/08/mat_honan_the_four_things_you_need_to_do_right_now_to_avoid_getting_hacked_.html) [articles](http://www.wired.com/2012/08/mat-honan-data-recovery/) from and about [Mat Honan](http://www.wired.com/gadgetlab/author/mathonan/), a tech journalist at Wired. He recently got some of his most important accounts hacked, including his Gmail, Twitter and especially his iCloud account, which enabled the hackers to remotely wipe his iPhone, iPad and MacBook with lots of invaluably precious data on it, like photos of his young daughter that were never backed up.

> And then, one of my hackers @ messaged me. He would later identify himself as Phobia. I followed him. He followed me back. We started a dialogue via Twitter direct messaging that later continued via e-mail and AIM. Phobia was able to reveal enough detail about the hack and my compromised accounts that it became clear he was, at the very least, a party to how it went down. I agreed not to press charges, and in return he laid out exactly how the hack worked.

I tried to stay unbiased while reading the article, because I know how it hurts to lose important data. But I couldn’t. I am a security and backup nerd and in my honest opinion, someone leaving their machines without backup —especially considering the background Honan has in the tech journalism and the sensitivity of the data— is just foolish. So I allow myself to make a seemingly harsh judgement: In a way he had it coming.

<!--more-->

But I am on his side when it comes to the screw-ups of other involved parties. There sure is something wrong with the security policies at Apple and Amazon and I, as a customer of both of them, am very angry they pull off something like that. Frankly I never liked the idea of possible password resets via phone, because it brings in one more human interaction that would not be necessary. Human interaction leads to failure and that is the least you want, if your account contains vital information, like your credit card data or is empowered with major security mechanisms, like Find My Mac/iPhone that can be used to remotely erase large amounts of important data in just a few clicks.

Honan is right, this entire shindig would not have been possible if those two companies would have had their security bullet-proofed. But they’re not alone to blame and Honan admits that, too. The minute I heard about [Google’s 2-step verification](https://support.google.com/accounts/bin/answer.py?hl=en&answer=180744&topic=1056283&rd=1), I was already hitting the Google settings and was enabling it. Same thing just happened a few days ago with Dropbox as they [introduced 2-step verification](https://blog.dropbox.com/index.php/another-layer-of-security-for-your-dropbox-account/) to their accounts. Heard of it, enabled it. Seriously, it’s just that simple for me. There is no reason to think twice on things like this, only a reason to authenticate twice and this hack holds up to be that reason.

To clear something up: Honan did get most of his data back. The next article explains how accounts on Google are not wiped completely the second you hit “delete”. There are ways to recover your data on services like Gmail. But it is a pain-in-the-ass procedure, answering a long … looong list of questions in online forms to make sure, you previously owned the account.

> Getting data back from a SSD drive, like the one in my MacBook Air, is considerably trickier than recovering it from a standard HDD for all kinds of reasons — from the way SSDs reallocate data, to the lack of a physical platter, to hardware-level encryption keys. I wasn’t about to attempt to recover it myself. Max, my guy at the Apple Store, had suggested that I call DriveSavers.

As you see recovery is not always possible. About 25% of the data was lost, since the remote wipe had already processed that much of the hard drive. And once wiped, you will _never_ get any of it back. That is just a fact. Honan was lucky the Apple genius was so helpful to interrupt the wiping process so DriveSavers could attempt to recover the non-wiped data. And he was even more lucky he haven’t had FileVault 2 enabled. In this case the wiping process would take only a quick reboot and the data would have been lost within seconds, since the wiping process then only consists of erasing the encryption key of FileVault.

Well, I have my Mac secured with FileVault. Every file on the hard drive is encrypted and can only be used when I unlock the encryption layer with my password. So I would be screwed if the hard drive would be remotely wiped by mistake or attack, right? Wrong. Because I do backups.

As I explained earlier, I am a cautious guy. Not only I do enable every possible extensive security features on accounts I have around the web. I also keep two full backups of the data that is on my machine. One is a Time Machine backup, kept on an encrypted partition on my NAS and a second one is a bootable backup, created with [Carbon Copy Cloner](http://www.bombich.com) on an encrypted external hard drive. The Time Machine backup of course is always as up to date as possible. Maximum amount of lost data: The stuff I was working on in the last hour or maybe a few days when I haven’t been at home and could not do the backup. The bootable backup is not _that_ up to date, but I get reminded of plugging in every few days and that way, even if my Time Machine backup would die the same time my Mac&#8217;s content is compromised, I would only lose a few days worth of data.

All three systems failing simultaneously would be a nightmare. The worst case scenario, like hell freezing over. But lets be honest: that is highly unlikely to be happening. And that unlikeliness didn’t cost me a fortune. Everyone can afford that kind of backup plan, especially if being an established tech journalist for the last decade or more. 😉

So what I am trying to, is to make a point. We live in a connected world. Every service can somehow be linked to another and by that the one&#8217;s flaw can fuel another one’s flaw. And pretty soon, bad things can and probably _will_ happen. If you are registered with tens of dozens of accounts on the web, one of them is always the weakest and is very likely to become the stepping stone for a successful exploit.

Yes, you probably can’t keep track all of your accounts’ security. But you should never lose track of the big ones. Remember accounts like Apple, Google, Amazon, Dropbox or Facebook and use every additional security feature they offer. Enable two-step verification wherever possible. I am sure that in near future even Amazon and Apple will make use of something like it and I think they have to. The account security they offer right now is just to weak.

If you ask me, the only way I would want some account’s password to be reset would be via an online form and only upon entering a much more information than just my address and a few credit card digits, or worse: only receiving an e-mail with a link. This kind of thing has to be bullet proof especially if sensitive data is involved. But lastly it’s the user who has to watch out for the flaws of his own security.