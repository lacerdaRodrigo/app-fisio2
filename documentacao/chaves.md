# Firebase Hosting
FIREBASE_PROJECT_ID=app-fisio-care-2
FIREBASE_HOSTING_URL=https://app-fisio-care-2.web.app
FIREBASE_HOSTING_PUBLIC_DIR=build/web

# Google OAuth / Google Sign-In Web
GOOGLE_OAUTH_CLIENT_ID_WEB=1034972209864-22ivlkbu9eu206fv6tvot90mup62stic.apps.googleusercontent.com
GOOGLE_OAUTH_CLIENT_ID_ANDROID=1034972209864-n2m95cpaoundfk1r006fcjr3to5vg7o9.apps.googleusercontent.com
GOOGLE_CLOUD_PROJECT_NUMBER=1034972209864
GOOGLE_AUTHORIZED_JAVASCRIPT_ORIGIN=https://app-fisio-care-2.web.app
GOOGLE_AUTHORIZED_JAVASCRIPT_ORIGIN_LOCAL=http://localhost:5000
GOOGLE_AUTHORIZED_REDIRECT_URI=https://app-fisio-care-2.web.app/__/auth/handler

# Escopos e APIs usadas pelo app
GOOGLE_DRIVE_SCOPE=https://www.googleapis.com/auth/drive.file
GOOGLE_SIGNIN_EXTRA_SCOPE=email
GOOGLE_DRIVE_API_VERSION=v3
GOOGLE_SHEETS_API_VERSION=v4

# Banco BYODB criado na conta Google do usuario
GOOGLE_SHEETS_DATABASE_FILE_NAME=__saas_fisio_db__
GOOGLE_SHEETS_TABS=Pacientes,Evolucoes,Agenda,Configuracoes,Auditoria

# Conta usada nos testes Maestro existentes
TEST_GOOGLE_EMAIL=lacerdaa.rodrigo@gmail.com

# Android — SHA-1 debug (registrar no Firebase Console → app com.rodrigo.fisio_care)
ANDROID_DEBUG_SHA1=EA:41:8E:63:75:54:26:F1:97:91:6D:5D:04:7F:18:4B:C5:44:F1:F6

## Login Android — erro 12500 ou 10

Se o login falhar no celular, o `google-services.json` provavelmente está incompleto.
Valide com: `make check-android-oauth`

O JSON correto deve conter `"client_type": 1` com `android_info` (além do `client_type: 3` Web).

### Passos para corrigir (projeto app-fisio-care-2)

1. **Firebase → Authentication → Sign-in method → Google → Ativar**
2. **Google Cloud Console → Credentials → Criar credencial → OAuth client ID → Android**
   - Package: `com.rodrigo.fisio_care`
   - SHA-1: valor de `ANDROID_DEBUG_SHA1` acima
3. **OAuth consent screen → Usuários de teste**
   - Adicionar o e-mail Google usado no login (ex.: `lacerdaa.rodrigo@gmail.com`)
4. **Firebase → Configurações → app Android → baixar novo `google-services.json`**
   - Substituir em `android/app/google-services.json`
5. Confirmar: `make check-android-oauth` deve retornar OK
6. Rodar: `make dev-android`