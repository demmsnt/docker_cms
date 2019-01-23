#!/bin/sh
#TODO start.sql
cd /usr/src/app

postgres_ready() {
python3 << END
import sys

import psycopg2

try:
    psycopg2.connect(
        dbname="${POSTGRES_USER}",
        user="${POSTGRES_USER}",
        password="${POSTGRES_PASSWORD}",
        host="db",
        port="5432",
    )
except psycopg2.OperationalError as e:
    print("e=", e)
    sys.exit(-1)
sys.exit(0)

END
}
until postgres_ready; do
  >&2 echo 'Waiting for PostgreSQL to become available...'
  sleep 1
done
>&2 echo 'PostgreSQL is available'

if [ -e migrate.flag ]
then
    echo "Migrate flag not exists. Process migration"
    python manage.py makemigrations
    python manage.py migrate
    mv migrate.flag migrate.flag.processed
else
    echo "Migrate flag not exists. Do not process migration"
fi

if [ -e collectstatic.flag ]
then
    echo "Collectstatic flag not exists. Process"
    python3 manage.py collectstatic --no-input
    mv collectstatic.flag collectstatic.flag.processed
else
    echo "Collectstatic flag not exists. Do not process collectstatic"
fi

python3 /usr/bin/gunicorn3 _app.wsgi -c gunicorn.cfg
