# Segurança, Privacidade e Arquitetura de Dados

Este documento descreve as diretrizes de segurança da informação, a arquitetura técnica de integração com o Google Sheets e as políticas de conformidade com a Lei Geral de Proteção de Dados (LGPD - Lei nº 13.709/2018) adotadas no aplicativo de Fisioterapia Domiciliar.

---

## 1. Arquitetura de Dados (Modelo Soberano)

Para garantir máxima privacidade e conformidade com a LGPD, o aplicativo adota um modelo de **Banco de Dados Soberano**. 

* **Sem Servidor Central:** O aplicativo **não** envia dados clínicos dos pacientes para servidores de terceiros ou bancos de dados centralizados pertencentes ao desenvolvedor da ferramenta.
* **Propriedade do Profissional:** Toda a estrutura de dados (planilhas) é criada e armazenada diretamente na conta pessoal do **Google Drive do fisioterapeuta**.
* **Isolamento de Contas:** Cada fisioterapeuta possui sua própria planilha. É impossível que um profissional acesse ou visualize a base de pacientes de outro através do aplicativo.

```
+------------------+                   +--------------------------+
|  Dispositivo do  |   OAuth 2.0 API   |   Google Cloud Server    |
|  Fisioterapeuta  | =================>| (Planilha Pessoal do App |
| (App Flutter)    |   (HTTPS TLS)     | no Drive do Profissional)|
+------------------+                   +--------------------------+
```

---

## 2. Autenticação e Autorização (OAuth 2.0)

O acesso à planilha do Google Sheets é regido por padrões de segurança do setor:

* **Google Sign-In:** A autenticação é delegada inteiramente ao Google. O aplicativo nunca tem acesso à senha do usuário.
* **Escopo Restrito (`drive.file`):** Ao solicitar acesso ao Google Drive, o aplicativo exige o escopo limitado `https://www.googleapis.com/auth/drive.file`.
  * *O que isso significa:* O app só pode ler e escrever em arquivos que ele mesmo criou (a planilha `__saas_fisio_db__`). O aplicativo **não** tem permissão para visualizar outros arquivos pessoais, fotos ou pastas do Drive do usuário.
* **Tokens de Acesso:** Na versão atual, os tokens são obtidos pelo fluxo Google Sign-In e usados para chamadas HTTPS à API. O app não implementa armazenamento persistente próprio de token de atualização.

---

## 3. Segurança Física dos Dados no Dispositivo

Na versão atual, o aplicativo depende de conectividade para carregar e persistir dados no Google Sheets:

* **Cache de Tela:** O Riverpod mantém dados em memória apenas durante a sessão para atualizar a interface.
* **Sem Modo Offline Persistente:** Ainda não há banco local criptografado, fila de sincronização offline ou reconciliação automática.
* **Logout:** Ao sair, a sessão Google é encerrada e o estado em memória é descartado.

---

## 4. Conformidade com a LGPD (Lei Geral de Proteção de Dados)

O aplicativo foi projetado desde a base sob os conceitos de *Privacy by Design* e *Privacy by Default*:

### A. Papéis na LGPD
* **Controlador dos Dados:** O fisioterapeuta (usuário do aplicativo). Ele decide quais dados coletar, por quanto tempo reter e como tratar.
* **Operador dos Dados:** O Google (provedor de infraestrutura da planilha) e o aplicativo (que apenas processa as requisições solicitadas pelo controlador).

### B. Atendimento aos Direitos do Titular (Paciente)
A escolha do Google Sheets como backend facilita o cumprimento imediato dos direitos dos pacientes:
* **Direito de Acesso e Retificação:** O paciente pode solicitar a correção de dados incorretos. O profissional pode corrigir no aplicativo ou diretamente na própria planilha.
* **Direito ao Esquecimento (Eliminação):** Se o paciente solicitar a exclusão de seu prontuário, o fisioterapeuta pode apagá-lo diretamente pelo aplicativo ou deletar a linha correspondente de forma definitiva na planilha do Google Sheets.
* **Minimização de Dados:** Apenas os dados estritamente necessários para o acompanhamento clínico e faturamento de sessões domiciliares são coletados.

### C. Registro de Consentimento
* O acesso ao login e uso do aplicativo é condicionado ao aceite do **Termo de Consentimento para Tratamento de Dados Pessoais e de Saúde**.
* A aceitação é usada como pré-condição para iniciar o login. A gravação formal desse aceite na planilha ainda deve ser implementada como melhoria de auditoria.
