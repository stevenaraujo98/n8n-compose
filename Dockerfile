FROM node:20-alpine

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

RUN apk add --no-cache openjdk17-jre-headless openjdk17-jdk python3 make g++ bash

RUN npm install -g n8n

RUN mkdir -p /home/node/.n8n/nodes && \
    cd /home/node/.n8n/nodes && \
    npm install @fimil/n8n-nodes-ibmi-db2 && \
    chown -R node:node /home/node/.n8n

USER node

EXPOSE 5678

CMD ["n8n", "start"]