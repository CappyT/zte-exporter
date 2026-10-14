FROM debian:13-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f AS build
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
FROM gcr.io/distroless/python3-debian12:latest@sha256:2fdb05402a2cf21cf78fdb3ba4c5db167241e9e498140f5bf689d7efb773731f
COPY --from=build-venv /venv /venv
COPY ./app /app
WORKDIR /app
ENTRYPOINT ["/venv/bin/python3", "zte_exporter.py"]

