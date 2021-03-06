FROM phusion/baseimage:0.9.15
MAINTAINER digitalman2112 <ian.cole@gmail.com>
ENV DEBIAN_FRONTEND noninteractive


# Set correct environment variables
ENV HOME /duc


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
RUN mkdir /duc && \
    wget -P /duc/ https://github.com/digitalman2112/duc/archive/master.zip && \
    unzip /duc/master.zip -d /duc/ && \
    rm /duc/master.zip && \
    cd /duc/duc-master/ && \
    autoreconf --install && \ 
    ./configure && \
    make && \
    make install && \
    ldconfig && \
    cp /duc/duc-master/www/duc.js /var/www/html && \
    cp /duc/duc-master/www/tooltipster-duc.css /var/www/html && \   
    wget -P /duc/ https://github.com/iamceege/tooltipster/archive/master.zip && \
    unzip /duc/master.zip -d /duc/ && \
    rm /duc/master.zip && \
    cp /duc/tooltipster-master/js/jquery.tooltipster.min.js /var/www/html && \
    cp /duc/tooltipster-master/css/tooltipster.css /var/www/html && \
    rm -r /duc/duc-master && \
    rm -r /duc/tooltipster-master
	

COPY duc.cgi /usr/lib/cgi-bin/
COPY 000-default.conf /etc/apache2/sites-available/
COPY index.html /var/www/html/

COPY duc_startup.sh /duc/

#create a starter database so that we can set permissions for cgi access
RUN mkdir /data && \
	duc index /data/ && \
	chmod 777 /duc/ && \
	chmod 777 /duc/.duc.db && \
	a2enmod cgi && \
	a2dismod deflate && \
	chmod +x /duc/duc_startup.sh && \
	chmod +x /usr/lib/cgi-bin/duc.cgi

ENV DUC_CGI_OPTIONS -i -l -t --maxlevels=5 --pixels=1000
VOLUME ["/data"]	
EXPOSE 80

CMD /duc/duc_startup.sh
