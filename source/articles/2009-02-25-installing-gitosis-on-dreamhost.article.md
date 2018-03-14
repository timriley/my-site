---
title: Installing Gitosis on Dreamhost
permalink: 2009/02/25/installing-gitosis-on-dreamhost
published_at: 2009-02-25 01:00:00 +0000
---

Hugh's [forays back into shared hosting](http://hughevans.net/2009/02/22/sinatra-on-dreamhost) over the last week have reminded me that I could make better use of the cheap [Dreamhost](http://dreamhost.com/) account that I have had languishing for the last few years. I am going to migrate the few things I have running on my more expensive Slicehost slice. Quick way to save a bit of money each month, particularly with the equally languishing Australian Dollar.

 ![Dreamhost stickers](content/images/ss/61a73383d000.jpg)

First of these is Gitosis, which is a very handy way to securely store and share your private Git repositories. Since most accounts on Dreamhost are on shared host, you'll need to install it inside your home directory. Turns out this is quite simply done, and Marco Borromeo [provides a good tutorial](http://blog.marcoborromeo.com/how-to-install-gitosis-on-a-dreamhost-shared-account).

I had to take an additional couple of steps in order to get things to work with the Python 2.4 installation on my particular host, so I have provided a complete list here. This should hopefully work on any of the Dreamhost servers. Please leave a note in the comments if you have to do anything differently.

The first step you'll need to do is create a dedicated user account for the gitosis installation. I also chose to create a dedicated subdomain at the same time. Then, all you'll need to do is follow these steps:

```
# 1. Create dirs for unpacking your source code and installing your apps
mkdir $HOME/src
mkdir $HOME/apps

# 2. Install the latest version of git
cd $HOME/src
wget http://kernel.org/pub/software/scm/git/git-1.6.1.3.tar.gz
tar zxvf git-1.6.1.3.tar.gz
cd git-1.6.1.3
./configure --prefix=$HOME/apps NO_MMAP=1
make && make install

# 3. Create dir for local python modules
mkdir -p $HOME/apps/lib/python2.4/site-packages
export PYTHONPATH=$HOME/apps/lib/python2.4/site-packages

# 4. Install setuptools python module
cd $HOME/src
wget http://peak.telecommunity.com/dist/ez_setup.py
python2.4 ez_setup.py --prefix=$HOME/apps

# 5. Install gitosis
cd $HOME/src
git clone git://eagain.net/gitosis.git
cd gitosis
python2.4 setup.py install --prefix=$HOME/apps

# 6. Add new paths to shell environment
echo 'export PATH=$HOME/apps/bin:$PATH' >> $HOME/.bashrc
echo 'export PATH=$HOME/apps/bin:$PATH' >> $HOME/.bash_profile
echo 'export PYTHONPATH=$HOME/apps/lib/python2.4/site-packages' >> $HOME/.bashrc
echo 'export PYTHONPATH=$HOME/apps/lib/python2.4/site-packages' >> $HOME/.bash_profile
. ~/.bash_profile

# 7. Paste your public SSH key into a temporary file on your server. I'll assume it to be '$HOME/id_rsa.pub'

# 8. Initialise gitosis with your public key
gitosis-init < $HOME/id_rsa.pub
```

Once you're done with these, follow the second half of [this excellent gitosis introduction](http://vafer.org/blog/20080115011413) to get started hosting your repositories on Dreamhost!

_Image courtesy of [Patrick Havens](http://www.flickr.com/photos/guder/924253586/)._

