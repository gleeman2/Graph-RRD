#!/usr/bin/docker build .
# -- Stor2rrd/Lapr2rrd/Grafana/Grphite --
# http://docs.grafana.org/installation/debian/ < grafana
#
# VERSION        1.0

FROM       debian:jessie
MAINTAINER jirka@dutka.net (xorux/apps)

ENV HOSTNAME GraphRRD
ENV VI_IMAGE 1
ENV DEBIAN_FRONTEND noninteractive

# create file to see if this is the firstrun when started
RUN touch /firstrun
# add non-free debian sources
RUN echo "deb http://ftp.debian.org/debian jessie main non-free" >> /etc/apt/sources.list

RUN apt-get update && apt-get dist-upgrade -y

# install nesessary apps and libs
RUN apt-get install -yq \
    wget \
    supervisor \
    apache2 \
    ed \
    bc \
    librrdp-perl \
    libxml-simple-perl \
    libxml-libxml-perl \
    libcrypt-ssleay-perl \
    libpdf-api2-perl \
    net-tools \
    libxml2-utils \
    sharutils \
    snmp \
    snmp-mibs-downloader \
    libsnmp-perl \
    openssh-client \
    openssh-server \
    vim \
    rsyslog \
    sudo \
    curl \
    graphite-carbon \
    adduser \
    libfontconfig
    less

# Install APT Grafana
# RUN echo "deb https://packagecloud.io/grafana/stable/debian/ stretch main" >> /etc/apt/sources.list
# RUN echo "deb https://packagecloud.io/grafana/testing/debian/ stretch main" >> /etc/apt/sources.list
# curl https://packagecloud.io/gpg.key | sudo apt-key add -
# RUN apt-get update
# RUN apt-get install grafana

# Cleanup
RUN apt-get clean

# setup default user
RUN useradd lpar2rrd -U -s /bin/bash -m
RUN echo 'lpar2rrd:xorux4you' | chpasswd
RUN echo '%lpar2rrd ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir /home/stor2rrd \
    && mkdir /home/lpar2rrd/stor2rrd \
    && ln -s /home/lpar2rrd/stor2rrd /home/stor2rrd \
    && chown lpar2rrd /home/lpar2rrd/stor2rrd

# configure Apache
COPY configs/apache2 /etc/apache2/sites-available
COPY configs/apache2/htpasswd /etc/apache2/conf/

# change apache user to lpar2rrd
RUN sed -i 's/^export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=lpar2rrd/g' /etc/apache2/envvars

# adding web root
ADD html.tar.gz /var/www
RUN chown -R www-data.www-data /var/www

# add product installations
ENV LPAR_VER_MAJ "5.07"
ENV LPAR_VER_MIN ""
ENV LPAR_SF_DIR "5.07"
ENV STOR_VER_MAJ "2.40"
ENV STOR_VER_MIN ""
ENV STOR_SF_DIR "2.40"

ENV LPAR_VER "$LPAR_VER_MAJ$LPAR_VER_MIN"
ENV STOR_VER "$STOR_VER_MAJ$STOR_VER_MIN"

# download tarballs from SF
ADD http://downloads.sourceforge.net/project/lpar2rrd/lpar2rrd/$LPAR_SF_DIR/lpar2rrd-$LPAR_VER.tar /home/lpar2rrd/
ADD http://downloads.sourceforge.net/project/stor2rrd/stor2rrd/$STOR_SF_DIR/stor2rrd-$STOR_VER.tar /home/stor2rrd/

# extract tarballs
WORKDIR /home/lpar2rrd
RUN tar xvf lpar2rrd-$LPAR_VER.tar

WORKDIR /home/stor2rrd
RUN tar xvf stor2rrd-$STOR_VER.tar

# expose ports for SSH, HTTP, HTTPS and LPAR2RRD daemon
EXPOSE 22 80 443 8162 8080 8081

COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

COPY configs/crontab /var/spool/cron/crontabs/lpar2rrd
RUN chmod 600 /var/spool/cron/crontabs/lpar2rrd && chown lpar2rrd.crontab /var/spool/cron/crontabs/lpar2rrd

COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
COPY tz.pl /usr/lib/cgi-bin/tz.pl
RUN chmod +x /usr/lib/cgi-bin/tz.pl
COPY index.html /var/www/

# Startup Grafana :3000
# RUN service grafana-server start
# RUN update-rc.d grafana-server defaults

ENTRYPOINT [ "/startup.sh" ]
