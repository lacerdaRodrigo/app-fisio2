#!/bin/bash
# Script para rodar o app em desenvolvimento com as variáveis de ambiente

# Carregar .env se existir
if [ -f .env ]; then
    export $(cat .env | xargs)
fi

# Verificar se o CLIENT ID foi fornecido
if [ -z "$GOOGLE_OAUTH_CLIENT_ID_WEB" ]; then
    echo "❌ Erro: GOOGLE_OAUTH_CLIENT_ID_WEB não foi definido."
    echo ""
    echo "Configure de uma das formas:"
    echo ""
    echo "1. Criar arquivo .env:"
    echo "   cp .env.example .env"
    echo "   # Editar .env e adicionar seu Client ID"
    echo ""
    echo "2. Exportar variável de ambiente:"
    echo "   export GOOGLE_OAUTH_CLIENT_ID_WEB=seu_client_id"
    echo ""
    echo "3. Passar como argumento:"
    echo "   GOOGLE_OAUTH_CLIENT_ID_WEB=seu_client_id flutter run"
    echo ""
    exit 1
fi

echo "✅ GOOGLE_OAUTH_CLIENT_ID_WEB configurado"
echo "🚀 Iniciando app..."
echo ""

flutter run --dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=$GOOGLE_OAUTH_CLIENT_ID_WEB "$@"
