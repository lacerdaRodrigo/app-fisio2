# Especificação da Tela: Pacientes

Esta tela permite a gestão, busca, cadastro e visualização detalhada dos pacientes cadastrados, garantindo a rastreabilidade histórica e a gestão da situação do paciente.

---

## 1. Requisitos Funcionais
* **Acesso ao Cadastro:** O botão central "+" da navegação inferior abre a tela de `TelaCadastroPaciente` quando o usuário está na aba `Pacientes`.
* **Buscador Dinâmico:** Campo de pesquisa que filtra a lista de pacientes em tempo real enquanto o usuário digita.
    * Critérios de busca: Nome ou CPF (o campo `CPF` já faz parte da aba `Pacientes` do Google Sheets).
* **Filtros de Lista:** A tela possui filtros `Todos`, `Ativos` e `Arquivados`.
    * `Ativos` é o filtro padrão.
    * `Todos` exibe pacientes ativos e arquivados.
    * `Arquivados` exibe apenas registros com `Situacao = "Arquivado"`.
    * Tocar novamente em `Arquivados` retorna para `Ativos`, preservando o comportamento de alternância usado nos testes.
* **Interação com Paciente (Pop-up/Modal de Detalhes):** Ao selecionar um paciente da lista, um modal exibe:
    * Nome Completo e Idade (calculada com base na `Data_Nascimento`).
    * Contato (Telefone) e Endereço Residencial.
    * **Anamnese Clínica Completa:**
        * Queixa Principal (QP) e Histórico da Doença Atual (HDA)
        * Gênero
        * Escala de Dor (0-10)
        * Comorbidades
        * Medicamentos em Uso
        * Alergias
        * Cirurgias/Traumas Prévios
        * Hábitos de Vida / Atividade Física
    * **Integração de Rotas (Google Maps / Waze):** Um ícone de rotas posicionado ao lado do endereço. Ao clicar, abre um bottom sheet próprio, com o endereço como contexto e opções em cards para Google Maps e Waze.
    * Botões de ação adicionais:
        1. **Nova Evolução:** Redireciona para o fluxo de registro clínico (`TelaRegistroEvolucao`).
        2. **Ver Histórico:** Exibe o prontuário completo (evoluções anteriores em formato de linha do tempo).
        3. **Arquivar Paciente:** Altera a situação do paciente para "Arquivado".
* **Regra de Arquivamento (LGPD/Integridade):**
    * Pacientes arquivados não aparecem no filtro padrão `Ativos`.
    * Os dados não são deletados da planilha (Google Sheets); apenas a situação é alterada para manter a integridade histórica dos prontuários.
    * Os filtros `Todos` e `Arquivados` permitem consultar pacientes arquivados caso o profissional precise recuperar algum dado.

---

## 2. Implementação Técnica
* **Gerenciamento de Estado (Riverpod):**
    * `provedorListaPacientes`: Para carregar os dados do Google Sheets.
    * `provedorBusca`: Armazena o termo de busca e filtra a lista em tempo real junto com o filtro visual selecionado.
* **Validação de Dados:**
    * Atualização do `MODELO_DADOS.md`: Adicionar coluna `CPF` e coluna `Situacao` (Ativo/Arquivado) na aba `Pacientes`.
* **Cálculo de Idade:** O app deve converter `Data_Nascimento` para a idade atual baseada em `DateTime.now()`.
* **Persistência:** A ação "Arquivar" deve realizar uma atualização (PATCH/PUT) na aba `Pacientes`, alterando a coluna `Situacao` de "Ativo" para "Arquivado".
* **Deep Link de Rotas:** Usar a biblioteca `url_launcher` e `Uri.encodeComponent(endereco)` para abrir:
  * Google Maps: `https://www.google.com/maps/search/?api=1&query=ENDERECO_ENCODED`
  * Waze: `https://waze.com/ul?q=ENDERECO_ENCODED`