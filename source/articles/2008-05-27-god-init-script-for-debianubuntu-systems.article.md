---
title: God init script for Debian/Ubuntu systems
permalink: 2008/05/27/god-init-script-for-debianubuntu-systems
published_at: 2008-05-26 14:45:00 +0000
---

To compliment the Red Hat [init script](http://pastie.caboo.se/110483) that is available on the net, here's the init script we use to launch [god](http://god.rubyforge.org/) on our Ubuntu systems.

To use, save as `/etc/init.d/god`, make the file executable, then run `update-rc.d god defaults`. You're done.

```
#!/bin/sh

### BEGIN INIT INFO
# Provides: god
# Required-Start: $all
# Required-Stop: $all
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: God
### END INIT INFO

NAME=god
DESC=god

set -e

# Make sure the binary and the config file are present before proceeding
test -x /usr/bin/god || exit 0

# Create this file and put in a variable called GOD_CONFIG, pointing to
# your God configuration file
test -f /etc/default/god && . /etc/default/god
[$GOD_CONFIG] || exit 0

. /lib/lsb/init-functions

RETVAL=0

case "$1" in
  start)
    echo -n "Starting $DESC: "
    /usr/bin/god -c $GOD_CONFIG -P /var/run/god.pid -l /var/log/god.log
    RETVAL=$?
    echo "$NAME."
    ;;
  stop)
    echo -n "Stopping $DESC: "
    kill `cat /var/run/god.pid`
    RETVAL=$?
    echo "$NAME."
    ;;
  restart)
    echo -n "Restarting $DESC: "
    kill `cat /var/run/god.pid`
    /usr/bin/god -c $GOD_CONFIG -P /var/run/god.pid -l /var/log/god.log
    RETVAL=$?
    echo "$NAME."
    ;;
  status)
    /usr/bin/god status
    RETVAL=$?
    ;;
  *)
    echo "Usage: god {start|stop|restart|status}"
    exit 1
    ;;
esac

exit $RETVAL
```
