FROM php:5.6-apache

RUN apt-get update \
		  && apt-get install -y \
		    libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmcrypt-dev \
		    zip \
		    unzip \
		    vim \
		    wget \
		    curl \
		    git \
				tar \
				file \
		    mysql-client \
		    moreutils \
		    dnsutils \
		    zlib1g-dev \
		    libicu-dev \
		    libmemcached-dev \
		    g++ \
				xz-utils \
		    memcached libz-dev libmemcached-dev libmemcached11 libmemcachedutil2 build-essential \
		    && pecl install memcached-2.2.0 \
		    && echo extension=memcached.so >> /usr/local/etc/php/conf.d/memcached.ini \
		    && pecl install memcache-2.2.7 \
		    && echo extension=memcache.so >> /usr/local/etc/php/conf.d/memcache.ini \
		    && docker-php-ext-install zip pdo_mysql mysqli gd iconv opcache


# Install mcrypt
RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
				    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
				    && docker-php-ext-install -j$(nproc) gd

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version

RUN ln -sf /dev/stdout /var/log/apache2/access.log \
	&& ln -sf /dev/stderr /var/log/apache2/error.log

RUN ln -snf /usr/share/zoneinfo/Europe/Lisbon /etc/localtime && echo Europe/Lisbon > /etc/timezone \
	&& printf '[PHP]\ndate.timezone = "%s"\n', Europe/Lisbon > /usr/local/etc/php/conf.d/tzone.ini \
	&& date

RUN a2enmod rewrite

ENTRYPOINT ["docker-php-entrypoint"]
WORKDIR /var/www/html
EXPOSE 80
CMD ["apache2-foreground"]
