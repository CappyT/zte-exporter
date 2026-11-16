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
FROM gcr.io/distroless/python3-debian13:latest@sha256:60faad2efce94a847f32e2adbcaefeb2e4fd3e3a78075a3abb600904a5e010e9
COPY --from=build-venv /venv /venv
COPY ./app /app
WORKDIR /app
ENTRYPOINT ["/venv/bin/python3", "zte_exporter.py"]

