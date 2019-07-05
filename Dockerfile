FROM lsiobase/alpine.nginx:3.10

# set version label
ARG BUILD_DATE
ARG VERSION
ARG LYCHEE_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

RUN \
 echo "**** install build packages ****" && \
 apk add --no-cache --virtual=build-dependencies \
	git \
	composer && \
 echo "**** install runtime packages ****" && \
 apk add --no-cache \
	ffmpeg \
	php7-exif \
	php7-gd \
	php7-imagick \
	php7-json \
	php7-mbstring \
	php7-mysqli \
	php7-pdo_mysql \
	php7-session \
	php7-tokenizer \
	php7-xml \
	php7-zip && \
 echo "**** install lychee ****" && \
 if [ -z ${LYCHEE_RELEASE+x} ]; then \
 	LYCHEE_RELEASE=$(curl -sX GET "https://api.github.com/repos/LycheeOrg/Lychee-Laravel/commits/master" \
	| awk '/sha/{print $4;exit}' FS='[""]'); \
 fi && \
 git clone --recursive https://github.com/LycheeOrg/Lychee-Laravel /app/lychee && \
 git -C /app/lychee checkout ${LYCHEE_RELEASE} && \
 echo "**** install composer dependencies ****" && \
 composer install \
 	-d /app/lychee \
	--no-dev \
	--no-suggest \
	--no-interaction && \
 echo "**** cleanup ****" && \
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/root/.cache \
	/tmp/*

# add local files
COPY root/ /
