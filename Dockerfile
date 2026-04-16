FROM eclipse-temurin:21-jre-jammy
LABEL maintainer="Jerrico Gamis <jecklgamis@gmail.com>"

ENV APP_HOME=/app

COPY target/gatling-scala-example.jar ${APP_HOME}/bin/
COPY docker-entrypoint.sh /

RUN chmod +x /docker-entrypoint.sh && \
    groupadd -r gatling && useradd -r -g gatling gatling && \
    chown -R gatling:gatling ${APP_HOME} /docker-entrypoint.sh

USER gatling
WORKDIR ${APP_HOME}

CMD ["/docker-entrypoint.sh"]
