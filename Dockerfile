FROM node:22-alpine

ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk
ENV PATH=$JAVA_HOME/bin:$PATH
ENV NODE_PATH=/usr/local/lib/custom-nodes/node_modules

RUN apk add --no-cache openjdk17-jre-headless openjdk17-jdk python3 make g++ bash

RUN npm install -g n8n

RUN mkdir -p /usr/local/lib/custom-nodes && \
    cd /usr/local/lib/custom-nodes && \
    npm install @fimil/n8n-nodes-ibmi-db2

USER node

EXPOSE 5678

CMD ["n8n", "start"]