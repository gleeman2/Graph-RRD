FROM xorux/apps

# Install APT Grafana (jessie)
RUN echo 'deb http://packagecloud.io/grafana/stable/debian/ jessie main' >> /etc/apt/sources.list
RUN echo 'deb https://packagecloud.io/grafana/testing/debian/ jessie main' >> /etc/apt/sources.list
RUN curl https://packagecloud.io/gpg.key | sudo apt-key add -
RUN apt-get update

RUN apt-get install -yq \
    curl \
    graphite-carbon \
    adduser \
    libfontconfig \
    grafana

# expose ports for SSH, HTTP, HTTPS and LPAR2RRD daemon
EXPOSE 8080 8081 3000 80

# Startup Grafana :3000
RUN service grafana-server start
RUN update-rc.d grafana-server defaults
