FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Instalar JDK (necesario para node-jt400 → java bridge)
RUN apk add --no-cache openjdk17-jre-headless python3 make g++

# Preinstalar el paquete problemático con acceso a JDK
RUN cd /home/node && \
    mkdir -p .n8n/nodes && \
    cd .n8n/nodes && \
    npm install @fimil/n8n-nodes-ibmi-db2

USER node