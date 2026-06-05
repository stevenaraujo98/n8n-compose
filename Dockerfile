FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Instalar JDK (Debian-based)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-17-jre-headless \
        python3 \
        make \
        g++ && \
    rm -rf /var/lib/apt/lists/*

# Preinstalar el paquete con JDK disponible
RUN mkdir -p /home/node/.n8n/nodes && \
    cd /home/node/.n8n/nodes && \
    npm install @fimil/n8n-nodes-ibmi-db2 && \
    chown -R node:node /home/node/.n8n

USER node