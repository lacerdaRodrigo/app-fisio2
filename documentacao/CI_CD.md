# CI/CD — Integração e Entrega Contínua

> Guia da pipeline automatizada do Fisio Home Care no **GitHub Actions**.
> Escrito para ser seguido mesmo sem experiência prévia com DevOps.

---

## O que é e por que existe

Antes, publicar o app era manual (`make prod-web` no PC do desenvolvedor).
Agora o **GitHub** faz isso sozinho: a cada alteração enviada, ele roda os testes
e publica o site automaticamente. Isso evita erro humano, garante que nada quebrado
vá ao ar e mantém a versão sempre organizada.

---

## O fluxo de branches (GitFlow simplificado)

```
  feature/correção (branches auxiliares)
            │  (abre Pull Request)
            ▼
        develop ───────────►  Ambiente de TESTES (URL temporária de preview)
            │  (merge quando aprovado)
            ▼
         master ───────────►  PRODUÇÃO (site oficial app-fisio-care-2.web.app)
```

- **Branches auxiliares** (`feature/...`, `fix/...`): onde você desenvolve. Ao abrir
  PR, roda a verificação de qualidade (não publica nada).
- **`develop`**: ambiente de testes. Todo push aqui publica num **preview channel**
  do Firebase (endereço temporário, isolado da produção).
- **`master`**: produção. Todo push aqui **incrementa a versão**, publica o site
  oficial e registra o número da nova versão automaticamente.

> Não há bloqueio de merge — é responsabilidade do time seguir o fluxo.

---

## Os 3 workflows (`.github/workflows/`)

| Arquivo | Dispara quando | O que faz |
|---|---|---|
| `ci.yml` | PR para `develop`/`master` e push em branches auxiliares | `flutter analyze` + `flutter test --coverage` + build web. **Não publica.** |
| `deploy-preview.yml` | push em `develop` | Testa, builda e publica no **preview channel** (ambiente de testes). |
| `deploy-prod.yml` | push em `master` | Testa, **incrementa a versão**, builda, publica em **produção** e commita o bump (`[skip ci]`). |

Detalhes técnicos:
- **Flutter** fixado em `3.44.1` (`subosito/flutter-action@v2`).
- **Deploy** via `FirebaseExtended/action-hosting-deploy@v0`.
- Cópia das páginas públicas (`branding/*.html`) e bump de versão replicam o
  antigo `make prod-web`.

---

## Segredos (Secrets) necessários no GitHub

Em **Settings → Secrets and variables → Actions** (aba **Secrets**, não "Variables"):

| Secret | Conteúdo |
|---|---|
| `FIREBASE_SERVICE_ACCOUNT` | **JSON da conta de serviço** do Firebase (começa com `"type": "service_account"` e tem `"private_key"`). Gerado em: Firebase Console → ⚙️ Configurações do projeto → **Contas de serviço** → **Gerar nova chave privada**. |
| `GOOGLE_OAUTH_CLIENT_ID_WEB` | Client ID OAuth web (`...apps.googleusercontent.com`). |
| `GOOGLE_OAUTH_CLIENT_ID_ANDROID` | Client ID OAuth Android (pode ser `none` enquanto for só web). |

> ⚠️ **Não confundir** o JSON de conta de serviço com o arquivo de "OAuth Client"
> (esse tem `installed`/`web`, `client_secret`, `auth_uri`...). Só o de **conta de
> serviço** funciona para deploy. Usar o arquivo errado dá o erro
> *"Failed to authenticate, have you run firebase login?"*.

---

## Como usar no dia a dia

### Atalhos no Makefile

```bash
make ci-local      # roda lint + testes + build web ANTES de subir (igual à CI)
make release-dev   # mescla a branch atual na develop e publica o ambiente de testes
make release-prod  # mescla develop -> master e PUBLICA EM PRODUÇÃO (pede confirmação)
```

### Passo a passo típico

1. **Desenvolver** numa branch auxiliar:
   ```bash
   git checkout -b feature/minha-mudanca
   # ...código...
   make ci-local            # confere que está tudo verde localmente
   git add . && git commit -m "feat: minha mudança"
   git push origin feature/minha-mudanca
   ```
   → abre PR para `develop` no GitHub; a CI roda sozinha.

2. **Testar no ambiente de testes** (após aprovar/mesclar na develop):
   ```bash
   make release-dev
   ```
   → acompanhe em **Actions**; a URL de preview aparece na etapa
   *"🚀 Publicar no ambiente de testes"* (formato
   `https://app-fisio-care-2--develop-XXXX.web.app`).

3. **Publicar em produção** (quando aprovado nos testes):
   ```bash
   make release-prod        # pede confirmação (s/N)
   ```
   → publica em `https://app-fisio-care-2.web.app`, sobe a versão (ex.: 1.0.7 → 1.0.8)
   e registra o commit do bump.

### Acompanhar as execuções

👉 `https://github.com/lacerdaRodrigo/app-fisio2/actions`
- ✓ verde = sucesso · ✗ vermelho = falha (clique na execução → no job → na etapa
  vermelha para ver o erro).

---

## Solução de problemas (troubleshooting)

| Sintoma | Causa provável | Como resolver |
|---|---|---|
| `Failed to authenticate, have you run firebase login?` | `FIREBASE_SERVICE_ACCOUNT` vazio ou com arquivo errado (OAuth em vez de conta de serviço) | Gerar a chave correta (conta de serviço) e recolar no secret. |
| Etapa **🔐 Conferir credencial** falha | Secret vazio ou salvo na aba "Variables" | Recriar na aba **Secrets** com o nome exato. |
| `403 ... does not have permission` | Conta de serviço sem permissão de Hosting | Conceder o papel **Administrador do Firebase Hosting** à conta em GCP → IAM. |
| Testes falham na CI mas passam local | Versão de Flutter diferente | A CI usa `3.44.1`; alinhe localmente (`flutter --version`). |

---

## Relação com o `make prod-web` antigo

O target `make prod-web` (deploy local direto pelo PC) **continua existindo** como
alternativa de emergência, mas o **caminho recomendado agora é via Git/CI**
(`make release-prod`). Evite usar os dois para a mesma versão, pois ambos
incrementam o número de versão e podem se desencontrar.

---

**Última atualização:** 2026-06-17
