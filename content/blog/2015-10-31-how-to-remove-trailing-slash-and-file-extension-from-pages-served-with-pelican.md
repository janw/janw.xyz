---
categories:
- Tutorials
date: '2015-10-31'
id: 45
slug: how-to-remove-trailing-slash-and-file-extension-from-pages-served-with-pelican
tags:
- pelican
- url pattern
title: How to remove trailing slash and file extension from pages served with Pelican

---

The work on this site continues and today I made great progress in minimizing the CSS and improving the general visual appeal of the site. As I am using the beautiful [Bootstrap](http://getbootstrap.com) web framework I tried to encorporate most of the styling directives that already ship with my customized version of bootstrap, and at the same time reduce the number of CSS rules that I implemented to overwrite default Bootstrap behavior. The result is a reduction of about 50KB of data on every request and I am now down to about 170KB for the front page to be served.

<!--more-->

As I like load times to be fast and my custom CSS contains only 60 lines of code I include those rules directly into the HTML, eliminating another request from the equation. I am pretty satisfied with the load speed now, even without activating caching and/or compression. More on that soon.

Now let&#8217;s turn to what we are actually here for: The visually appealing fact that I now have URLs without trailing slashes and without file extensions! One does not get around modifying the `.htaccess` to add the necessary `mod_rewrite` directives but of course Pelican can serve that aswell when `rsync_upload`-ing the site to the server: The htaccess file will be created in `content/extra/htaccess` (yes without the dot in front, so we can see it at all time) and referenced in the `pelicanconf.py` like this:

    STATIC_PATHS = [
        'extra/htaccess',
        ]
    EXTRA_PATH_METADATA = {
        'extra/htaccess': {'path': '.htaccess'},
        }


This tells Pelican to take the htaccess file from the extra folder and place it in the root folder of the compiled output of the site (of course then prefixed with a dot). For this method of removing trailing slashes to work, your URL patterns have to be modified as well, to something along these lines:

    ARTICLE_URL = '{date:%Y}/{date:%m}/{date:%d}/{slug}'
    ARTICLE_SAVE_AS = '{date:%Y}/{date:%m}/{date:%d}/{slug}.html'
    PAGE_URL = '{slug}'
    PAGE_SAVE_AS = '{slug}.html'


All `_URL` settings have to have their trailing slash removed, and all `_SAVE_AS` settings have to end in the same thing but with `.html` appended. The only thing missing now, is the contents of our `content/extras/htaccess`:

    RewriteEngine On
    RewriteBase /

    # Check if request is for an actual file, serve the file
    RewriteRule ^([^\.]+)$ $1.html [NC,L]

    # Catch request to HTML file, remove extension
    RewriteCond %{THE_REQUEST} ^[A-Z]{3,9}\ /([^\ ]+)\.html
    RewriteRule ^/?(.*)\.html$ /$1 [L,R=301]


Now your webserver will present the correct file when you call on it with no extension attached. If you call it _with_ an extension, you will be permanently redirected to the version without the extension (or slash). Looks good!