#!/bin/sh
set -e

NODES_DIR=/home/node/.n8n/nodes

mkdir -p "$NODES_DIR"

echo ">>> Limpiando paquete @fimil si existe..."
rm -rf "$NODES_DIR/node_modules/@fimil"

echo ">>> Preparando community nodes..."

if [ ! -d "$NODES_DIR/node_modules/n8n-nodes-ibmi-db2" ]; then
  echo ">>> Copiando n8n-nodes-ibmi-db2 preinstalado..."
  cp -R /opt/custom-nodes/node_modules "$NODES_DIR/"
else
  echo ">>> n8n-nodes-ibmi-db2 ya existe en el volumen."
fi

echo ">>> Corrigiendo package.json del volumen..."
node -e "
  const fs = require('fs');
  const p = '$NODES_DIR/package.json';
  let pkg = {};
  try {
    pkg = JSON.parse(fs.readFileSync(p));
  } catch(e) {}

  pkg.name = pkg.name || 'installed-nodes';
  pkg.private = true;
  pkg.dependencies = {
    'n8n-nodes-ibmi-db2': '1.0.3'
  };

  fs.writeFileSync(p, JSON.stringify(pkg, null, 2));
  console.log('Dependencias:', JSON.stringify(pkg.dependencies));
"

echo ">>> Verificando archivos nativos..."
find "$NODES_DIR" -type f | grep -E "jvm_dll_path.json|IbmiDb2.node.js|\.node$" || true

exec n8n start