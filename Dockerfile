FROM ubuntu:questing-20251029

# Disable interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Copy all needed files
COPY terraform-copy-vars.py entrypoint.sh /

# Install needed packages
SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]
# hadolint ignore=DL3008
RUN chmod +x /entrypoint.sh ;\
  apt-get update -y ;\
  apt-get install --no-install-recommends -y \
    bash \
    git \
    python3 \
    python3-pip ;\
  apt-get clean ;\
  rm -rf /var/lib/apt/lists/*

# Finish up
CMD ["python", "--version"]
WORKDIR /github/workspace
ENTRYPOINT ["/entrypoint.sh"]
