FROM jecklgamis/java-runtime:latest
MAINTAINER Jerrico Gamis <jecklgamis@gmail.com>

RUN groupadd -r app && useradd -r -g app app
RUN mkdir -m 0755 -p /usr/local/app/bin

COPY target/gatling-test-example.jar /usr/local/app/bin
COPY docker-entrypoint.sh /usr/local/app/bin

RUN chown -R app:app /usr/local/app
RUN chmod +x /usr/local/app/bin/docker-entrypoint.sh

CMD ["/usr/local/app/bin/docker-entrypoint.sh"]

