# N8N espol

Con docker compose  
Para correr y detener
```bash
sudo docker compose up -d
sudo docker compose -f compose.dev.yaml up -d
sudo docker compose -f compose.test.yaml up -d


sudo docker logs -f n8ncon
sudo docker logs -f ngrok

sudo docker compose -f compose.dev.yaml logs -f 
sudo docker compose -f compose.dev.yaml logs -f n8n
sudo docker compose -f compose.dev.yaml logs -f ngrok

sudo docker compose -f compose.test.yaml logs -f 
sudo docker compose -f compose.test.yaml logs -f n8n
sudo docker compose -f compose.test.yaml logs -f ngrok


sudo docker compose stop
sudo docker compose -f compose.dev.yaml down
sudo docker compose -f compose.dev.yaml down -v --rmi all
sudo docker compose -f compose.test.yaml stop
sudo docker compose -f compose.test.yaml down

sudo docker exec -it ds_postgres psql -U postgres -d saacdata -c "DELETE FROM n8n.credentials_entity;"

```

Con Ngrok
```bash
ngrok http --url=URL_NGROK.ngrok-free.dev 5678
```