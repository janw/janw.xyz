---
categories:
- Tinkering
date: '2017-08-21'
id: 340
slug: mqtt-enabling-the-elv-ws-300-pc-ii-weather-station-using-raspberry-pi
tags:
- home assistant
- mqtt
- raspberry pi
- rx868
title: MQTT-enabling the sensors of an old ELV WS 300 PC II Weather Station using the Raspberry Pi
author: Testi
---

For years I have been using an old ELV WS 300 PC-II weather station (also known as eQ-3 WS PC-II) to measure temperature and humidity levels in parts of our flat. Mostly to quantify the effectiveness of our airing habits. Something that always annoyed me about the base station is its interface: it has a USB port at the back, and comes with a crummy Windows tool for collecting the data. Not very smart and not very connected. I&#8217;m a big fan of [Home Assistant](https://home-assistant.io), a Python-based smart home / connected home framework, and I already run all of my smart home efforts through that. My credo is: If there&#8217;s no Home Assistant component for it, it does not exist. In this post I am going to connect the WS 300 (or parts thereof) to Home Assistant using the MQTT protocol.

<!--more-->

Until now I stuck to using the USB interface to read the data. There&#8217;s even a [perl script to read from the station](https://github.com/mommel/weatherpi), and I adapted it to pipe the data into Home Assistant. Nonetheless it annoyed me being bound to the WS 300: using the USB connection is a bit too hacky and the adaption of the read-out script failed from time to time. And … it&#8217;s perl.

For a while I have tried building other temperature/humidity sensors myself, using ESP8266 Wifi-connected micro controllers, and DHT22, and BME280 sensors—with mediocre success. Since next heating period is moving closer and closer, I finally want to have a solid solution again, and ditch the WS 300 in it&#8217;s current form entirely.

Thankfully the WS 300 connects to it&#8217;s probes via the popular 868 MHz band. It _is_ using a proprietary protocol but that has already been [reverse-engineered](http://www.dc3yc.privat.t-online.de/protocol.htm), and another friendly dude has also published [code on GitHub to use an individual 868 MHz receiver](https://github.com/skaringa/TempHygroRX868) for receiving the probe data, and decoding it. I figured it might get me going to disassemble the WS 300 base station, and check out if I could get better access its internal receiver data. And I hit a jackpot: the base station&#8217;s RF receiver turns out to be a run-of-the-mill [RX868-3V sold by ELV](https://www.elv.de/controller.aspx?cid=683&detail=10&detail2=416748), soldered on to the main PCB. It is almost structurally identical to what the lib on GitHub expected to work with. All that&#8217;s missing is a pull-up pad to disable and enable the receiver entirely. Removing the receiver module was a piece of cake, and the pinout was perfect to create a simple &#8220;module&#8221; to plug onto the Raspberry Pi.

{{< fig src="/media/IMG_4568.jpg" title="Raspberry Pi with the RX868 module attached to the GPIO connector">}}

After I checked the available tool to be working—which it did out of the box—I got to work to turn it into an MQTT daemon. Luckily I worked on a [MQTT daemon in Python](https://github.com/janwh/miflora-mqtt-daemon) before, and repeating the effort in C++ wasn&#8217;t that hard. Just a matter of refreshing my C skills. Which were a bit rusty. Anyhow.

Forked from the original, I created a [repository for the RX868 MQTT daemon](https://github.com/janwh/rx868-mqtt-daemon). On the off-change that someone might benefit from my efforts (which I doubt, since the WS 300 PC-II has been discontinued for quite a while now), have fun with it and drop me a message, if you like!