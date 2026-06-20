FROM node:24-alpine

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apk add --no-cache \
    openjdk17-jre-headless \
    openjdk17-jdk \
    make \
    g++ \
    bash \
    git \
    curl

RUN npm install -g n8n@2.26.8

RUN mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node/.n8n

COPY --chown=node:node entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER node
WORKDIR /home/node
EXPOSE 5678
ENTRYPOINT ["/entrypoint.sh"]