# Especificação da Tela: Pacientes

Esta tela permite a gestão, busca, cadastro e visualização detalhada dos pacientes cadastrados, garantindo a rastreabilidade histórica e a gestão da situação do paciente.

---

## 1. Requisitos Funcionais
* **Acesso ao Cadastro:** Exibe um botão flutuante (Floating Action Button - "+") no canto inferior direito para abrir a tela de `TelaCadastroPaciente` (Anamnese).
* **Buscador Dinâmico:** Campo de pesquisa que filtra a lista de pacientes em tempo real enquanto o usuário digita.
    * Critérios de busca: Nome ou CPF (o campo `CPF` já faz parte da aba `Pacientes` do Google Sheets).
* **Lista de Pacientes:** Exibição filtrada dos pacientes que possuem a situação "Ativo".
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
    * **Integração de Rotas (Google Maps / Waze):** Um ícone de rotas ("Como Chegar") posicionado ao lado do endereço. Ao clicar, abre o modal de seleção rápida entre Google Maps e Waze para traçar a rota até a casa do paciente.
    * Botões de ação adicionais:
        1. **Nova Evolução:** Redireciona para o fluxo de registro clínico (`TelaRegistroEvolucao`).
        2. **Ver Histórico:** Exibe o prontuário completo (evoluções anteriores em formato de linha do tempo).
        3. **Arquivar Paciente:** Altera a situação do paciente para "Arquivado".
* **Regra de Arquivamento (LGPD/Integridade):**
    * Pacientes arquivados não aparecem mais na lista principal de busca.
    * Os dados não são deletados da planilha (Google Sheets); apenas a situação é alterada para manter a integridade histórica dos prontuários.
    * Deve haver uma área ou filtro para visualizar pacientes arquivados caso o profissional precise recuperar algum dado.

---

## 2. Implementação Técnica
* **Gerenciamento de Estado (Riverpod):**
    * `provedorListaPacientes`: Para carregar os dados do Google Sheets.
    * `provedorPacientesFiltrados`: Um `Provider` que ouve o termo de busca e filtra a lista em tempo real.
* **Validação de Dados:**
    * Atualização do `MODELO_DADOS.md`: Adicionar coluna `CPF` e coluna `Situacao` (Ativo/Arquivado) na aba `Pacientes`.
* **Cálculo de Idade:** O app deve converter `Data_Nascimento` para a idade atual baseada em `DateTime.now()`.
* **Persistência:** A ação "Arquivar" deve realizar uma atualização (PATCH/PUT) na aba `Pacientes`, alterando a coluna `Situacao` de "Ativo" para "Arquivado".
* **Deep Link de Rotas:** Usar a biblioteca `url_launcher` para abrir:
  * Google Maps: `https://www.google.com/maps/search/?api=1&query=ENDERECO`
  * Waze: `https://waze.com/ul?q=ENDERECO`