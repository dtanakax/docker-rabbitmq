#!/bin/bash
set -e

if [ "$1" = "rabbitmq-server" ]; then
    chown -R rabbitmq:rabbitmq /var/lib/rabbitmq
fi

exec "$@"