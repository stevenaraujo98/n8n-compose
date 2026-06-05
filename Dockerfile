# Usamos una imagen de Node limpia basada en Debian Slim
FROM node:18-slim

USER root

# Instalar Java, Python y herramientas de compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    openjdk-17-jdk \
    python3 \
    build-essential \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar n8n globalmente en la versión que desees (o 'latest')
RUN npm install -g n8n@latest

# Configurar variables de entorno para Java
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

# n8n corre por defecto en el puerto 5678
EXPOSE 5678

# Crear el usuario node (ya viene en la imagen base) y el directorio de trabajo
WORKDIR /home/node

# Comando para iniciar n8n tal como lo hace la imagen oficial
CMD ["n8n", "start"]