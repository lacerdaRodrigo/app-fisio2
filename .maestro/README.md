# Maestro — testes E2E mobile

Flows YAML para automação no Android/iOS via [Maestro](https://maestro.mobile.dev).

## Pré-requisitos

- Maestro CLI instalado (`~/.maestro/bin/maestro`)
- Device Android conectado ou emulador rodando
- App instalado: `make dev-android` (ou APK debug)

## Rodar um flow

```bash
maestro test .maestro/flows/smoke_app_abre.yaml
```

## MCP no Cursor

Config em `.cursor/mcp.json` ([mobile-mcp](https://github.com/mobile-next/mobile-mcp)). Após alterar, reinicie o Cursor ou em **Settings → Tools & MCP** desligue/ligue o servidor **mobile-mcp**.

Ferramentas disponíveis: `mobile_list_available_devices`, `mobile_launch_app`, `mobile_list_elements_on_screen`, `mobile_take_screenshot`, etc.
