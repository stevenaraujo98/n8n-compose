FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Actualizar repositorios e instalar Java JDK y herramientas de compilación usando apt
RUN apt-get update && apt-get install -y \
    openjdk-17-jdk \
    python3 \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Configurar la variable de entorno para Java (Debian indexa OpenJDK aquí)
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:${PATH}"

USER node