FROM ubuntu:26.04

EXPOSE 80

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       apache2 \
       ca-certificates \
       libcgi-pm-perl \
       libdbd-mysql-perl \
       libjson-perl \
       liblwp-protocol-https-perl \
       libmail-sendmail-perl \
       libsasl2-modules \
       libwww-perl \
       postfix \
       sudo \
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

# Set up postfix's chroot (systemd normally does this), fix smtp.gmail.com DNS
# resolution, and allow the non-root user to start postfix
RUN mkdir -p /var/spool/postfix/etc \
    && cp /etc/host.conf /etc/hosts /etc/localtime /etc/nsswitch.conf /etc/services /var/spool/postfix/etc/ \
    && echo 'nameserver 8.8.8.8' > /var/spool/postfix/etc/resolv.conf \
    && echo 'tnmc ALL=(ALL) NOPASSWD: /usr/sbin/postfix' > /etc/sudoers.d/tnmc

USER tnmc
COPY --chown=tnmc . /tnmc
RUN cd /tnmc && mkdir auto && ./autosplit.pl

CMD ["/tnmc/docker-entrypoint.sh"]
