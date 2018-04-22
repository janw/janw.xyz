---
categories:
- Tutorials
date: '2016-12-30'
id: 35
slug: installing-a-matrix-org-synapse-server-on-uberspace
tags:
- matrix
- self-hosting
- synapse
- uberspace
title: Installing a Matrix.org Synapse server on Uberspace

---

So [Matrix](https://matrix.org/) is the hot new shit for federated ([end-to-end encrypted](https://matrix.org/blog/2016/11/21/matrixs-olm-end-to-end-encryption-security-assessment-released-and-implemented-cross-platform-on-riot-at-last/)) messaging in the filter bubble these days, and I figured: what sense does federation support make, if nobody joins the alliance? So I set out to set up my own instance of the Synapse reference implementation server. This post is a walk-through of the setup process.

<!--more-->

Some caveats apply though:

  * An Uberspace account is required for this to work (d&#8217;uh.)
  * You should have a valid [(Let&#8217;s Encrypt) TLS certificate](https://wiki.uberspace.de/webserver:https#let_s-encrypt-zertifikate) for the server&#8217;s domain
  * Your domain registrar should allow the addition of SRV records to your DNS zone ([Gandi](https://www.gandi.net/) does)

### Making your life easier – one variable at a time

Writing this tutorial I used the environment variables `$USER`, `$HOME` (which are both set by your shell when connecting), and `$SERVER_NAME`. The latter has to be set manually, which we do first. Here you set the hostname of your future Synapse server. For example:

    export SERVER_NAME="server-name.example"


### Setting up the PostgreSQL

We&#8217;re starting off with installing PostgreSQL. By default Synapse uses an sqlite database, which is not really advisable &#8220;in production&#8221;. If your server is going to host more than just a few users sqlite will become sluggish really fast. So I suggest you use Postgres instead. Another caveat: PostgreSQL is still in BETA at Uberspace and has to be set up specifically to run on a per-user basis. I will use it anyway – because be bold! And the Uberspace guys even greated a handy little installer. Let&#8217;s fire it up:

    uberspace-setup-postgresql

    # Pinning PostgreSQL to release version 9.3 in ~/etc/postgresversion.
    # Creating ~/tmp (if it doesn't exist already).
    # Creating ~/.pgpass.
    # Setting permissions on ~/.pgpass.
    # Generating a long PostgreSQL superuser password.
    # Running initdb.
    # ...


A little side note here: If your account has not been prepared to run your own services yet: doesn&#8217;t matter. `uberspace-setup-postgresql` will do the necessary work for you, and install the PostgreSQL service in your `~/service/` directory. Postgres and any future [services can now be started/stopped/restarted using the `svc` command](https://wiki.uberspace.de/system:daemontools#wenn_der_daemon_laeuft).

Postgres inserts itself into the `PATH` environment variable to expose the functions `createuser`, and `createdb` on the command line. For the new PATH to become active, it&#8217;s easiest to just log out and log back in to your SSH connection again. Without that, the next steps won&#8217;t complete properly.

To give Synapse its own database later, we create a separate user for Postgres. In [alignment with the official Synapse guide](https://github.com/matrix-org/synapse/blob/master/docs/postgres.rst) I chose `synapse_user` as the username. Give the user a proper password as well, and remember that for the config.

    createuser synapse_user -P

    # Enter password for new role:
    # Enter it again:


Let&#8217;s also create an adjacent database that is owned by our new synapse_user:

    createdb --encoding=UTF8 \
        --lc-collate=C \
        --lc-ctype=C \
        --owner=synapse_user \
        --template=template0 \
        synapse


### Getting rid of a future warning

The version of CentOS installed on most Uberspaces is shipping with a rather old version of a crypto library that Synapse depends on (by extension). Before we install Synapse, we bring that library up to date using the `toast` package manager:

    toast arm gmp


### Basic setup

Next, let&#8217;s take care of the basic Synapse installation itself. Some of the lines are directly copied from the [official Readme](https://github.com/matrix-org/synapse#synapse-installation) – but we are getting a little bit funky. Also note that a &#8220;mint&#8221; Uberspace account might not have `virtualenv` installed so we do that first. Then create a virtualenv with Python 2.7, and activate it. Upgrade setuptools, install `psycopg2` (for postgreSQL database support), and install Synapse from tarball:

    pip install virtualenv
    virtualenv -p python2.7 ~/.synapse
    source ~/.synapse/bin/activate
    pip install --upgrade --ignore-installed --no-cache-dir setuptools psycopg2 PyCrypto
    pip install https://github.com/matrix-org/synapse/tarball/master


Installation of the tarball might take a while. There are quite a few dependencies to be satisfied. But after that we take care of the initial config. Here we use our `$SERVER_NAME` variable, meaning usernames look pretty in the end (`@user:server-name.example`). This does not conflict running a website on that domain at the same time. As long as you have access to the `.htaccess` file of said website, you will be fine.

    cd ~/.synapse
    python -m synapse.app.homeserver \
        --server-name $SERVER_NAME \
        --config-path homeserver.yaml \
        --generate-config --report-stats=yes


Now we add our first modifications to the config file. If you used the above command (`python -m synapse.app.homeserver ...`), the file will reside in `~/.synapse/homeserver.yaml`. Open that file in an editor of your choice and modify the `database:` section, replacing the default sqlite settings like so:

    database:
        # The database engine name
        name: psycopg2
        # Arguments to pass to the engine
        args:
            user: "synapse_user"
            password: "<my super secure password>"
            database: "synapse"
            host: "/home/$USER/tmp"
            cp_min: 5
            cp_max: 10


Make sure to replace `<my super secure password>` with the password you entered for synapse_user, and swap `$USER` for your Uberspace username. Don&#8217;t worry that there is no real hostname in `host:`: The default Uberspace Postgres configuration does not listen on a Unix Domain socket, but on a file socket which resids in `~/tmp/`.

### Adding a properly signed TLS certificate

[Adding a Let&#8217;s Encrypt TLS certificate on Uberspace](https://wiki.uberspace.de/webserver:https#let_s-encrypt-zertifikate) is very well documented in the official Wiki, and I&#8217;ll assume you have a properly configured TLS certificate for the domain name you&#8217;re setting Synapse up on. What we need from that setup are the paths to the `privkey.pem`, and `cert.pem`, usually those reside here:

    /home/$USER/.config/letsencrypt/live/<domainname>/cert.pem
    /home/$USER/.config/letsencrypt/live/<domainname>/privkey.pem


We have to swap the self-signed certificate in the Synapse config with the above one. Open the `homeserver.yaml` in your an editor of your own choosing, and modify `tls_certificate_path`, and `tls_private_key_path`:

    tls_certificate_path: "/home/$USER/.config/letsencrypt/live/<domainname>/cert.pem"
    tls_private_key_path: "/home/$USER/.config/letsencrypt/live/<domainname>/privkey.pem"


Again it goes without saying, that you have to swap `$USER` for your Uberspace username, and <domainname> for the domain name.

### Setting up custom ports

With TLS prepared, we move on to ports. Uberspace is a shared hosting provider, so the default ports Matrix uses (8008, and 8448) are not available to us mere mortals. That&#8217;s not a problem for Matrix though, since they properly employ an (RFC2782) DNS SRV entry, to determine the correct port (and hostname) on which a server is listening for an entire domain. We start off with poking a hole through the firewall on a custom port, given by a handy script provided by the Uberspace guys:

    uberspace-add-port -p tcp -f

    #   All good! Opened port 64949, tcp protocol(s).


Cool. In this example I got port 64949 opened in the firewall, so we can handle direct (mostly server-to-server / federation) connections through that.

For client side access it is easier to handle connections via the default HTTPS port (443), but of course we can not hog that for ourselves as well. Therefore we employ our webserver to act as a reverse proxy on a specific URL. Think of a port number between 61000 and 65535, (I&#8217;ll take 64950 here) and check with `netstat -tulpen | grep 64950` that it is not already occupied by another user. If the command returns silently, you may use this port to configure the proxy.

With these two ports in mind we open up the config again, and look for `listeners:` section. In the default config the first one is the &#8220;Main **HTTPS** listener&#8221;, which has to be equipped with `port: 64949` (the first one from the `uberspace-add-port` command).

The second one is the &#8220;Unsecure **HTTP** listener&#8221;. Here you add the second port (chosen by you): `port: 64950`. In addition to that `bind_address` is set to `'127.0.0.1'`, and `x_forwarded` to `true`, making the &#8220;Unsecure&#8221; prefix moot.

### Reverse-proxying the client front end

Next up is the proxy. If you don&#8217;t already host a site on your domain name, create a folder in `/var/www/virtual/$USER/` that matches your domain name:

    mkdir /var/www/virtual/$USER/$SERVER_NAME/
    cd /var/www/virtual/$USER/$SERVER_NAME/


In this directory we create an `.htaccess` file and add the following contents to setup reverse-proxying the `_matrix` subdirectory, which is the entry point for connecting clients. Note the `localhost:64950` statement, and replace the port with the second one from your own &#8220;Unsecure&#8221; HTTP listener:

    RewriteEngine On
    RewriteRule ^_matrix(/?)$ /_matrix/client/ [R]
    RewriteRule ^(_matrix/.*)$ http://localhost:64950/$1 [P]


### Setting up a daemontools service

By default Synapse is started using `synctl` which is installed in the Python virtualenv belonging to Synapse. This is not very handy, when Synapse is supposed to be automatically (re)started on reboots and crashes. Therefore we setup a service with daemontools. I created a tiny shell script in `~/bin/synapse` (as [suggested by the Wiki](https://wiki.uberspace.de/system:daemontools#einen_daemon_einrichten)) as the startup script for Synapse. You may do the same by executing the following:

    mkdir -p ~/bin
    cat << __EOF__ > ~/bin/synapse
    #!/bin/sh
    cd /home/$USER/.synapse
    exec bin/python -B -u -m synapse.app.homeserver -c /home/$USER/.synapse/homeserver.yaml 2>&1
    __EOF__


Don&#8217;t forget to mark it as executable: `chmod +x ~/bin/synapse`, and use the `uberspace-setup-service` tool to create a proper service.

    uberspace-setup-service synapse ~/bin/synapse

    # Creating the ~/etc/run-synapse/run service run script
    # Creating the ~/etc/run-synapse/log/run logging run script
    # Symlinking ~/etc/run-synapse to ~/service/synapse to start the service
    # Waiting for the service to start ... 1 2 3 4 started!
    # ...


This will create all directories and files necessary to run Synapse as a service – including proper logging to `~/service/synapse/log/main/*` –, and fire up the service for the first time. Awesome!

### Setting up a DNS SRV record

The final step is rather hard to explain universally, since it depends a lot on your domain registrar&#8217;s configuration interface. But I assume that most registrars will have the necessary steps documented in their help sections, or their support people will be happy to help you.

Those of you registering with [Gandi](https://gandi.net) – you&#8217;re in luck. The documentation on [how to set up an SRV record at Gandi](https://wiki.gandi.net/en/dns/zone/srv-record) is quite helpful: Using the &#8220;normal&#8221; zone configuration interface, you&#8217;ll first have to create a new version of the zone that contains `$SERVER_NAME`&#8216;s entries, and add a new record of type `SRV` and name `_matrix._tcp`:<figure id="attachment_259" style="width: 740px" class="wp-caption alignnone">

<img src="https://i2.wp.com/janw.io/wp-content/uploads/2016/12/matrix-srv-record.png?resize=525%2C194&#038;quality=100&#038;strip=all&#038;ssl=1" alt="" width="525" height="194" class="size-full wp-image-259" srcset="https://i0.wp.com/janw.xyz/wp-content/uploads/2016/12/matrix-srv-record.png?w=740&quality=100&strip=all&ssl=1 740w, https://i0.wp.com/janw.xyz/wp-content/uploads/2016/12/matrix-srv-record.png?resize=300%2C111&quality=100&strip=all&ssl=1 300w" sizes="(max-width: 706px) 89vw, (max-width: 767px) 82vw, 740px" data-recalc-dims="1" /><figcaption class="wp-caption-text">Screenshot of the &#8220;add a record&#8221; interface of Gandi.net for setting up a \_matrix.\_tcp SRV record</figcaption></figure>

The value field contains &#8220;priority, weight. port, and target, ending in a dot&#8221;. Priority and weight are of no concern to us, so I chose default values ``, and `5`. For the port, we enter the one opened in the firewall (`64949` in my case, and the target is our `server-name.example.` (replace with your domain name from `$SERVER_NAME` and add a dot at the end!)

Upon saving the entry don&#8217;t forget to activate the new zone file to propagate the new setting to the Gandi nameservers.

Time for an extensive coffee break to wait for DNS propagation. After a while you can use the URL [`https://matrix.org/federationtester/api/report?server_name=server-name.example`](https://matrix.org/federationtester/api/report?server_name=server-name.example) to test our server. If the SRV record is working, the return should contain something like

    {
        "DNSResult": {
            "SRVCName": "_matrix._tcp.server-name.example.",
            "SRVRecords": [
                {
                    "Target": "server-name.example.",
                    "Port": 61494,
                    "Priority": 0,
                    "Weight": 5
                }
            ]
        }
    }


### Registering a new user

Btw, to create a user without enabling registration in the config file, here&#8217;s the way to do it from the command line:

    source ~/.synapse/bin/activate
    register_new_matrix_user -c ~/.synapse/homeserver.yaml https://$SERVER_NAME

    # New user localpart: <username>
    # Password:
    # Confirm password:
    # Success!


<del datetime="2017-08-16T19:36:34+00:00">If you got it running (or failed, got angry, and chose <a href="https://riot.im/app/#/register">create an account on the default Matrix server</a>), you might want to hit me up, and tell me about the experience. My user name is <code>@jan:janw.io</code>. </del> Sorry, I over-estimated the usefulness in my personal messaging landscape. I shut the server down by now. Have fun with the tutorial though!