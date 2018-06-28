FROM php:5.6-apache

RUN apt-get update \
	&& apt-get install -y \
		wget \
    zlib1g-dev \
		curl \
		git \
    vim \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
RUN composer --version
# Run docker-php-ext-install for available extensions
RUN docker-php-ext-install pdo pdo_mysql opcache zip

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
