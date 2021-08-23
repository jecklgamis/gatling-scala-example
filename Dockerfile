FROM openjdk:8-jre-alpine
MAINTAINER Jerrico Gamis <jecklgamis@gmail.com>

RUN apk update && apk add bash curl

ENV APP_HOME /app
RUN mkdir -m 0755 -p ${APP_HOME}/bin

COPY target/gatling-test-example.jar ${APP_HOME}/bin/
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN addgroup -S gatling && adduser -S gatling -G gatling
RUN chown -R gatling:gatling ${APP_HOME}
RUN chown gatling:gatling /docker-entrypoint.sh

USER gatling
WORKDIR ${APP_HOME}

CMD ["/docker-entrypoint.sh"]

