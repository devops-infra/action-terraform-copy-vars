# Use a clean tiny image to store artifacts in
FROM alpine:3.11

ARG BUILD_DATE=2020-04-01T00:00:00Z
ARG VCS_REF=abcdef1
ARG VERSION=v0.0
# For http://label-schema.org/rc1/#build-time-labels
LABEL \
  com.github.actions.author="Krzysztof Szyper <biotyk@mail.com>" \
  com.github.actions.color="white" \
  com.github.actions.description="GitHub Action automatically copying variables' definitions from a single file to many modules." \
  com.github.actions.icon="wind" \
  com.github.actions.name="Copy variables to many Terraform modules at once" \
  org.label-schema.build-date="${BUILD_DATE}" \
  org.label-schema.description="GitHub Action automatically copying variables' definitions from a single file to many modules." \
  org.label-schema.name="action-terraform-copy-vars" \
  org.label-schema.schema-version="1.0"	\
  org.label-schema.url="https://christophshyper.github.io/" \
  org.label-schema.vcs-ref="${VCS_REF}" \
  org.label-schema.vcs-url="https://github.com/ChristophShyper/action-terraform-copy-vars" \
  org.label-schema.vendor="Krzysztof Szyper <biotyk@mail.com>" \
  org.label-schema.version="${VERSION}" \
  maintainer="Krzysztof Szyper <biotyk@mail.com>" \
  repository="https://github.com/ChristophShyper/action-terraform-copy-vars"

# Copy all needed files
COPY terraform-copy-variables.py entrypoint.sh /

RUN set -eux \
  && chmod +x /entrypoint.sh \
  && apk update --no-cache \
  && apk upgrade --no-cache \
  && apk add --no-cache bash \
  && apk add --no-cache git \
  && apk add --no-cache python3 \
  && if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi \
  && python3 -m ensurepip \
  && rm -r /usr/lib/python*/ensurepip \
  && pip3 install --no-cache --upgrade pip setuptools wheel \
  && if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi \
  && rm -rf /var/cache/* \
  && rm -rf /root/.cache/*

# Finish up
CMD python --version
WORKDIR /github/workspace
ENTRYPOINT /entrypoint.sh
