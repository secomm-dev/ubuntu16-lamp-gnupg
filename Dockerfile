FROM ubuntu:16.04
MAINTAINER Soulblade "phuocvu@builtwithdigital.com"

# Install Apache2 & Development Tools
RUN apt-get update && apt-get -y install python-software-properties software-properties-common vim sudo
RUN LC_ALL=C.UTF-8 add-apt-repository -y ppa:ondrej/php && \
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C && \
    apt-get update && apt-get -y install apache2 libgnutls-dev bzip2 make gettext texinfo gnutls-bin \
    wget build-essential libbz2-dev zlib1g-dev libncurses5-dev libsqlite3-dev libldap2-dev libgnutls28-dev \
    php5.6 php5.6-mcrypt php5.6-mbstring php5.6-curl php5.6-cli php5.6-mysql php5.6-gd \
    libapache2-mod-php5.6 php5.6-imagick php5.6-redis php5.6-common php5.6-json php5.6-xsl php5.6-intl \
    libgpgme11-dev php5.6-dev php-pear && apt-get -y autoremove
# Config PHP, Apache
RUN sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/5.6/apache2/php.ini \
 && sed -i 's/post_max_size = 8M/post_max_size = 256M/g' /etc/php/5.6/apache2/php.ini \
 && sed -i 's/short_open_tag = Off/short_open_tag = On/g' /etc/php/5.6/apache2/php.ini \
 && sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 256M/g' /etc/php/5.6/apache2/php.ini \
 && sed -i 's/;opcache.save_comments/opcache.save_comments/g' /etc/php/5.6/apache2/php.ini \
 && sed -i 's/export APACHE_RUN_USER=www-data/export APACHE_RUN_USER=web/g' /etc/apache2/envvars
RUN a2enmod rewrite
RUN phpenmod mcrypt
# Install PHP gnupg extension
RUN pecl install gnupg
RUN sed -i 's?extension=msql.so?extension=msql.so\nextension=gnupg.so?' /etc/php/5.6/apache2/php.ini
RUN sed -i 's?extension=msql.so?extension=msql.so\nextension=gnupg.so?' /etc/php/5.6/cli/php.ini
# Add composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer
# Install Magerun
RUN wget https://files.magerun.net/n98-magerun.phar && chmod +x ./n98-magerun.phar && mv ./n98-magerun.phar /usr/bin/
# Install GnuPG 2.2.x
RUN mkdir -p /var/src/gnupg22 && cd /var/src/gnupg22
RUN gpg --list-keys
RUN gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys \
    249B39D24F25E3B6 04376F3EE0856959 2071B08A33BD3F06 8A861B1C7EFD60D9
RUN wget -c https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.31.tar.gz && \
wget -c https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-1.31.tar.gz.sig && \
wget -c https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.3.tar.gz && \
wget -c https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-1.8.3.tar.gz.sig && \
wget -c https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.1.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/libassuan/libassuan-2.5.1.tar.bz2.sig && \
wget -c https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/libksba/libksba-1.3.5.tar.bz2.sig && \
wget -c https://www.gnupg.org/ftp/gcrypt/npth/npth-1.5.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/npth/npth-1.5.tar.bz2.sig && \
wget -c https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.1.0.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/pinentry/pinentry-1.1.0.tar.bz2.sig && \
wget -c https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.9.tar.bz2 && \
wget -c https://www.gnupg.org/ftp/gcrypt/gnupg/gnupg-2.2.9.tar.bz2.sig && \
gpg --verify libgpg-error-1.31.tar.gz.sig && tar -xzf libgpg-error-1.31.tar.gz && \
gpg --verify libgcrypt-1.8.3.tar.gz.sig && tar -xzf libgcrypt-1.8.3.tar.gz && \
gpg --verify libassuan-2.5.1.tar.bz2.sig && tar -xjf libassuan-2.5.1.tar.bz2 && \
gpg --verify libksba-1.3.5.tar.bz2.sig && tar -xjf libksba-1.3.5.tar.bz2 && \
gpg --verify npth-1.5.tar.bz2.sig && tar -xjf npth-1.5.tar.bz2 && \
gpg --verify pinentry-1.1.0.tar.bz2.sig && tar -xjf pinentry-1.1.0.tar.bz2 && \
gpg --verify gnupg-2.2.9.tar.bz2.sig && tar -xjf gnupg-2.2.9.tar.bz2 && \
cd libgpg-error-1.31/ && ./configure && make && make install && cd ../ && \
cd libgcrypt-1.8.3 && ./configure && make && make install && cd ../ && \
cd libassuan-2.5.1 && ./configure && make && make install && cd ../ && \
cd libksba-1.3.5 && ./configure && make && make install && cd ../ && \
cd npth-1.5 && ./configure && make && make install && cd ../ && \
cd pinentry-1.1.0 && ./configure --enable-pinentry-curses --disable-pinentry-qt4 && \
make && make install && cd ../ && \
cd gnupg-2.2.9 && ./configure && make && make install && \
echo "/usr/local/lib" > /etc/ld.so.conf.d/gpg2.conf && ldconfig -v && \
echo "Complete!!!"
# Create sudo user
RUN adduser --home /home/web web
RUN usermod -aG root web && usermod -aG www-data web
RUN echo "web      ALL=(ALL)       ALL" >> /etc/sudoers
RUN mkdir -p /home/web/.gnupg && \
chown -R web:web /home/web/.gnupg && \
su -s /bin/bash -c "gpg -k" web && \
su -s /bin/bash -c "echo 'allow-loopback-pinentry' >> /home/web/.gnupg/gpg-agent.conf && \
echo 'pinentry-mode loopback' >> /home/web/.gnupg/gpg.conf" web

VOLUME ["/var/www/html", "/var/log/httpd", "/var/log/mysql", "/var/lib/mysql", "/etc/apache2"]
WORKDIR /var/www/html

ADD conf/apache_default /etc/apache2/sites-available/000-default.conf
ADD conf/start-apache2.sh /start-apache2.sh
RUN chmod 755 /*.sh

CMD ["/start-apache2.sh"]
