# hadolint ignore=DL3006
FROM base_context

COPY docker-compose.yaml /opt/mender-client-docker/docker-compose.yaml
ENTRYPOINT [ "docker", "compose", "-f", "/opt/mender-client-docker/docker-compose.yaml", "up", "--detach" ]
