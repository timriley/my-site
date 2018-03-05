---
title: Enabling a non-interactive install of Blackdown's j2re1.4 on Ubuntu or Debian
permalink: 2008/06/12/enabling-a-non-interactive-install-of-blackdowns-j2re14-on-ubuntu-or-debian
published_at: 2008-06-12 05:45:00 +0000
---

When you `apt-get install` the `j2re1.4` Java package in Debian or Ubuntu, it displays a few ncurses-style dialogs to configure the software and to require your acceptance of the license agreement. Working with these dialogs is fine if you are installing the software with apt-get in a typical interactive shell session. If you are installing without this capacity to interact (like in a script), you will run into problems. Here's how to fix it.

If you install the package with the noninteractive frontend for dpkg, then you'll get an error like this:

```
# DEBIAN_FRONTEND=noninteractive /usr/bin/apt-get --yes --force-yes install j2re1.4

Reading package lists... Done
Building dependency tree
Reading state information... Done
Suggested packages:
  mozilla-browser mozilla-firefox galeon ttf-kochi-gothic ttf-kochi-mincho
Recommended packages:
  gsfonts-x11 libx11-6 libxext6 libxi6
The following NEW packages will be installed:
  j2re1.4
0 upgraded, 1 newly installed, 0 to remove and 23 not upgraded.
Need to get 0B/22.5MB of archives.
After unpacking 60.3MB of additional disk space will be used.
Preconfiguring packages ...
j2re1.4 failed to preconfigure, with exit status 10
Selecting previously deselected package j2re1.4.
(Reading database ... 26639 files and directories currently installed.)
Unpacking j2re1.4 (from .../j2re1.4_1.4.2.02-1ubuntu3_i386.deb) ...
dpkg: error processing /var/cache/apt/archives/j2re1.4_1.4.2.02-1ubuntu3_i386.deb (--unpack):
 subprocess pre-installation script returned error exit status 10
Errors were encountered while processing:
 /var/cache/apt/archives/j2re1.4_1.4.2.02-1ubuntu3_i386.deb
E: Sub-process /usr/bin/dpkg returned an error code (1)
```

The package fails to install because it requires the acceptance of the licence agreement, which it will only allow in an interactive installation.

The typical way to fix this is to pre-seed the debconf database (using @debconf-set-selections@) with the answers to the questions that the j2re1.4 package requires. However, this doesn't seem to satisfy j2re1.4, and the package still displays the dialog or fails in non-interactive mode. Why is it java that always gives me these hairy problems?

Anyway, here is the way to fix it. If you manually append the values _directly_ to the debconf database file, it will work:

```
cp /var/cache/debconf/config.dat /var/cache/debconf/config.dat-old

cat << E_O_DEBCONF >> /var/cache/debconf/config.dat

Name: j2re1.4/jcepolicy
Template: j2re1.4/jcepolicy
Value:
Owners: j2re1.4
Flags: seen

Name: j2re1.4/license
Template: j2re1.4/license
Value: true
Owners: j2re1.4
Flags: seen

Name: j2re1.4/stopthread
Template: j2re1.4/stopthread
Value: true
Owners: j2re1.4
Flags: seen

E_O_DEBCONF
```

_(For reference, I found these values by making a copy of the config.dat file, running `dpkg-preconfigure` on the j2re1.4 package, and then running a diff between the updated config.dat file and my copy.)_

Now you'll be able to successfully install the package in noninteractive mode. This means, for us, one step closer to fully automating our Xen builds!

