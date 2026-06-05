FROM docker.n8n.io/n8nio/n8n:latest

USER root

# Instalar Java JDK y herramientas de compilación necesarias para node-java
RUN apk add --no-cache openjdk11 python3 make g++

# Configurar las variables de entorno para que Node encuentre Java
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk
ENV PATH="$JAVA_HOME/bin:${PATH}"

USER node