# Plano de Desenvolvimento: Sistema de Fisioterapia Domiciliar

## 1. Objetivo Principal
Desenvolver um aplicativo Flutter para gerenciar agendamentos e evoluções de pacientes de fisioterapia domiciliar, utilizando Google Sheets como backend e Google Sign-In para autenticação.

## 2. Arquitetura e Tecnologias
*   **Frontend: Flutter**
    *   **Justificativa:** Permite o desenvolvimento para Android e Web com uma única base de código, garantindo uma UI consistente e performática.
*   **Gerenciamento de Estado: Riverpod**
    *   **Justificativa:** Escolhido por sua segurança em tempo de compilação, facilidade de teste e abordagem baseada em provedores (Providers) que simplifica a injeção de dependências, sendo mais moderno que o Provider original.
*   **Backend/Dados: Google Sheets API**
    *   **Justificativa:** Atende ao requisito de usar planilhas do Google. A comunicação será feita via requisições HTTP REST, autorizadas com tokens OAuth 2.0 obtidos pelo Google Sign-In.
*   **Autenticação: Google Sign-In**
    *   **Justificativa:** Padrão seguro para permitir que o terapeuta acesse sua própria planilha. O token de acesso obtido será usado para autorizar todas as chamadas à API do Google Sheets.
*   **Deploy Web: Firebase Hosting**
    *   **Justificativa:** Hospeda a aplicação Web em `https://app-fisioterapia-rodrigo.web.app`, mantendo o Firebase apenas como camada de distribuição do frontend.

## 3. Pré-requisitos (Ação do Usuário)
1.  Configurar credenciais OAuth 2.0 no Google Cloud Console (Habilitar Google Sheets API e configurar credenciais para Android/iOS/Web).

## 4. Status Atual
1.  Autenticação Google Sign-In implementada.
2.  Integração real com Google Drive/Sheets implementada para localizar/criar a planilha `__saas_fisio_db__`.
3.  Fluxos principais persistem no Google Sheets: pacientes, agenda, evoluções, configurações e auditoria.
4.  Deploy Web configurado e publicado no Firebase Hosting.

## 5. Próximos Passos de Desenvolvimento
1.  Melhorar tratamento de erros de OAuth/Google APIs, incluindo token expirado e permissões recusadas.
2.  Implementar visualização/restauração de pacientes arquivados.
3.  Evoluir a agenda para visão semanal/mensal.
4.  Criar testes automatizados de UI para login, cadastro, agendamento, evolução e integração com Google Sheets.

---
*A estrutura detalhada dos dados está documentada no arquivo `MODELO_DADOS.md`.
*A especificação da tela de Pacientes está em `documentacao/PACIENTES_SPEC.md`.*