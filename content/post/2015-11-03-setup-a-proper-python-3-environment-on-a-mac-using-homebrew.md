---
author: Jan
categories:
- Tutorials
date: '2015-11-03'
guid: http://beta.janw.io/setup-a-proper-python-3-environment-on-a-mac-using-homebrew/
id: 44
slug: setup-a-proper-python-3-environment-on-a-mac-using-homebrew/
tags:
- brew
- mac
- python
- virtualenv
title: Setup a proper Python 3 environment on a Mac using Homebrew

---

I don&#8217;t know why, but I&#8217;ll probably never get this into my head so this is partly a reminder to myself but also small tutorial for other. Recently I am writing a lot of code in Python. And since it&#8217;s 2015, nobody would actually want to start Python programming using Python 2. Unfortunately Python 2 is the default version shipping with most of the OSes I know, to the least on Mac OSX.

<!--more-->

So what has to be done to get Python 3 properly up and running, right beside Python 2 that might be used by the system itself? The answer is Virtualenv. In the following I assume that you have [Homebrew](http://brew.sh) installed on your Mac. I am going so far as to say, this is _mandatory_ Mac software!

Using Brew, we&#8217;ll install a custom Python 2 via `brew` and VirtualEnv via Python Package Manager `pip`. In addition we&#8217;ll also install Python 3, but it is not usable yet! Well, it is. But not the way it is meant to be used.

    brew install python python3
    pip install virtualenv


Now we are able to create a virtual environment. This will cause the default `python` call in shell to be forwarded to `python3` as long as the Venv is activated. When it&#8217;s not activated, `python` will behave just like before and your system will keep on running. Before doing the following, you may need to close (quit!) and reopen your Terminal.

    virtualenv ~/.envs/python3 -p python3


I like all my Venvs to be created in `~/.envs`. That directory is hidden (henve the &#8216;.&#8217; in front of the folder name) and it&#8217;s the same on all my machines. That makes it easier to maintain all my stuff. The above command will cause all the necessary symlinks to be created. Next step is to activate the Venv and finally use it!

    source ~/.envs/python3/bin/activate


By default, the bash shell prompt will show the Venv on the far left. Now you are able to use not only simple calls to `python` to actually reach `python3`, but you may also use `pip` to install packages. Those will be saved to `~/.envs/python3/lib/site-packages/`, far far away from the system-wide packages. And that&#8217;s one of the strengths of Venvs. It allows you to easily create complex dependency situations for single projects while leaving your system-wide configuration untouched, save, and sound.

Of course new Venvs can even be created for Python 2. In that case you can just omit the `-p python3` option on creation or specifically set it to `-p python2`. On omition, the system&#8217;s default `python` will be used.