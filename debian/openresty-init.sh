#!/bin/sh

### BEGIN INIT INFO
# Provides:        openresty
# Required-Start:  $network
# Required-Stop:   $network
# Default-Start:   2 3 4 5
# Default-Stop:    0 1 6
# Short-Description: Start OpenResty (nginx) daemon
### END INIT INFO

PATH=/sbin:/bin:/usr/sbin:/usr/bin

. /lib/lsb/init-functions

DAEMON=__OPENRESTY_ROOT__/nginx/sbin/nginx

test -x $DAEMON || exit 5

case $1 in
	start)
		log_daemon_msg "Starting OpenResty (nginx) server" "openresty"
		$DAEMON
		$0 status >/dev/null
		log_end_msg $?
		;;
	stop)
		log_daemon_msg "Stopping OpenResty (nginx) server" "openresty"
		$DAEMON -s stop	
		log_end_msg $?
		;;
	restart|force-reload)
		$0 stop && sleep 2 && $0 start
		;;
	try-restart)
		if $0 status >/dev/null; then
			$0 restart
		else
			exit 0
		fi
		;;
	reload)
		exit 3
		;;
	status)
		status_of_proc $DAEMON "OpenResty (nginx) server"
		;;
	*)
		echo "Usage: $0 {start|stop|restart|try-restart|force-reload|status}"
		exit 2
		;;
esac
