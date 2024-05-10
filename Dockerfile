FROM debian:bookworm-slim

ARG VERSION=0.23.0-alpha11
ARG ARCH=amd64

ADD https://github.com/juanfont/headscale/releases/download/v${VERSION}/headscale_${VERSION}_linux_${ARCH}.deb /tmp/headscale.deb

ADD https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH} /usr/bin/yq

COPY entrypoint.sh /srv/entrypoint.sh
ADD scripts /srv/scripts
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set user and group
ARG user=headscale
ARG group=headscale
ENV PUID=1000
ENV PGID=1000
RUN groupadd -g ${PGID} ${group}
RUN useradd -u ${PUID} -g ${group} -s /bin/sh -m ${user}

ENV CONFIG_DIR=/etc/headscale/config.yaml.d

RUN apt-get update \
  && apt-get install -y ca-certificates \
    inotify-tools \
    supervisor \
  && apt-get install /tmp/headscale.deb \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && rm -rf /tmp/headscale.deb \
  && mkdir -p ${CONFIG_DIR} \
  && chmod +x /usr/bin/yq \
  && chmod +x /srv/entrypoint.sh \
  && chmod +x /srv/scripts/*.sh \
  && chown -R headscale: /etc/headscale

USER ${PUID}:${PGID}

EXPOSE 8080/tcp

CMD ["/srv/entrypoint.sh"]
