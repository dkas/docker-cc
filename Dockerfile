# Docker lernen - ein Callcenter mit Silverstripe auf Nginx, PHP5-FPM und MariaDB

FROM        ubuntu:latest
MAINTAINER  Dominique Kaspar "dk@8gm.de"

# Update packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get dist-upgrade -y

# install Software: curl, wget
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install curl wget

# Set the locale
RUN locale-gen de_DE.UTF-8
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de
ENV LC_ALL de_DE.UTF-8

# Install MariaDB, nginx, php5 & modules
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server nginx php5-fpm php5-mysql php-apc php5-imap php5-mcrypt php5-curl php5-gd php5-json

# Configure nginx for PHP websites
ADD nginx_default.conf /etc/nginx/sites-available/default
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN mkdir -p /var/www && chown -R www-data:www-data /var/www

# Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-setuptools
RUN easy_install supervisor
ADD supervisord.conf /etc/supervisord.conf

EXPOSE 80

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
