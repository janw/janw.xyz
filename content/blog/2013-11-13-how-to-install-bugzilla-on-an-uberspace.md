---
categories:
- Tutorials
date: '2013-11-13'
id: 53
slug: how-to-deploy-bugzilla-on-an-uberspace
tags:
- bugtracking
- self-hosting
- uberspace
title: How to install Bugzilla on an Uberspace

---

You may have heard of [Uberspace](http://uberspace.de), the &#8220;hosting on asteriods&#8221; offering comfortably furnished web hosting at a price of your own choosing, starting at only €1 per month. I moved all my services there about half a year ago and I really enjoy it there.

However not hosting on your own root-server come with some (imho gladly taken) restrictions, which sometimes require you to find little workarounds to run certain sites or applications. A lot of cool things are to be found [here](https://uberspace.de/dokuwiki/cool), but apparently no-one tried to set-up an instance of [Bugzilla](http://www.bugzilla.org/) before, so I gave it a try. Even though the default setup of the bugtracking tool requires root access to the server, working around that is not as hard as one might think.

<!--more-->

Hence: this is how to install Bugzilla on an Uberspace without superuser privileges. The only necessity is SSH access to the server and we&#8217;re good to go. Note that I am using `<your_uberspace_username>` throughout this tutorial to substitute for your Uberspace&#8217;s name. Replace it everytime you see it.

First we download Bugzilla&#8217;s most current tarball to the uberspace, extract its contents and move it to the folder at which is is supposed to be accessible over the web. As of writing this article, the current stable version of Bugzilla is 4.4.1. After moving the files we remove the remaining tarball and cd into the base folder of our installation.

<pre><code class="bash">wget http://ftp.mozilla.org/pub/mozilla.org/webtools/bugzilla-4.4.1.tar.gz
tar -xzf bugzilla-4.4.1.tar.gz
mv bugzilla-4.4.1 /var/www/virtual/&lt;your_uberspace_username&gt;/html/bugzilla
rm bugzilla-4.4.1.tar.gz
cd /var/www/virtual/&lt;your_uberspace_username&gt;/html/bugzilla
</code></pre>

By the way. as you see I am deploying the bugzilla instance at `<your_uberspace_username>.<your_uberspace_server>.uberspace.de/bugzilla/`. If you want to run the bugtracker from somewhere else, for example a subdomain, change the last part of the `mv` and `cp` commands accordingly.

Next up is pretty much the default process of installing Bugzilla on any server. We check for dependencies of some Perl packages, initialize the database, and setup the administrator&#8217;s account, all using Bugzilla&#8217;s built-in `checksetup.pl` script. To accomodate this process to the non-superuser environment, we have to add a few lines to that script. So lets open up the file in an editor of our own choosing (I prefer Pico here: `pico checksetup.pl`), locate the expression `__END__` (in v4.4.1 it&#8217;s at line 219) and add the following lines _before_ that:

<pre><code class="perl">system('for i in docs graphs images js skins; do find $i -type d -exec chmod o+rx {} \; ; done');
system('for i in jpg gif css js png html rdf xul; do find . -name \*.$i -exec chmod o+r {} \; ; done');
system('find . -name .htaccess -exec chmod o+r {} \;');
system('chmod o+x . data data/webdot');
</code></pre>

After saving and closing the script (i.e. `Ctrl+X` &#8211; `Y`&#8211; `Enter` in Pico), we execute it for the first time using `./checksetup.pl` at the shell&#8217;s prompt. Perl will now check for required modules and most likely some will be missing. At the bottom of the output you&#8217;ll find a list of _required_ modules, while others may be installed _optionally_, too. You can either install the required modules by executing the listed commands or go with the attempt to install _all_ of them (required _and_ optional) automatically using the following command:

<pre><code class="bash">/usr/bin/perl install-module.pl --all
</code></pre>

This may take a little while then. Upon finishing, `./checksetup.pl` needs to be re-run. Next step is the configuration. `pico localconfig` opens the config file in which the following lines need to be changed. Note that `<your_uberspace_mysql_passwd>` can be obtained from `~/.my.cnf`.

<pre><code class="perl">$webservergroup = '&lt;your_uberspace_username&gt;';
$db_name = '&lt;your_uberspace_username&gt;_bugs';
$db_user = '&lt;your_uberspace_username&gt;';
$db_pass = '&lt;your_uberspace_mysql_passwd&gt;';
</code></pre>

Save and close the file. Once again `./checksetup.pl` needs to be run and the database and directory tree is prepared. This script will then pause and ask you to enter login credentials for the Admin of your new bugtracker. Fill the fields appropriately.

After that we are basically done, but calling the desired address of the bugtracker in a webbrowser will still lead to a 403 error. That is because Bugzilla uses CGI to generate pages of the webinterface and CGIs are only executable from outside of the `cgi-bin` directory when you add the allowance to the `.htaccess` of your deployment. Just copy all of the following lines and execute them at once:

<pre><code class="bash">cat &lt;&lt;'__EOF__' &gt;&gt; .htaccess
Options +ExecCGI
AddHandler cgi-script .cgi
__EOF__
</code></pre>

Now head to the website and it should open up properly. Upon login you&#8217;ll be asked to edit the basic parameters of your installation, like `urlbase`, on the Parameters page. By deploying Bugzilla in a subdirectory of the default hostname of your Uberspace, you may activate `ssl_redirect` right from the beginning, routing all request via a secured connection.

Et voilà! The rest is up to you. If you&#8217;ve got any questions or comments, leave them down below.
