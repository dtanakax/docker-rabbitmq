# Set the base image
FROM dtanakax/debianjp:wheezy

# File Author / Maintainer
MAINTAINER Daisuke Tanaka, dtanakax@gmail.com

ENV DEBIAN_FRONTEND noninteractive

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r rabbitmq && useradd -r -d /var/lib/rabbitmq -m -g rabbitmq rabbitmq

# http://www.rabbitmq.com/install-debian.html
# "Please note that the word testing in this line refers to the state of our release of RabbitMQ, not any particular Debian distribution."
RUN apt-key adv --keyserver pool.sks-keyservers.net --recv-keys F78372A06FF50C80464FC1B4F7B8CEA6056E8E56
RUN echo 'deb http://www.rabbitmq.com/debian/ testing main' > /etc/apt/sources.list.d/rabbitmq.list

ENV RABBITMQ_VERSION 3.5.1-1

RUN apt-get -y update && \
    apt-get install -y rabbitmq-server=$RABBITMQ_VERSION && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean all

ENV PATH /usr/lib/rabbitmq/bin:$PATH

# get logs to stdout (thanks to http://www.superpumpup.com/docker-rabbitmq-stdout for inspiration)
# TODO figure out what we'd need to do to add "(sasl_)?" to this sed and have it work ("{"init terminating in do_boot",{rabbit,failure_during_boot,{error,{cannot_log_to_tty,sasl_report_tty_h,not_installed}}}}")
RUN sed -E 's!^(\s*-rabbit\s+error_logger)\s+\S*!\1 tty!' /usr/lib/rabbitmq/lib/rabbitmq_server-*/sbin/rabbitmq-server > /tmp/rabbitmq-server \
    && chmod +x /tmp/rabbitmq-server \
    && mv /tmp/rabbitmq-server /usr/lib/rabbitmq/lib/rabbitmq_server-*/sbin/rabbitmq-server

# Install plugins
RUN rabbitmq-plugins enable --offline rabbitmq_mqtt
RUN rabbitmq-plugins enable --offline rabbitmq_management

RUN echo '[{rabbit, [{loopback_users, []}]}].' > /etc/rabbitmq/rabbitmq.config

VOLUME ["/var/lib/rabbitmq"]

COPY start.sh /start.sh
RUN chmod +x /start.sh
ENTRYPOINT ["./start.sh"]

# Set the port
# RabbitMQ main:      5672
# Management WebUI:   15672
EXPOSE 5672 15672

CMD ["rabbitmq-server"]
