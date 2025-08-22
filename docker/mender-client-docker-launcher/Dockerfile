# hadolint ignore=DL3006
FROM src_context AS src_context

# hadolint ignore=DL3006
FROM base_context

RUN pip install --no-cache-dir requests==2.32.5

COPY --from=src_context mender-client-docker-launcher.py /opt/mender-client-docker/mender-client-docker-launcher.py
COPY docker-compose.yaml /opt/mender-client-docker/docker-compose.yaml
COPY entrypoint /entrypoint
ENTRYPOINT [ "/entrypoint" ]
