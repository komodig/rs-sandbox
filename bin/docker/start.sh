#!/bin/bash

set -o errexit
set -o nounset

check_db_ready() {
     echo "checking database connectivity"
     # python manage.py db_ready
}

wait_for_db() {
    local host=${POSTGRES_DB_HOST:-db}
    local port=${POSTGRES_DB_PORT:-5432}
    check_db_ready
}

wait_for_db

#echo ">>> Compiling translated messages"
#python manage.py compilemessages

echo ">>> Compile static files "
python manage.py collectstatic --noinput


if [ "${RUN_DEV}" = "1" ]
  then
    echo ">>> Make Migrations "
    python manage.py makemigrations

    python manage.py migrate
fi

echo ">>> Run gunicorn"
gunicorn -c gunicorn_config.py backend.wsgi
#gunicorn backend.asgi:application -k uvicorn.workers.UvicornWorker
