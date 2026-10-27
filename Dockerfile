FROM ubuntu:26.04

EXPOSE 80

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apache2 \
       ca-certificates \
       libauthen-sasl-perl \
       libcgi-pm-perl \
       libdbd-mysql-perl \
       libjson-perl \
       liblwp-protocol-https-perl \
       libwww-perl \
       tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && a2enmod cgid

ENV \
  APACHE_LOG_DIR=/var/log/apache2 \
  APACHE_PID_FILE=/var/run/apache2/apache2.pid \
  APACHE_RUN_DIR=/var/run/apache2 \
  APACHE_RUN_GROUP=tnmc \
  APACHE_RUN_USER=tnmc

# remove the image's default ubuntu user so tnmc keeps UID 1000
RUN userdel -r ubuntu \
    && useradd -ms /bin/bash tnmc \
    && mkdir -p $APACHE_RUN_DIR/socks \
    && chown -R tnmc $APACHE_RUN_DIR \
    && mkdir -p $APACHE_LOG_DIR \
    && chown -R tnmc $APACHE_LOG_DIR \
    && sed -i -e 's|^ErrorLog.*|ErrorLog /dev/stderr|' /etc/apache2/apache2.conf \
    && echo 'ServerName www.tnmc.ca' >> /etc/apache2/apache2.conf

COPY docker/sites-available.tnmc.ca.conf /etc/apache2/sites-available/tnmc.ca.conf
RUN a2dissite 000-default && a2ensite tnmc.ca

USER tnmc
COPY --chown=tnmc . /tnmc
RUN cd /tnmc && mkdir auto && ./autosplit.pl

CMD ["/tnmc/docker-entrypoint.sh"]
