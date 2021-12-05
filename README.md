# Backend

## Overview

## Prerequisites
* [Docker](https://docs.docker.com/install/#server)
* [Docker Compose](https://docs.docker.com/compose/install/)
* Basic knowledge of Django and Python.

## Quick Start

1. Install the prerequisites if you haven't already.
2. After cloning this repository, navigate to the root folder and run the following command to start with backend:
    * make sure your SSH key is NOT protected with a password
    * copy the file `.env.example` to a file named `.env`, fill in any secrets needed from Berglas
    * build backend image with ssh key: `docker-compose build --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"`
   On first run, Docker builds the required images and installs the dependencies listed in [`pyproject.toml`](./pyproject.toml)
    and locked in [`poetry.lock`](./poetry.lock).
    * Run `docker network create global_network`
3. It might be necessary to apply database migrations BEFORE starting the container for the first time:

    ```
    docker-compose run backend python manage.py migrate
    ```

4. Run `$ docker-compose up -d` to start the backend app (`$ docker-compose down` stops it again)
5. After the app has booted, connect to backend container:

    ```
    docker exec -it backend_backend_1 bash
    ```
   (you can exit the container by executing `exit` on the shell)

6. In the container, run the following setup commands:

     Create and execute migration files to initialize your database

       * To __create__ DB migration files, in the app container `backend` run:
           ```
           python manage.py makemigrations
           ```

       * To __apply__ new DB migrations, in the app container `backend` run:
           ```
           python manage.py migrate
           ```

7. To update / add dependencies to poetry you can use the included builder image:
    ```
    docker image build -t backend_builder --file ./Dockerfile.builder . --build-arg SSH_PRIVATE_KEY="$(cat ~/.ssh/id_rsa)"

    docker run --rm -it --privileged --mount type=bind,source=/`pwd`,target=/srv/www backend_builder bash

     ```

#### Local Environment
After running all docker services using docker-compose, set `DJANGO_READ_DOT_ENV_FILE` to true.
Then you're able to run any django commands from your local machine.

### Accessing the backend server locally
Once the containers have been started using docker-compose, you can go to localhost:8080/swagger/
to explore the available endpoints and to localhost:8080/admin/ to access Django's admin GUI.

#### Run translations script

To manually run translation files in folder locale  (not recommended) run the following command:
```
python manage.py compilemessages
```
    Important
    this command will run during docker build time in live environment and during container startup in locale environment


#### throttling
We are using the default REST framework throttling rate classes.
for anonymous users we set a limit of 100 requests per hour and for authenticated users it's 1000 requests per hour.

### Commit hooks
```bash
pre-commit install
pre-commit install -t commit 
```


## psycopg2 Linux (Debian/Ubuntu)
If `poetry install` fails on psycopg2 try:
`pip install psycopg2-binary`

If app complains about missing module uvicorn
`pip install uvicorn`

