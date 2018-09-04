FROM gaozhi/php7-fpm-phalcon3:7.2

RUN \
    apt-get update && \
    apt-get install -y libgearman-dev tesseract-ocr cron imagemagick libc-client-dev libkrb5-dev ffmpeg

RUN \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap

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
    pecl install mongodb && \
    docker-php-ext-enable mongodb && \
    pecl install mailparse && \
    docker-php-ext-enable mailparse && \
    pecl clear-cache

RUN \
    mkdir -p ${HOME}/php-default-conf && \
    cp -R /usr/local/etc/* ${HOME}/php-default-conf

ADD ["./docker-entrypoint.sh", "/root/"]

ENTRYPOINT ["sh", "-c", "${HOME}/docker-entrypoint.sh"]