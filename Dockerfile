FROM node:20-bookworm-slim

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=${JAVA_HOME}/bin:${PATH}

RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    python3 \
    make \
    g++ \
    git \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Importante: usar versión fija, no latest
# Importante: NO compilar todas las dependencias nativas de n8n
RUN npm install -g n8n@2.23.4

# Preinstalar SOLO n8n-nodes-ibmi-db2, sin @fimil
# Aquí sí forzamos build-from-source para el módulo java/node-jt400
RUN mkdir -p /opt/custom-nodes && \
    cd /opt/custom-nodes && \
    npm init -y && \
    npm install n8n-nodes-ibmi-db2@1.0.3 --unsafe-perm --build-from-source

# Validar que el módulo java generó jvm_dll_path.json
RUN find /opt/custom-nodes -type f | grep -E "jvm_dll_path.json|IbmiDb2.node.js|\.node$" || true

RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node /opt/custom-nodes

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown node:node /entrypoint.sh

USER node
WORKDIR /home/node

EXPOSE 5678

ENTRYPOINT ["/entrypoint.sh"]