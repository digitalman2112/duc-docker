FROM phusion/baseimage:0.9.11
MAINTAINER digitalman2112 <ian.cole@gmail.com>
ENV DEBIAN_FRONTEND noninteractive

# Set correct environment variables
ENV HOME /root

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

RUN add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty universe multiverse"
RUN add-apt-repository "deb http://us.archive.ubuntu.com/ubuntu/ trusty-updates universe multiverse"

# Install Dependencies
RUN apt-get update -qq && \ 
	apt-get install -qq --force-yes libcairo2-dev libpango1.0-dev libtokyocabinet-dev wget unzip dh-autoreconf apache2 && \ 
	apt-get autoremove && \
	apt-get autoclean

# Install duc
RUN wget -P /tmp/ https://github.com/digitalman2112/duc/archive/master.zip
RUN unzip /tmp/master.zip -d /tmp/
RUN cd /tmp/duc-master/ && \
	autoreconf --install && \
	./configure && \
	make && \
	make install && \
	ldconfig
	

COPY duc.cgi /usr/lib/cgi-bin/

#RUN { echo "#!/bin/sh" ; echo "/usr/local/bin/duc cgi -d /root/.duc.db"; } >> /usr/lib/cgi-bin/duc.cgi
RUN chmod +x /usr/lib/cgi-bin/duc.cgi

COPY 000-default.conf /etc/apache2/sites-available/
RUN a2enmod cgi

RUN mkdir /data
RUN duc index /data/
RUN chmod 777 /root/
RUN chmod 777 /root/.duc.db

EXPOSE 80

COPY duc_startup.sh /root/
RUN chmod +x /root/duc_startup.sh

# By default, simply start apache.
#CMD /usr/sbin/apache2ctl -D FOREGROUND

CMD /root/duc_startup.sh
