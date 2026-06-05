#!/bin/sh
set -e

NODES_DIR=/home/node/.n8n/nodes

mkdir -p "$NODES_DIR"

# Copiar los community nodes preinstalados al volumen si aún no existen
if [ ! -d "$NODES_DIR/node_modules/@fimil" ]; then
  echo ">>> Copiando community nodes preinstalados..."
  cp -R /opt/custom-nodes/node_modules "$NODES_DIR/"
  cp /opt/custom-nodes/package.json "$NODES_DIR/" || true
fi

echo ">>> Verificando package instalado..."
find "$NODES_DIR" -type f | grep -E "jvm_dll_path.json|IbmiDb2.node.js" || true

exec n8n start