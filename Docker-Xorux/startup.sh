#!/bin/bash

if [ -f /firstrun ]
then
    # remote syslog server to docker host
    SYSLOG=`netstat -rn|grep ^0.0.0.0|awk '{print $2}'`
    echo "*.* @$SYSLOG" > /etc/rsyslog.d/50-default.conf

    # Start syslog server to see something
    /etc/init.d/rsyslog start

    echo "Running for first time.. need to configure..."

    a2ensite lpar2rrd.conf stor2rrd.conf
    # a2ensite default-ssl
    # a2enmod ssl
	  a2enmod cgid

    # Stopping ALL services
    /etc/init.d/apache2 stop
    /etc/init.d/ssh stop
    /etc/init.d/cron stop
    /etc/init.d/rsyslog stop
    #Start Grafana at startup
    update-rc.d grafana-server defaults

    # setup products
    su - lpar2rrd -c "cd /home/lpar2rrd/lpar2rrd-$LPAR_VER/; yes '' | ./install.sh"
    rm -r /home/lpar2rrd/lpar2rrd-$LPAR_VER
    su - lpar2rrd -c "cd /home/stor2rrd/stor2rrd-$STOR_VER/; yes '' | ./install.sh"
    rm -r /home/lpar2rrd/stor2rrd-$STOR_VER

    # mv /home/lpar2rrd/tz.pl /home/lpar2rrd/lpar2rrd/bin/tz.pl
    # chown lpar2rrd /home/lpar2rrd/lpar2rrd/bin/tz.pl

    # enable LPAR2RRD daemon on default port (8162)
    sed -i "s/LPAR2RRD_AGENT_DAEMON\=0/LPAR2RRD_AGENT_DAEMON\=1/g" /home/lpar2rrd/lpar2rrd/etc/lpar2rrd.cfg
    # set DOCKER env var
    echo "export DOCKER=1" >> /home/lpar2rrd/lpar2rrd/etc/.magic

    # set default TZ to London, enable TZ change via GUI
    echo "America/New_York" > /etc/timezone
    chmod 666 /etc/timezone

    # copy .htaccess files for ACL
    cp -p /home/lpar2rrd/lpar2rrd/html/.htaccess /home/lpar2rrd/lpar2rrd/www
    cp -p /home/lpar2rrd/lpar2rrd/html/.htaccess /home/lpar2rrd/lpar2rrd/lpar2rrd-cgi

	  cp -p /home/stor2rrd/stor2rrd/html/.htaccess /home/stor2rrd/stor2rrd/www
    cp -p /home/stor2rrd/stor2rrd/html/.htaccess /home/stor2rrd/stor2rrd/stor2rrd-cgi

    # Load Grafana
    /bin/systemctl daemon-reload
    /bin/systemctl enable grafana-server

    # clean up
    rm /firstrun
fi

# Sometimes with un unclean exit the rsyslog pid doesn't get removed and refuses to start
if [ -f /var/run/rsyslogd.pid ]
    then rm /var/run/rsyslogd.pid
fi

# run apache2ctl to create missing dirs
/usr/sbin/apache2ctl configtest > /dev/null
# Start supervisor to start the services
/usr/bin/supervisord

# Startup Grafana :3000
service grafana-server restart
#update-rc.d grafana-server defaults
