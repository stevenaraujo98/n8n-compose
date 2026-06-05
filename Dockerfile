FROM node:20-alpine

# Instalar dependencias del sistema
RUN apk add --no-cache openjdk17-jre-headless python3 make g++

# Instalar n8n globalmente
RUN npm install -g n8n

# Preinstalar el paquete problemático
RUN mkdir -p /home/node/.n8n/nodes && \
    cd /home/node/.n8n/nodes && \
    npm install @fimil/n8n-nodes-ibmi-db2 && \
    chown -R node:node /home/node/.n8n

USER node

EXPOSE 5678

CMD ["n8n", "start"]