### Base image for builder and final image
FROM python:3.9 as base

RUN apt-get update && apt-get install -y \
    gettext netcat \
    && rm -rf /var/lib/apt/lists/*

ARG RUN_DEV=0

ENV PYTHONFAULTHANDLER=1 \
    PYTHONHASHSEED=random \
    PYTHONUNBUFFERED=1\
    RUN_DEV=${RUN_DEV}

WORKDIR /srv/www

### Build and install packages
FROM base as builder

ARG SSH_PRIVATE_KEY

ENV PIP_DEFAULT_TIMEOUT=100 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1 \
    POETRY_VERSION=1.1.4


# Install Python dependencies
RUN pip install "poetry==$POETRY_VERSION"
RUN python -m venv /venv

COPY pyproject.toml poetry.lock ./

RUN if [ "${RUN_DEV}" = "1" ]; then \
        poetry export --no-interaction --without-hashes --dev -f requirements.txt | /venv/bin/pip install -r /dev/stdin; \
    else \
        poetry export --no-interaction --without-hashes -f requirements.txt | /venv/bin/pip install -r /dev/stdin; \
    fi


COPY . .
RUN poetry build
RUN /venv/bin/pip install dist/*.whl

### satisfy README
RUN /venv/bin/pip install psycopg2-binary uvicorn

### Final image
FROM base as final

COPY --from=builder /venv /venv

COPY . .

# Enable Virtual Env
ENV VIRTUAL_ENV=/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

RUN chmod u+x bin/docker/entrypoint.sh
ENTRYPOINT ["bin/docker/entrypoint.sh"]

RUN chmod u+x ./bin/docker/start.sh
CMD ["bin/docker/start.sh"]
