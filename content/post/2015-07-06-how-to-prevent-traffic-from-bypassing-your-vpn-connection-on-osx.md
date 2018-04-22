---
author: Jan
categories:
- Tutorials
date: '2015-07-06'
guid: http://beta.janw.io/how-to-prevent-traffic-from-bypassing-your-vpn-connection-on-osx/
id: 51
slug: how-to-prevent-traffic-from-bypassing-your-vpn-connection-on-osx/
tags:
- firewall
- mac os x
- vpn
title: How to prevent traffic from bypassing your VPN connection on OSX

---

situations just cry out for adding an additional layer of security to your internet connection. Like sitting in a café or visiting congresses and using their respective complementary WiFi.

If you are a tech-savvy paranoid like me, you soon start thinking about leaks in your otherwise perfectly well chosen and configured VPN service. Two of those are [DNS leaks](https://www.dnsleaktest.com/what-is-a-dns-leak.html) or (probably worse) actual traffic leaks that occur between the time your WiFi connection is established and the moment the VPN connections catches up. If the WiFi is a little patchy, those scenarios might occur even more often than just when you enter the area of coverage and your programs end up sending a lot of packages through the unprotected network because the VPN is still trying to reconnect properly.

This is actually the time where a proper firewall comes in handy and based on this [answer on our beloved Stack Exchange](http://superuser.com/q/468919) I figured out a setup that works well for me on Mac OSX using an OpenVPN server and Viscosity as the client-side software. So I thought I&#8217;d share it!

<!--more-->

Center of it all is `pf`, packet filter, the firewall software originating from OpenBSD that ships with OSX and a few other unixoids by now. We&#8217;ll modify its config file that resides in `/etc/pf.conf`. Again, Kudos to the above-mentioned answer on Stack Exchange as I took most of the firewall config file from there. Below you see my example configuration. You just have to append that to the conf file.

    wifi=en1 # <- en0 for Macs with no ethernet jack
    vpn=tun0
    vpn2=tap0

    # Block everything
    block all

    # But allow local traffic
    set skip on lo

    # Allow AirDrop and AirPrint as well
    pass on p2p0
    pass on p2p1
    pass on p2p2
    pass quick proto tcp to any port 631

    # Allow mDNS multicast (used to detect wifi status)
    pass on $wifi proto udp to 224.0.0.251 port 5353

    # Allow DNS requests to specific servers
    pass on $wifi proto udp to {46.246.46.246, 194.132.32.32} port 53

    # Allow establishing connection to VPN provider
    pass on $wifi proto udp to 46.246.32.0/19 port 1194

    # Allow traffic through VPN interfaces
    pass on $vpn
    pass on $vpn2


Upon saving the config file, you need to enable `pf` and force it to read-in the file. Be aware: after that you won&#8217;t be able to connect to the internet without having configured your VPN client properly.

    sudo pfctl -e
    sudo pfctl -f /etc/pf.conf


Still, disabling is of course possible using `sudo pfctl -d`. With `pf` active and your VPN disconnected, you should not be able to reach any websites, nor read connect to email servers or anything. If you&#8217;re not greeted with the appropriate errors, check the config and if `pf` is actually running and has read the config file.

Lastly, connecting to your VPN requires you to statically set DNS servers in your system&#8217;s network config because otherwise your VPN client won&#8217;t be able to resolve the server&#8217;s hostname. My advice would be to use a DNS server provided by your VPN service. Or one from [OpenDNS](https://www.opendns.com/home-internet-security/opendns-ip-addresses/).

If in addition you want `pf` to be started at boot time, you have to modify its launch daemon:

    sudo nano /System/Library/LaunchDaemons/com.apple.pfctl.plist


In the `ProgramArguments` array, exchange `-f` for `-ef`, and you&#8217;re good to go: `pf` will start automatically preventing any connections right from the start, until you connect to your VPN provider.