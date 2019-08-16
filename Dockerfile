FROM php:7.2-fpm AS builder

RUN apt-get update   
    
RUN \
    apt-get install -y git libgearman-dev && \
    cd /tmp && \
    git clone https://github.com/wcgallego/pecl-gearman.git && \
    cd pecl-gearman && \
    phpize && \
    ./configure && \
    make && make install && \
    rm -rf /tmp/pecl-gearman && \
    docker-php-ext-enable gearman

RUN \
    apt-get install -y libc-client-dev libkrb5-dev && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

RUN \
    pecl install mongodb && \
    pecl install mailparse

FROM gaozhi/php7-fpm-phalcon3:7.2 AS final

RUN apt-get update

RUN apt-get install -y tesseract-ocr cron imagemagick ffmpeg

COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-20170718/ /usr/local/lib/php/extensions/no-debug-non-zts-20170718/

RUN apt-get install -y libgearman-dev libc-client-dev libkrb5-dev
RUN docker-php-ext-enable gearman imap mongodb mailparse

RUN \
    apt-get clean && \
    rm -rf /var/lib/apt/list/*

RUN \
    mkdir -p ${HOME}/php-default-conf && \
    cp -R /usr/local/etc/* ${HOME}/php-default-conf

ADD ["./docker-entrypoint.sh", "/root/"]

ENTRYPOINT ["sh", "-c", "${HOME}/docker-entrypoint.sh"]