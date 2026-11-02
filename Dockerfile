FROM debian:13-slim@sha256:f6b08b09a05725f9431502d3b5714f5c4576e82c1a84fa1debe0c24a7e0c3ec4 AS build
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
FROM gcr.io/distroless/python3-debian13:latest@sha256:9a1ed29d41d7695245ff86bc2e08684d3dd253a3f9c8ca45677427f9f4fe3598
COPY --from=build-venv /venv /venv
COPY ./app /app
WORKDIR /app
ENTRYPOINT ["/venv/bin/python3", "zte_exporter.py"]

