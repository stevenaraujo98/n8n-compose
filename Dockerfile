FROM node:24-alpine

# Variables de entorno de Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Instalar dependencias del sistema (incluyendo python3 para node-gyp)
RUN apk add --no-cache \
    openjdk17-jre-headless \
    openjdk17-jdk \
    python3 \
    make \
    g++ \
    bash \
    git \
    curl

# Instalar n8n globalmente
RUN npm install -g n8n

# Crear directorio base (el volumen lo sobreescribirá en runtime)
RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

# Copiar entrypoint
COPY --chown=node:node entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER node
WORKDIR /home/node

EXPOSE 5678

ENTRYPOINT ["/entrypoint.sh"]