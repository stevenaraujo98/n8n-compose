FROM node:22-alpine

# Configurar variables de entorno de Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Instalar todas las dependencias necesarias
RUN apk add --no-cache \
    openjdk17-jre-headless \
    openjdk17-jdk \
    python3 \
    make \
    g++ \
    bash \
    git

# Instalar n8n globalmente
RUN npm install -g n8n

# Crear el directorio de nodos comunitarios donde n8n los espera
# Esto debe hacerse ANTES de cambiar al usuario node
RUN mkdir -p /home/node/.n8n/nodes && \
    chown -R node:node /home/node/.n8n

# Cambiar al usuario node para instalar el paquete
USER node

# Instalar el paquete de IBM DB2 en el directorio correcto
WORKDIR /home/node/.n8n/nodes
RUN npm init -y && \
    npm install @fimil/n8n-nodes-ibmi-db2 && \
    cd node_modules/@fimil/n8n-nodes-ibmi-db2 && \
    npm rebuild

# Volver al directorio de trabajo por defecto
WORKDIR /home/node

EXPOSE 5678

CMD ["n8n", "start"]
