# N8N espol
Infraestructura de n8n con docker y docker compose.  

### Linux
Revision IP y puertos
```bash
nc -zv 192.168.253.6 7087
telnet 192.168.253.6 7087

curl -I http://192.168.10.37/docs 
curl -v http://192.168.10.37/docs 
curl -X GET "URL"
curl -X GET "URL"
```

Permisos Change User
```bash
sudo chown -R manager:manager /var/n8n-compose/
```

### Con docker
Primer asegurar las variables de entorno o modificar manualmente:
```bash
export POSTGRES_USER=
export POSTGRES_PASSWORD=
export DNS_1=
export DNS_2=
export DOMAIN=
```

Segundo compenzar a crear volumen y contenedores:
```bash
sudo docker volume create n8n_data

# CREATE SCHEMA IF NOT EXISTS "N8N";
#  En segundo plano
sudo docker run -d \
 --name n8n \
 --dns $DNS_1 --dns $DNS_2 \
 --restart unless-stopped \
 --network datalakehouseonpremise_ds_network \
 -p 5678:5678 \
 -e GENERIC_TIMEZONE="America/Guayaquil" \
 -e TZ="America/Guayaquil" \
 -e N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true \
 -e N8N_SECURE_COOKIE=false \
 -e WEBHOOK_URL=$DOMAIN \
 -e DB_TYPE=postgresdb \
 -e DB_POSTGRESDB_DATABASE=saacdata \
 -e DB_POSTGRESDB_HOST=ds_postgres \
 -e DB_POSTGRESDB_PORT=5432 \
 -e DB_POSTGRESDB_USER=$POSTGRES_USER \
 -e DB_POSTGRESDB_SCHEMA=n8n \
 -e DB_POSTGRESDB_PASSWORD=$POSTGRES_PASSWORD \
 -v n8n_data:/home/node/.n8n \
 docker.n8n.io/n8nio/n8n

sudo docker logs -f n8n
sudo docker start n8n
sudo docker stop n8n
sudo docker rm -f n8n
sudo docker volume rm n8n_data
# Borrar el esquema n8n

sudo docker ps
```


### Con docker compose  
Con docker compose  

#### Linux
```bash
sudo chown -R mania:mania /var/n8n-compose
sudo chmod 755 /var/n8n-compose
```

**Para correr y detener**
```bash
sudo docker compose up -d
sudo docker compose -f compose.dev.yaml up -d
sudo docker compose -f compose.test.yaml up -d
docker compose -f compose.local.yaml up -d
# Para prod
sudo docker compose -f compose.prod.yaml build
sudo docker compose -f compose.prod.yaml up -d
sudo docker compose -f compose.prod.yaml up -d --build

sudo docker logs -f n8ncon
sudo docker logs -f ngrok

sudo docker compose -f compose.dev.yaml logs -f 
sudo docker compose -f compose.dev.yaml logs -f n8n
sudo docker compose -f compose.dev.yaml logs -f ngrok

sudo docker compose -f compose.test.yaml logs -f 
sudo docker compose -f compose.test.yaml logs -f n8n
sudo docker compose -f compose.test.yaml logs -f ngrok

docker compose -f compose.local.yaml logs -f 
docker compose -f compose.local.yaml logs -f n8n
docker compose -f compose.local.yaml logs -f ngrok
docker compose -f compose.local.yaml logs -f ds_postgres

sudo docker compose -f compose.prod.yaml logs -f 
sudo docker compose -f compose.prod.yaml logs -f n8n
sudo docker compose -f compose.prod.yaml logs -f traefik


sudo docker compose stop
# down ese comando elimina los contenedores.
# -v también borra los volúmenes (postgres + n8n data)
sudo docker compose -f compose.dev.yaml down
sudo docker compose -f compose.dev.yaml down -v --rmi all
sudo docker compose -f compose.test.yaml stop
sudo docker compose -f compose.test.yaml down -v --rmi all
docker compose -f compose.local.yaml stop
docker compose -f compose.local.yaml down -v --rmi all

sudo docker compose -f compose.prod.yaml stop
sudo docker compose -f compose.prod.yaml down
sudo docker compose -f compose.prod.yaml down -v --rmi all


docker compose -f compose.local.yaml start
sudo docker exec -it ds_postgres psql -U postgres -d saacdata -c "DELETE FROM n8n.credentials_entity;"
```

**Actualizacion de imagen**
```bash
sudo git pull

sudo docker compose -f compose.prod.yaml pull

sudo docker compose -f compose.prod.yaml up -d

# https://endoflife.date/traefik
sudo docker exec -it traefik traefik version
```

#### Compose.dev
 ```bash
services:
  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8n
    dns:
      - 8.8.8.8
      - 8.8.4.4
    restart: always
    ports:
      - "5678:5678"
    environment:
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_PORT=5678
      - N8N_PROTOCOL=http
      - NODE_ENV=develop
      - N8N_SECURE_COOKIE=false  # Obligatorio para entrar sin HTTPS
      - WEBHOOK_URL=http://${IP_LOCAL}:5678/ 
      - GENERIC_TIMEZONE=America/Guayaquil
      - TZ=America/Guayaquil
      # Base de Datos
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=saacdata
      - DB_POSTGRESDB_HOST=ds_postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_POSTGRESDB_SCHEMA=n8n
    volumes:
      - n8n_data:/home/node/.n8n
      - ./local-files:/files
    networks:
      - ds_network

networks:
  ds_network:
    external: true
    name: datalakehouseonpremise_ds_network

volumes:
  n8n_data:
```

#### Compose.test
Con [Ngrok](https://dashboard.ngrok.com/get-started/setup/linux)  
Ejemplo de ejecución local:
```bash
ngrok http --url=URL_NGROK.ngrok-free.dev 5678
```

Archivo YAML
```bash
name: n8n-test

services:
  ngrok:
    image: ngrok/ngrok:latest
    container_name: ngrok
    restart: unless-stopped
    environment:
      - NGROK_AUTHTOKEN=${NGROK_AUTHTOKEN}
    command: http --url=${SUBDOMAIN}.${DOMAIN_NAME} --log stdout http://n8n:5678
    depends_on:
      - n8n
    networks:
      - ds_network

  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8ncon
    hostname: n8n-saac
    restart: always
    ports:
      - "${IP_LOCAL}:5678:5678"
    environment:
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - N8N_HOST=${SUBDOMAIN}.${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - N8N_SECURE_COOKIE=false
      - WEBHOOK_URL=https://${SUBDOMAIN}.${DOMAIN_NAME}/
      - GENERIC_TIMEZONE=America/Guayaquil
      - TZ=America/Guayaquil
      - N8N_DIAGNOSTICS_ENABLED=false
      - N8N_VERSION_NOTIFICATIONS_ENABLED=false
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=saacdata
      - DB_POSTGRESDB_HOST=ds_postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_POSTGRESDB_SCHEMA=n8n
    volumes:
      - n8n_data_test:/home/node/.n8n
      - ./local-files:/files
    networks:
      - ds_network

networks:
  ds_network:
    external: true
    name: datalakehouseonpremise_ds_network

volumes:
  n8n_data_test:
```

#### Compose.prod
```bash
name: n8n-prod

services:
  traefik:
    image: "traefik"
    container_name: traefik
    restart: always
    command:
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      - "--entrypoints.web.http.redirections.entrypoint.scheme=https"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.mytlschallenge.acme.tlschallenge=true"
      - "--certificatesresolvers.mytlschallenge.acme.email=${SSL_EMAIL}"
      - "--certificatesresolvers.mytlschallenge.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    dns:
      - 8.8.8.8
      - 8.8.4.4
    volumes:
      - traefik_data:/letsencrypt
      - /var/run/docker.sock:/var/run/docker.sock:ro
    networks:
      - ds_network

  n8n:
    image: docker.n8n.io/n8nio/n8n
    container_name: n8n
    dns:
      - 8.8.8.8
      - 8.8.4.4
    restart: always
    # En producción, no es necesario mapear el puerto a la máquina host, ya que Traefik se encargará de enrutar el tráfico al contenedor n8n
    expose:
      - "5678"
    labels:
      - traefik.enable=true
      - traefik.http.routers.n8n.rule=Host(`${SUBDOMAIN}.${DOMAIN_NAME}`)
      - traefik.http.routers.n8n.tls=true
      - traefik.http.routers.n8n.entrypoints=web,websecure
      - traefik.http.routers.n8n.tls.certresolver=mytlschallenge
      - traefik.http.middlewares.n8n.headers.SSLRedirect=true
      - traefik.http.middlewares.n8n.headers.STSSeconds=315360000
      - traefik.http.middlewares.n8n.headers.browserXSSFilter=true
      - traefik.http.middlewares.n8n.headers.contentTypeNosniff=true
      - traefik.http.middlewares.n8n.headers.forceSTSHeader=true
      - traefik.http.middlewares.n8n.headers.SSLHost=${DOMAIN_NAME}
      - traefik.http.middlewares.n8n.headers.STSIncludeSubdomains=true
      - traefik.http.middlewares.n8n.headers.STSPreload=true
      - traefik.http.routers.n8n.middlewares=n8n@docker
    environment:
      - N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true
      - N8N_ENCRYPTION_KEY=${N8N_ENCRYPTION_KEY}
      - N8N_HOST=${SUBDOMAIN}.${DOMAIN_NAME}
      - N8N_PORT=5678
      - N8N_PROTOCOL=https
      - NODE_ENV=production
      - N8N_SECURE_COOKIE=true
      - N8N_DIAGNOSTICS_ENABLED=false
      - N8N_VERSION_NOTIFICATIONS_ENABLED=false
      - WEBHOOK_URL=https://${SUBDOMAIN}.${DOMAIN_NAME}/      
      - GENERIC_TIMEZONE=America/Guayaquil
      - TZ=America/Guayaquil
      - DB_TYPE=postgresdb
      - DB_POSTGRESDB_DATABASE=saacdata
      - DB_POSTGRESDB_HOST=ds_postgres
      - DB_POSTGRESDB_PORT=5432
      - DB_POSTGRESDB_USER=${POSTGRES_USER}
      - DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}
      - DB_POSTGRESDB_SCHEMA=n8n
    volumes:
      - n8n_data:/home/node/.n8n
      - ./local-files:/files
    networks:
      - ds_network

networks:
  ds_network:
    external: true
    name: datalakehouseonpremise_ds_network

volumes:
  n8n_data:
  traefik_data:
```
