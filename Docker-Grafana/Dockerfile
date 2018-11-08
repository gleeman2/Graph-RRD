FROM graphiteapp/graphite-statsd

# Install Grafana
RUN curl -O https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_5.1.4_amd64.deb
RUN chmod +x grafana_5.1.4_amd64.deb
RUN dpkg -i grafana_5.1.4_amd64.deb
RUN update-rc.d grafana-server defaults 95 10
RUN rm -f grafana_5.1.4_amd64.deb

# defaults
EXPOSE 22 80 2003-2004 2023-2024 8080 8125 8125/udp 8126 3000
VOLUME ["/opt/graphite/conf", "/opt/graphite/storage", "/opt/graphite/webapp/graphite/functions/custom", "/etc/nginx", "/opt/statsd", "/etc/logrotate.d", "/var/log", "/var/lib/redis"]
WORKDIR /
ENV HOME /root
ENV STATSD_INTERFACE udp

CMD ["/sbin/my_init"]
