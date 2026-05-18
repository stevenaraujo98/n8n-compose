# Guía: Usar Certificado Wildcard con Traefik en n8n

## Resumen de Cambios

Tu proyecto n8n originalmente usaba **Let's Encrypt con TLS Challenge** (generación automática de certificados). Ahora lo hemos modificado para usar el **mismo certificado wildcard** (`*.espol.edu.ec`) que usa tu otro proyecto.

## Archivos Necesarios

### 1. `traefik-certs.yml`
Este archivo le dice a Traefik dónde encontrar tus certificados wildcard:
- Ubicación: En la raíz de tu proyecto (mismo nivel que `compose.prod.yaml`)
- Función: Configura los certificados estáticos

### 2. `compose.prod.yaml` (modificado)
Los cambios principales son:

**ANTES (Let's Encrypt automático):**
```yaml
command:
  - "--certificatesresolvers.mytlschallenge.acme.tlschallenge=true"
  - "--certificatesresolvers.mytlschallenge.acme.email=${SSL_EMAIL}"
  - "--certificatesresolvers.mytlschallenge.acme.storage=/letsencrypt/acme.json"
volumes:
  - traefik_data:/letsencrypt
```

**DESPUÉS (Certificado wildcard estático):**
```yaml
command:
  - "--providers.file.filename=/traefik-certs.yml"
  - "--providers.file.watch=true"
volumes:
  - ./certs:/certs:ro
  - ./traefik-certs.yml:/traefik-certs.yml:ro
```

## Estructura de Archivos Requerida

```
tu-proyecto/
├── compose.prod.yaml          # Archivo modificado
├── traefik-certs.yml          # NUEVO - Configuración de certificados
├── certs/                     # NUEVA carpeta (compartida con el otro proyecto)
│   ├── bundle.crt            # Certificado wildcard
│   └── star_espol_edu_ec.key # Llave privada del wildcard
├── local-files/
└── .env
```

## Pasos de Implementación

### 1. Copiar los Archivos Generados

Coloca estos archivos en la raíz de tu proyecto n8n:
- `compose.prod.yaml` (reemplaza el original)
- `traefik-certs.yml` (archivo nuevo)

### 2. Verificar la Carpeta de Certificados

Asegúrate de tener acceso a la carpeta `certs/` con los certificados wildcard:

**Opción A: Si ambos proyectos están en el mismo servidor**
```bash
# Desde la raíz de tu proyecto n8n, crea un enlace simbólico
ln -s /ruta/absoluta/al/otro/proyecto/certs ./certs
```

**Opción B: Si están en servidores diferentes**
```bash
# Copia los certificados a tu proyecto
mkdir -p certs
cp /ruta/al/otro/proyecto/certs/bundle.crt ./certs/
cp /ruta/al/otro/proyecto/certs/star_espol_edu_ec.key ./certs/
```

### 3. Verificar el Contenido de la Carpeta certs/

```bash
ls -la certs/
# Deberías ver:
# bundle.crt
# star_espol_edu_ec.key
```

### 4. Actualizar Variables de Entorno

En tu archivo `.env`, asegúrate de que `DOMAIN_NAME` sea `espol.edu.ec` (el dominio del wildcard):

```bash
SUBDOMAIN=n8n  # o el subdominio que uses
DOMAIN_NAME=espol.edu.ec
```

### 5. Detener el Stack Actual (si está corriendo)

```bash
docker compose -f compose.prod.yaml down
```

### 6. Limpiar Volumen de Let's Encrypt (ya no necesario)

```bash
docker volume rm n8n-prod_traefik_data
```

### 7. Iniciar el Nuevo Stack

```bash
docker compose -f compose.prod.yaml up -d
```

### 8. Verificar los Logs

```bash
# Ver logs de Traefik
docker logs traefik

# Deberías ver algo como:
# "Configuration loaded from file: /traefik-certs.yml"
# Y NO deberías ver errores de ACME/Let's Encrypt
```

## Diferencias Principales

| Aspecto | Antes (Let's Encrypt) | Después (Wildcard) |
|---------|----------------------|-------------------|
| **Generación de certificados** | Automática por Traefik | Manual (ya existen) |
| **Renovación** | Automática cada 90 días | Manual (compartes con otro proyecto) |
| **Dominio** | Específico por servicio | Wildcard `*.espol.edu.ec` |
| **Almacenamiento** | Volumen Docker | Carpeta local `./certs` |
| **Complejidad** | Más simple (auto-gestionado) | Requiere gestión manual |

## Ventajas del Certificado Wildcard

✅ **Un solo certificado** para todos los subdominios de `espol.edu.ec`
✅ **Consistencia** entre proyectos
✅ **No dependes** de Let's Encrypt Challenge (útil en redes restringidas)

## Consideraciones Importantes

⚠️ **Renovación de Certificados**: Cuando el certificado wildcard se renueve, deberás:
1. Actualizar los archivos en `./certs/`
2. Reiniciar Traefik: `docker restart traefik`

⚠️ **Seguridad de Llaves**: Asegúrate de que los archivos de certificados tengan permisos restrictivos:
```bash
chmod 644 certs/bundle.crt
chmod 600 certs/star_espol_edu_ec.key
```

⚠️ **Backup**: Mantén copias de seguridad de tus certificados en un lugar seguro.

## Troubleshooting

### Error: "no certificate found for domain"
- Verifica que los archivos existen en `./certs/`
- Revisa los logs: `docker logs traefik`
- Confirma que `traefik-certs.yml` esté montado correctamente

### Error: "permission denied"
- Ajusta permisos: `chmod 644 certs/*.crt && chmod 600 certs/*.key`

### Error: "certificate is not valid"
- Verifica que el certificado no haya expirado: `openssl x509 -in certs/bundle.crt -noout -dates`

## Comandos Útiles

```bash
# Verificar configuración de Traefik
docker exec traefik cat /traefik-certs.yml

# Ver certificados cargados
docker exec traefik ls -la /certs/

# Recargar configuración sin reiniciar (si watch está activo)
touch traefik-certs.yml

# Ver logs en tiempo real
docker logs -f traefik
```

## ¿Necesitas Volver a Let's Encrypt?

Si en algún momento quieres volver al sistema automático de Let's Encrypt, simplemente usa tu archivo `compose.prod.yaml` original.
