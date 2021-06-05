#!/bin/bash
set -e

if [ -n "${WAIT_FOR_IT}" ]; then
  wait-for-it.sh ${DATABASE_HOST}:${DATABASE_PORT}
fi

echo "running migrations"
python3 manage.py migrate

echo "updating catalog"
python3 updatecatalog

echo "starting $@"
exec "$@"
