FROM node:20-bookworm-slim

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}
ENV npm_config_build_from_source=true

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    python3 \
    make \
    g++ \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN npm install -g n8n@latest

# Preinstalar community nodes fuera del volumen persistente
RUN mkdir -p /opt/custom-nodes && \
    cd /opt/custom-nodes && \
    npm init -y && \
    npm install @fimil/n8n-nodes-ibmi-db2 --unsafe-perm --build-from-source

# Verificación opcional de instalación
RUN find /opt/custom-nodes -type f | grep -E "jvm_dll_path.json|\.node$" || true

RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown node:node /entrypoint.sh

USER node
WORKDIR /home/node

EXPOSE 5678

ENTRYPOINT ["/entrypoint.sh"]