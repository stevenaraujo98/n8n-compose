FROM n8nio/n8n:latest

USER root

RUN apk add --no-cache openjdk17-jre-headless python3 make g++

RUN mkdir -p /home/node/.n8n/nodes && \
    cd /home/node/.n8n/nodes && \
    npm install @fimil/n8n-nodes-ibmi-db2 && \
    chown -R node:node /home/node/.n8n

USER node