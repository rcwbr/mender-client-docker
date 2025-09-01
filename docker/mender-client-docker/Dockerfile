# hadolint ignore=DL3006
FROM base_context

ARG DEBIAN_FRONTEND=noninteractive
ENV DEVICE_TYPE=none
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN \
  mkdir -p /run/dbus \
  && apt-get update \
  && apt-get install --allow-unauthenticated --no-install-recommends -y \
    apt-transport-https=2.8.3* \
    ca-certificates=20240203* \
    curl=8.5.0* \
    dbus=1.14.10* \
    iproute2=6.1.0* \
    jq=1.7.1* \
    openssh-server=1:9.6p1* \
    wget=1.21.4* \
  && wget -qO- https://downloads.mender.io/repos/debian/gpg | tee /etc/apt/trusted.gpg.d/mender.asc \
  && echo "deb [arch=$(dpkg --print-architecture)] https://downloads.mender.io/repos/debian ubuntu/noble/stable main" | tee /etc/apt/sources.list.d/mender.list \
  && apt-get update \
  && apt-get install --allow-unauthenticated --no-install-recommends -y \
    mender-client4=5.0.1* \
    mender-connect=2.3.0* \
    xdelta3=3.0.11* \
  && apt-get clean \
  && apt-get autoclean \
  && apt-get autoremove \
  && rm -rf /var/cache/debconf \
  && rm -rf /var/lib/apt/lists/* \
  && mkdir -p /usr/share/mender/modules/v3 \
  && wget -q -P /usr/share/mender/modules/v3 https://raw.githubusercontent.com/mendersoftware/mender-update-modules/master/docker/module/docker \
  && wget -q https://raw.githubusercontent.com/mendersoftware/app-update-module/1.1.0/src/app \
          -O /usr/share/mender/modules/v3/app \
          && chmod +x /usr/share/mender/modules/v3/app \
  && mkdir -p /usr/share/mender/app-modules/v1 \
  && wget -q https://raw.githubusercontent.com/mendersoftware/app-update-module/1.1.0/src/app-modules/docker-compose \
          -O /usr/share/mender/app-modules/v1/docker-compose \
          && chmod +x /usr/share/mender/app-modules/v1/docker-compose \
  && wget -q https://raw.githubusercontent.com/mendersoftware/app-update-module/1.1.0/conf/mender-app.conf \
          -O /etc/mender/mender-app.conf \
  && wget -q https://raw.githubusercontent.com/mendersoftware/app-update-module/1.1.0/conf/mender-app-docker-compose.conf \
        -O /etc/mender/mender-app-docker-compose.conf

COPY entrypoint /entrypoint
COPY setup-entrypoint /setup-entrypoint
ENTRYPOINT [ "/entrypoint" ]
