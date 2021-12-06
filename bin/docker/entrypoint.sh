#!/bin/bash

set -o errexit
set -o nounset

# TODO wait for database ready
welcome() {
    echo "Welcome to rs-backend!"
}

welcome

exec "$@"
