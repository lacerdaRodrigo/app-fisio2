#!/bin/bash
set -e
echo "=== Build Flutter Web ==="
flutter build web
echo "=== Copiar páginas de branding ==="
cp -r branding/* build/web/
echo "=== Deploy Firebase ==="
firebase deploy
echo "=== Pronto! ==="
