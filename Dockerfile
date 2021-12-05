FROM ubuntu:18.04

EXPOSE 80
VOLUME /backups

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
       apache2 \
       cpanminus \
       libapache2-mod-perl2 \
       libapache2-reload-perl \
       libdbd-mysql-perl \
       libhtml-treebuilder-xpath-perl \
       libmail-sendmail-perl \
       make \
       postfix \
       tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm CGI \
    && cpanm CGI::Lite \
    && a2enmod cgid

ENV \
  APACHE_LOG_DIR=/var/log/apache2 \
  APACHE_PID_FILE=/var/run/apache2/apache2.pid \
  APACHE_RUN_DIR=/var/run/apache2 \
  APACHE_RUN_GROUP=tnmc \
  APACHE_RUN_USER=tnmc

RUN useradd -ms /bin/bash tnmc \
    && mkdir -p $APACHE_RUN_DIR \
    && chown tnmc $APACHE_RUN_DIR \
    && mkdir -p $APACHE_LOG_DIR \
    && chown -R tnmc $APACHE_LOG_DIR \
    && sed -i -e 's|^ErrorLog.*|ErrorLog /dev/stderr|' /etc/apache2/apache2.conf \
    && echo 'ServerName www.tnmc.ca' >> /etc/apache2/apache2.conf

COPY docker/sites-available.tnmc.ca.conf /etc/apache2/sites-available/tnmc.ca.conf
RUN a2dissite 000-default && a2ensite tnmc.ca

USER tnmc
COPY --chown=tnmc . /tnmc
RUN cd /tnmc && mkdir auto && make

CMD ["/usr/sbin/apache2", "-DFOREGROUND"]
