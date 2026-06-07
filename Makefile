-include .env
export

FIREBASE_PROJECT_ID ?= app-fisio-care-2
GOOGLE_OAUTH_CLIENT_ID_WEB ?= 1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_ID_ANDROID ?=

.DEFAULT_GOAL := help

.PHONY: help dev dev-android dev-web prod-web prod-android

help: ## Lista os comandos disponíveis
	@echo "Comandos disponíveis:"
	@awk 'BEGIN {FS = ":.*## "}; /^[a-zA-Z0-9_-]+:.*## / {printf "  make %-14s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

dev: dev-android ## Alias compatível para rodar no device Android

dev-android: ## Roda local no celular/device Android conectado
	flutter pub get
	flutter run \
		--dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=$(GOOGLE_OAUTH_CLIENT_ID_WEB) \
		--dart-define=GOOGLE_OAUTH_CLIENT_ID_ANDROID=$(GOOGLE_OAUTH_CLIENT_ID_ANDROID)

dev-web: ## Roda local no Chrome em http://localhost:5000
	flutter pub get
	flutter run -d chrome --web-hostname localhost --web-port 5000 \
		--dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=$(GOOGLE_OAUTH_CLIENT_ID_WEB)

prod-web: ## Compila e publica a Web em produção no Firebase Hosting
	flutter pub get
	flutter build web --release \
		--base-href=/app/ \
		--dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=$(GOOGLE_OAUTH_CLIENT_ID_WEB) \
		--dart-define=GOOGLE_OAUTH_CLIENT_ID_ANDROID=$(GOOGLE_OAUTH_CLIENT_ID_ANDROID)
	rm -rf build/web_root
	mkdir -p build/web_root/app
	cp -r build/web/. build/web_root/app/
	cp branding/sobre.html build/web_root/index.html
	cp branding/privacidade.html build/web_root/privacidade.html
	cp branding/termos.html build/web_root/termos.html
	cp branding/google505e804a9d870920.html build/web_root/google505e804a9d870920.html
	rm -rf build/web
	mv build/web_root build/web
	firebase deploy --only hosting --project $(FIREBASE_PROJECT_ID)

prod-android: ## Gera APK Android release para preparar publicação na loja
	flutter pub get
	flutter build apk --release \
		--dart-define=GOOGLE_OAUTH_CLIENT_ID_WEB=$(GOOGLE_OAUTH_CLIENT_ID_WEB) \
		--dart-define=GOOGLE_OAUTH_CLIENT_ID_ANDROID=$(GOOGLE_OAUTH_CLIENT_ID_ANDROID)
