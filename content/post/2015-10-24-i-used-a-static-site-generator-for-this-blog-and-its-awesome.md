---
categories:
- Personal
date: '2015-10-24'
id: 49
slug: i-used-a-static-site-generator-for-this-blog-and-its-awesome
tags:
- blog
- cms
- meta
- pelican
- python
- static site generator
- website
title: I used a static site generator for this blog, and it’s awesome!

---

Okay, the dust starts to settle, rigid structures become visible, and I am getting comfortable in this new chair that is this blog. Over the past two days I put a little bit of work into building this site and of course I have to share that with the world. That just how I roll.

A long time ago in a galaxy far, far away I tried quite a few blog engines, most notably WordPress and Ghost. While they are extremely versatile and potent, their possibilites are what cripples them. To me they often feel bloated on the back-end and slow on the front-end. Load times are sheer endless and only looking at the amount source code of an exemplary WordPress theme discourages me to actually tailor it to my personal needs.

<!--more-->

Enter: my recently developed affection for Python and the [static site generator Pelican](http://blog.getpelican.com/). The concept of static site generators (SSG) is pretty simple. You never actually deploy compilable source code as you would with PHP. The page&#8217;s code is pre-compiled (often locally on your machine) and only the static HTML markup is then served. At first this sounded rather archaic to me. Why would modern web sites in 2015 be made up from pure HTML?

Well, of course SSGs still allow you to use cool Web-3.0-ish stuff, using pretty CSS for example. But any content that might have to be rendered by an engine like PHP will just be pre-rendered. And as I started working with Pelican I realized how clever that actually is.

Getting a bare-naked version of this site up and running took me less than 10 minutes. Yes, WordPress can do that aswell but only _after_ you already have a server somewhere. With Pelican I could start right away, developing the site. Serving it is only just the next step somewhere down the road. Well, it could have been but I am jus too impatient, which is why the site is already up and running even though I am not completely sure I didn&#8217;t forget any design customizations.

For designing the site I started from an exemplary template that was just empty. No styling had been inserted, only raw page outline was presented. This template is included with Pelican. Slowly but steadily I applied my own customizations to make it aesthetically appealing &#8230; at least to myself. Of course I gathered some inspiration from around the web. I&#8217;ve always done that for themes I developed and I would never see myself a copycat but rather an admirer of the web wizardry of others. I just lack the skill and professional background to have a vision for everything artistic. Some parts, sure. But the whole thing? Can&#8217;t do!

Anyhow, here we are now and I am quite satisfied with what I created so far. Of course the site is still lacking content. Badly. But I am going to change that very soon. The idea of it all is to publish something here at least every other day, preferably every day. Let&#8217;s see if I can keep that pace up.

* * *

**Update 2017-08-16:** Well, I am moving back to WordPress for a while. Sometimes having to compile everything statically has it&#8217;s downsides: draft to publishing takes a lot longer, when you have to handle it all from the command line.