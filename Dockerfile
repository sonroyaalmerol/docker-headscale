FROM debian:bookworm-slim

ARG VERSION=0.23.0-alpha11
ARG ARCH=amd64

ADD https://github.com/juanfont/headscale/releases/download/v${VERSION}/headscale_${VERSION}_linux_${ARCH}.deb /tmp/headscale.deb

ADD https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${ARCH} /usr/bin/yq

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN apt-get update \
  && apt-get install -y ca-certificates \
    inotify-tools \
  && apt-get install /tmp/headscale.deb \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && rm -rf /tmp/headscale.deb \
  && chmod +x /usr/bin/yq \
  && chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080/tcp

CMD ["/usr/local/bin/entrypoint.sh"]
