# Docker lernen - ein Callcenter mit Silverstripe auf Nginx, PHP5-FPM und MariaDB

FROM        ubuntu:latest
MAINTAINER  Dominique Kaspar "dk@8gm.de"

# Update packages
RUN DEBIAN_FRONTEND=noninteractive apt-get update

# Upgrade Distribution, fetch security updates
RUN DEBIAN_FRONTEND=noninteractive apt-get -y dist-upgrade

# install Software: curl, wget
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install curl wget

# Set the locale
RUN locale-gen de_DE.UTF-8
ENV LANG de_DE.UTF-8
ENV LANGUAGE de_DE:de
ENV LC_ALL de_DE.UTF-8

# Install MariaDB, nginx, php5 & modules
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mariadb-server nginx php5-fpm php5-mysql php-apc php5-imap php5-mcrypt php5-curl php5-gd php5-json tidy php5-tidy

# Custom my.cnf for mySQL (MariaDB), linking socket to default location
ADD my.cnf /etc/mysql/my.cnf
RUN mkdir /var/run/mysqld && ln -s /tmp/mysqld.sock /var/run/mysqld/mysqld.sock

# Configure nginx for PHP websites
ADD nginx_default.conf /etc/nginx/sites-available/default
ADD nginx.conf /etc/nginx/nginx.conf
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN sed -i 's/\;date.timezone\ \=/date.timezone\ \=\ Europe\/Berlin/g' /etc/php5/fpm/php.ini 
RUN sed -i 's/\memory_limit\ \=\ 128M/memory_limit\ \=\ 512M/g' /etc/php5/fpm/php.ini
RUN mkdir -p /var/www && chown -R www-data:www-data /var/www

# Supervisord
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install python-setuptools
RUN easy_install supervisor
ADD supervisord.conf /etc/supervisord.conf

# Download and Extract Silverstripe
RUN wget -O /tmp/Silverstripe.tgz http://www.silverstripe.org/assets/releases/SilverStripe-cms-v3.1.13.tar.gz
RUN tar -xzvf /tmp/Silverstripe.tgz -C /var/www
RUN chown -R www-data:www-data /var/www

# Callcenter
ADD cc.tgz /tmp/cc.tgz
RUN tar -xzvf /tmp/cc.tgz -C /var/www/

EXPOSE 80

CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]
