FROM openjdk:8-jre-alpine
MAINTAINER Jerrico Gamis <jecklgamis@gmail.com>

RUN apk update && apk add bash curl
RUN addgroup -S gatling && adduser -S gatling -G gatling
RUN mkdir -m 0755 -p /usr/local/app/bin

COPY target/gatling-test-example.jar /usr/local/app/bin
COPY docker-entrypoint.sh /usr/local/app/bin

RUN chown -R gatling:gatling /usr/local/app
RUN chmod +x /usr/local/app/bin/docker-entrypoint.sh

CMD ["/usr/local/app/bin/docker-entrypoint.sh"]

