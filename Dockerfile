FROM debian:13-slim@sha256:a72b4433de1cf7d6bae0c4cee74d0547f58601a643b3375f070c51600d63b6b2 AS build
RUN apt-get update && \
    apt-get install --no-install-suggests --no-install-recommends --yes python3-venv gcc libpython3-dev && \
    python3 -m venv /venv && \
    /venv/bin/pip install --upgrade pip setuptools wheel

# Build the virtualenv as a separate step: Only re-execute this step when requirements.txt changes
FROM build AS build-venv
COPY ./app/requirements.txt /requirements.txt
RUN /venv/bin/pip install --disable-pip-version-check -r /requirements.txt

# Copy the virtualenv into a distroless image.
# distroless publishes no versioned tags, so :latest is pinned by digest and
# renovate rolls the digest forward.
FROM gcr.io/distroless/python3-debian13:latest@sha256:5bac3c3ab33426c460db63504cd1a267b3326b9f804d21c63359492858d1beda
COPY --from=build-venv /venv /venv
COPY ./app /app
WORKDIR /app
ENTRYPOINT ["/venv/bin/python3", "zte_exporter.py"]

