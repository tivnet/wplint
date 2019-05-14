FROM alpine:3.9

# Argument's default values. See the `--build-arg` build parameter in package.json.
ARG version=NO_VERSION
ARG description=NO_DESCRIPTION

# The Author.
LABEL maintainer="gregory@tiv.net"
LABEL version="${version}"
LABEL description="${description}"

RUN set -e \
  && apk add --no-cache \
  curl \
  wget \
  git

#
# https://github.com/codecasts/php-alpine
#

# trust this project public key to trust the packages.
ADD https://dl.bintray.com/php-alpine/key/php-alpine.rsa.pub /etc/apk/keys/php-alpine.rsa.pub

## you may join the multiple run lines here to make it a single layer

# make sure you can use HTTPS
RUN apk --update add ca-certificates

# add the repository, make sure you replace the correct versions if you want.
RUN echo "@php https://dl.bintray.com/php-alpine/v3.9/php-7.3" >> /etc/apk/repositories

# install php and some extensions
# notice the @php is required to avoid getting default php packages from alpine instead.
RUN apk add \
    php7@php \
    php7-phar@php \
    && ln -s /usr/bin/php7 /usr/bin/php \
    && php -v \
    && php -m

# Install PHPCS
RUN wget -nv -O /usr/bin/phpcs.phar https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && echo "#!/usr/bin/env sh" > /usr/bin/phpcs \
    && echo "php /usr/bin/phpcs.phar \$@" >> /usr/bin/phpcs \
    && chmod 775 /usr/bin/phpcs \
    && phpcs --version

RUN git clone -b master https://github.com/WordPress-Coding-Standards/WordPress-Coding-Standards.git /wpcs \
    && phpcs --config-set installed_paths /wpcs \
    && phpcs --config-set default_standard WordPress \
    && phpcs --config-set php_version 50600

