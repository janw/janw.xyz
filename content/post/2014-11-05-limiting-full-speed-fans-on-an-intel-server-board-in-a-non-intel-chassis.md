---
author: Jan
categories:
- Tutorials
date: '2014-11-05'
guid: http://beta.janw.io/limiting-full-speed-fans-on-an-intel-server-board-in-a-non-intel-chassis/
id: 52
slug: limiting-full-speed-fans-on-an-intel-server-board-in-a-non-intel-chassis/
tags:
- hardware
- server
title: Limiting full-speed fans on an Intel Server Board in a non-Intel chassis

---

I recently used an Intel S3200SHX Entry Server Mainboard build a new home server. While performing perfectly well for the purpose, in regards to temperature control the board is highly optimized to work with official Intel chassis and when put into a non-Intel case, the fans are running at full speed all the time.

<!--more-->

Fortunately, the fan speed can be controlled via the FRUSDR (Field Replaceable Unit/Sensor Data Record) configuration of the EFI BIOS. The Sensor Data Record has a lot of settings available for controlling the sensors inside the case etc. The settings can be deployed via the EFI shell using a current Firmware update package, which –for the S3200SH and SR1530SH– can be obtained [here](https://downloadcenter.intel.com/Detail_Desc.aspx?DwnldID=20869).

Prepare a USB thumb drive with FAT formatting and MBR partition layout and extract the contents of the aforementioned ZIP file onto it. Among others, you’ll see the `3210SH15.sdr` file, which contains the Sensor Data Record for the board. The file is actually a regular text file that can be opened with an editor.

Inside of the file, there are a ton of declarations for different sensors, and chassis types. The latter are indicated by the `_SDR_TAG ...` statements. If we are running our Intel Board inside of a non-Intel chassis, the only fitting statements are `_SDR_TAG 'OTHER'`. The sections we are actually interested in look like this:

    // Sensor Record Header
    2100               // Record ID
    51                 // SDR Version
    C0                 // Record Type
    0C                 // Record Length

    // Record Body Bytes
    // Domain defaults to 100%
    570100             // Manufacturer ID
    0C                 // Record sub-type - Temperature Fan Speed Control Type 2
    00                 // Control Domain Number (PWM0)
    64                 // Normal Control Value (100%)
    64                 // Sleep Control Value (100%)
    64                 // Boost Control Value (100%)
    04                 // Ramp Step
    02                 // Scan Rate
    01                 // Flags; profile 1
    64                 // minimum control value - fail value (100%)


The first interesting byte pair is the Control Domain Number. This is a representation of the PWM connector on the board the following settings apply to. For the Intel S3200SHX these are the values for the adjacent connector:

    //CDN  Name  Related connector
      00   PWM0  CPU Fan
      01   PWM1  SYS Fan 1 + 2 (rear and low front fan)
      02   PWM2  SYS Fan 3 + 4 (mid and up front fan)


With that in mind, you can set the Control Values accordingly. By default, Intel defines them as `64`, which is hexadecimal representation of 100, as in percent of maximum PWM frequency. For my setup I derived a single set of values, applied to _all_ CDNs:

    12                 // Normal Control Value (20%)
    12                 // Sleep Control Value (20%)
    64                 // Boost Control Value (100%)
     // ...
    0F                 // minimum control value - fail value (15%)


Keep in mind that the Boost CV should stay at a very high value, at least for the CPU Fan. It is used when one of the fans fails and supposed to prevent overheating. With the values set in the `.sdr` file, we can boot the thumb drive now. Select the `EFI shell` to be the first boot device in the BIOS setup and reboot the machine with the thumb drive plugged in.

You’ll see the welcome screen of the BIOS update package. It might not be necessary to update the firmware itself, but I did it just in case the SDR config is specific to the version of the update package. If you have already done the firmware update, you can `q` quit out of the updater and get into the EFI shell. There you simply have to call the following command and follow the instructions on screen to apply you selected settings, i.e. fan speeds.

    FRUSDR /cfg master.cfg


When loading the `master.cfg` you should choose option 3, to update FRU and SDR altogether. After that, you are supposed to tell the number and location of fans in your system and after finishing up and a quick reboot, the speeds should be applied.