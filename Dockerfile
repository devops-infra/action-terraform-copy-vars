FROM alpine:3.23.4

# Copy all needed files
COPY terraform-copy-vars.py entrypoint.sh /
COPY alpine-packages.txt /tmp/alpine-packages.txt

# Install needed packages
SHELL ["/bin/sh", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3018
RUN set -eux; \
  xargs -r apk add --no-cache < /tmp/alpine-packages.txt; \
  chmod +x /entrypoint.sh; \
  python3 --version; \
  pip3 --version; \
  git --version; \
  rm -rf /var/cache/*; \
  rm -rf /root/.cache/*; \
  rm -rf /tmp/*

# Finish up
CMD ["python3", "--version"]
WORKDIR /github/workspace
ENTRYPOINT ["/entrypoint.sh"]
