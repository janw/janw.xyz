---
categories:
- Tutorials
date: '2015-07-17'
id: 50
slug: create-a-local-git-repository-to-be-used-as-a-remote
tags:
- command line
- git
title: Create a local Git repository to be used as a remote

---

A question that popped up a little more often lately in students I work with is how to use a local directory (for example on a backup or USB thumb drive) as a remote to another repository without utilizing a dedicated Git server. Many of the students are using a graphical Git client (such as [SourceTree](https://www.sourcetreeapp.com/)) to manage their repositories and create new ones. Unfortunately SourceTree (and probably other GUI clients, too) does not allow you to create the necessary type of repository to use as a remote to be pushed to. Using a regular repository instead results in errors upon pushing from one repository to the other while pulling still works. In this post I am explaining how to do just that: basically backup your local respository to another directory without the necessity to setup a Git server.

<!--more-->

**tl;dr:** Use `git init --bare MyLocalRemoteRepo.git` to create a so-called bare repository that can be used as a &#8220;pushable&#8221; remote to another working-copy repository.

### Scenario

I assume the presence of a main repository to be worked on. Let&#8217;s say a Bachelor&#8217;s Thesis written in LaTeX. We have a working copy of it that some commits have been made to and since we all know that **you just don&#8217;t write a thesis without at least two backups**, it&#8217;s time to get at least one of them going. This is our current directory in all its glory:

<pre><code class="bash">$ ls -1A MyThesis/
.git
.gitignore
graphics
include
my-awesome-thesis.aux
my-awesome-thesis.log
my-awesome-thesis.pdf
my-awesome-thesis.synctex.gz
my-awesome-thesis.tex
</code></pre>

Of course the `.gitignore` contains all filetypes that LaTeX creates temporarily for compiling the document, such as `.aux, .log, .synctex.gz`. Those are not getting tracked by Git.

Normally one would assume that simply creating a new Git respository (from the command line or via a GUI client) would allow both repositories to be &#8220;synchronized&#8221; via Pushes and Pulls. Unfortunately it&#8217;s not all that easy. While you can easily _pull_ from any repository into another one, _pushing_ requires the remote repository to be &#8220;bare&#8221;. Here&#8217;s an [explanation of the difference between regular Git repositories and bare ones](http://www.saintsjd.com/2011/01/what-is-a-bare-git-repository/). It boils down to:

> First off, [bare repositories] contain no working or checked out copy of your source files. And second, bare repos store git revision history of your repo in the root folder of your repository instead of in a .git subfolder.

### Enter: the command line

As mentioned above, SourceTree (and propbably other GUI clients as well) is not capable of creating a bare repository from the regular &#8220;Create New Repository&#8221; dialog box. As with many many other things as well, you are better off using Git on the command line to manage this sort of things. Let&#8217;s go OS-specific for a bit now. If you know how to launch the console and navigate to places, you may skip to the [next section](#creating-a-bare-respository).

#### Windows

The Command Line can be launched pressing Windows+R and entering `cmd` at the prompt. After clicking OK, you should be left with the command line. Try to enter `git` here, to see if you have Git &#8220;on path&#8221;. If the command won&#8217;t be found, here&#8217;s a [quick guide on how to add Git to path](http://blog.countableset.ch/2012/06/07/adding-git-to-windows-7-path/). After doing so, relaunch the command line. Navigating to another folder can be done using `cd` followed by the path you want to **c**hange **d**irectory to. If you are passing disk boundaries (i.e., changing from the current directory on drive `C:` to a folder on `D:`, you first need to enter the target drive:

<pre><code class="bash">&gt; D:
&gt; cd D:\Backups
</code></pre>

#### Mac and other unixoids (Linux)

The command line utility is most likely called `Terminal`. On a Mac simply press Cmd+Space, enter `Terminal`, and execute. On most Linux OSes the Terminal is found somewhere in the application menue. Navigating to another directory is done using `cd` followed by the path you want to **c**hange **d**irectory to:

<pre><code class="bash">cd /path/to/ExternalHardDrive/Backups
</code></pre>

### Creating a bare repository

Now that you are in the parent directory of your future backup, the repository is only a single command away. Note that it&#8217;s best practice to add `.git` as a suffix to the new repository&#8217;s directory.

<pre><code class="git">git init --bare MyThesisBackup.git
</code></pre>

Now navigate back to your working repository, and add the new bare repo as a remote. Finally we execute our first push to the remote. Note that adding and pushing can now easily be done via the GUI client again if you feel more comfortable with that. Only the bare repository creation requires the command line.

<pre><code class="bash">cd /path/to/MyThesis
git remote add local_backup /path/to/Backups/MyThesisBackup.git
git push --set-upstream local_backup master
</code></pre>

### Final remarks

Keep in mind that Git is made from developers for developers and I&#8217;d consider it an essential skill to be able to handle the command line. While it may take a long time to get ones head around the concept of doing _everything_ in text mode, no GUI can provide you with all the features that the console gives you, especially (but not exclusively) when it comes to Git. My advise is: familiarize yourself with the [Git command cheatsheet](https://training.github.com/kit/downloads/github-git-cheat-sheet.pdf). In many cases, using the text commands is just so much faster than using a GUI client.