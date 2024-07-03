FROM eclipse-temurin:21-jammy
MAINTAINER Jerrico Gamis <jecklgamis@gmail.com>

ENV APP_HOME /app
RUN mkdir -m 0755 -p ${APP_HOME}/bin

COPY target/gatling-scala-example.jar ${APP_HOME}/bin/
COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh

RUN groupadd -r gatling && useradd -r -ggatling gatling
RUN chown -R gatling:gatling ${APP_HOME}
RUN chown gatling:gatling /docker-entrypoint.sh

USER gatling
WORKDIR ${APP_HOME}

CMD ["/docker-entrypoint.sh"]

