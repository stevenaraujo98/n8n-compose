#!/bin/sh
set -e

NODES_DIR=/home/node/.n8n/nodes

mkdir -p "$NODES_DIR"

# Limpiar @fimil si quedó del pasado
rm -rf "$NODES_DIR/node_modules/@fimil"

# Copiar nodes preinstalados si no existen
if [ ! -d "$NODES_DIR/node_modules/n8n-nodes-ibmi-db2" ]; then
  echo ">>> Copiando community nodes preinstalados..."
  cp -R /opt/custom-nodes/node_modules "$NODES_DIR/"
fi

# Actualizar package.json del volumen con solo n8n-nodes-ibmi-db2
node -e "
  const fs = require('fs');
  const p = '$NODES_DIR/package.json';
  let pkg = {};
  try { pkg = JSON.parse(fs.readFileSync(p)); } catch(e) {}
  pkg.name = pkg.name || 'installed-nodes';
  pkg.private = true;
  pkg.dependencies = { 'n8n-nodes-ibmi-db2': '1.0.3' };
  fs.writeFileSync(p, JSON.stringify(pkg, null, 2));
  console.log('package.json actualizado:', JSON.stringify(pkg.dependencies));
"

echo ">>> Verificando archivos nativos..."
find "$NODES_DIR" -type f | grep -E "jvm_dll_path.json|IbmiDb2.node.js" || true

exec n8n start