#!/bin/bash

set -o errexit
set -o nounset

welcome() {
    echo "Welcome to rs-backend!"
}

welcome

exec "$@"
