FROM php:7.2-fpm AS builder

RUN \
    apt-get update && \
    apt-get install -y git libwebp-dev libjpeg-dev libpng-dev libfreetype6-dev libgmp-dev libicu-dev libgearman-dev libc-client-dev libkrb5-dev

RUN \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/include --with-webp-dir=/usr/include --with-freetype-dir=/usr/include && \
    docker-php-ext-install pdo_mysql sockets gd opcache exif gmp bcmath intl

RUN \
    pecl install redis && \
    pecl install xdebug

RUN \
    cd ${HOME} && \
    git clone https://github.com/phalcon/cphalcon.git && \
    cd cphalcon && \
    git checkout v3.4.4 && \
    cd build/php7/64bits && \
    phpize && \
    export CFLAGS="-O2 -g" && \
    ./configure && \
    make && make install
    
RUN \
    cd /tmp && \
    git clone https://github.com/wcgallego/pecl-gearman.git && \
    cd pecl-gearman && \
    phpize && \
    ./configure && \
    make && make install && \
    rm -rf /tmp/pecl-gearman && \
    docker-php-ext-enable gearman

RUN \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

RUN \
    pecl install mongodb && \
    pecl install mailparse

FROM php:7.2-fpm AS final

RUN apt-get update

RUN apt-get install -y libwebp-dev libjpeg-dev libpng-dev libfreetype6-dev libgmp-dev libicu-dev libgearman-dev libc-client-dev libkrb5-dev tesseract-ocr cron imagemagick ffmpeg

COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20170718/ /usr/local/lib/php/extensions/no-debug-non-zts-20170718/

RUN docker-php-ext-enable pdo_mysql sockets gd opcache exif gmp bcmath intl redis phalcon gearman imap mongodb mailparse

RUN \
    apt-get clean && \
    rm -rf /var/lib/apt/list/*

RUN \
    mkdir -p ${HOME}/php-default-conf && \
    cp -R /usr/local/etc/* ${HOME}/php-default-conf

ADD ["./docker-entrypoint.sh", "/root/"]

CMD ["sh", "-c", "${HOME}/docker-entrypoint.sh"]