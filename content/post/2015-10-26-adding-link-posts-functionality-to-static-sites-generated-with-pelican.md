---
author: Jan
categories:
- Tutorials
date: '2015-10-26'
guid: http://beta.janw.io/adding-link-posts-functionality-to-static-sites-generated-with-pelican/
id: 47
slug: adding-link-posts-functionality-to-static-sites-generated-with-pelican/
tags:
- link posts
- pelican
title: Adding link posts functionality to static sites generated with Pelican

---

In my quest to world domination using just my words and a blog I have created a slightly modified version of the default Pelican site template. One of the most important things for me to post to my readers are link posts. A _lot_ of people out there use them to share other articles or websites and add comments to them. John Gruber for example is doing most of his posts on [Daring Fireball](http://daringfireball.net/) as link posts (and I can&#8217;t even remember the last time I did see any other content over there). I really love sharing the thoughts of others and I am a very frequent retweeter on Twitter. Unfortunately Twitter has a hard limit on how much I can comment on the shared things, ergo this blog of mine needs to have a &#8220;retweet&#8221; functionality built-in.

<!--more-->

As it turns out, implementing it into the Pelican static site generator is extremely simple and requires only a few changes to the theme: Wherever the site may show the title of an article an if-clause will be added. In my case the `article.html` template contained the following as part of an article titleage:

    #!html
    <header>
      <h2 class="entry-title">
        <a href="{{ SITEURL }}/{{ article.url }}">{{ article.title }}</a>
      </h2>
    </header>


So when looking at other people&#8217;s implementations of commented link posts, they universally agree on presenting the link as the `href` of the article&#8217;s title whilst marking the title as &#8220;external&#8221; by using some fancy symbol behind it. Since Pelican allows me to have any content tag I want in a markdown article file, I chose to add the `link:` tag for articles that are supposed to link externally. Therefore I simply start my upcoming article template with

    #!markdown
    Title: Fancy article on that site tells us a crazy story
    Date: 1970-01-01 00:00
    Link: https://that.site/fancy-article-with-crazy-story


and the content is ready. The only thing missing is querying for the `link:` tag in the template, changing the link, adding a cute symbol next to it, and we are golden:

    #!html
    <header>
      <h2 class="entry-title">
        {% if article.link %}
          <a href="{{article.link}}">{{ article.title }}</a> &rarr;
        {% else %}
          <a href="{{ SITEURL }}/{{ article.url }}">{{ article.title }}</a>
        {% endif %}
      </h2>
    </header>


That should be it: the blog now supports commented link posts that link directly to the original location. Of course such an article is still linkable locally as well – the page is created after all. I used a little chain link symbol to provide a permalink on this blog, that _always_ links to the local reference of the article.

So dear Pelicans out there: you&#8217;re welcome!