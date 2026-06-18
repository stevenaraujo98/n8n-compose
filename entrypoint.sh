#!/bin/sh
set -e

# NODES_DIR=/home/node/.n8n/nodes
# PACKAGE="@fimil/n8n-nodes-ibmi-db2"

# # Si el paquete no está compilado correctamente, reinstalarlo
# if [ ! -f "$NODES_DIR/node_modules/@fimil/n8n-nodes-ibmi-db2/node_modules/node-jt400/node_modules/java/build/jvm_dll_path.json" ]; then
#   echo ">>> Instalando/recompilando $PACKAGE..."
#   mkdir -p "$NODES_DIR"
#   cd "$NODES_DIR"
  
#   # Inicializar package.json si no existe
#   if [ ! -f package.json ]; then
#     npm init -y
#   fi

#   rm -rf "$NODES_DIR/node_modules/$PACKAGE"
  
#   # Instalar con compilación nativa
#   npm install "$PACKAGE" --build-from-source
  
#   echo ">>> Instalación completada"
# fi

if [ "$#" -eq 0 ]; then
	exec n8n start
fi

exec n8n "$@"