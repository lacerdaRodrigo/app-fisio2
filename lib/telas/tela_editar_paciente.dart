import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../componentes/design_system.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/formatters.dart';
import '../utilitarios/utilitarios_data.dart';

/// Tela de edição de um paciente já cadastrado.
///
/// Campos de identidade — Nome, CPF, Data de Nascimento e Gênero — são
/// exibidos travados (somente leitura) por regra de negócio: não podem mudar
/// após o cadastro. Os demais campos (contato, endereço e anamnese) são
/// editáveis e salvos como atualização da linha existente na planilha.
class TelaEditarPaciente extends ConsumerStatefulWidget {
  final Paciente paciente;

  const TelaEditarPaciente({super.key, required this.paciente});

  @override
  ConsumerState<TelaEditarPaciente> createState() => _TelaEditarPacienteState();
}

class _TelaEditarPacienteState extends ConsumerState<TelaEditarPaciente> {
  late final TextEditingController _telefoneController;
  late final TextEditingController _enderecoController;
  late final TextEditingController _queixaController;
  late final TextEditingController _historicoController;
  late final TextEditingController _histPregressoController;
  late final TextEditingController _ocupacaoController;
  late final TextEditingController _dorController;
  late final TextEditingController _comorbidadesController;
  late final TextEditingController _medicamentosController;
  late final TextEditingController _alergiasController;
  late final TextEditingController _cirurgiasController;
  late final TextEditingController _habitosVidaController;

  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.paciente;
    _telefoneController = TextEditingController(text: p.telefone);
    _enderecoController = TextEditingController(text: p.endereco);
    _queixaController = TextEditingController(text: p.queixaPrincipal ?? '');
    _historicoController = TextEditingController(text: p.histDoencaAtual ?? '');
    _histPregressoController =
        TextEditingController(text: p.histPregresso ?? '');
    _ocupacaoController = TextEditingController(text: p.ocupacao ?? '');
    _dorController = TextEditingController(text: p.dor ?? '');
    _comorbidadesController =
        TextEditingController(text: p.comorbidades ?? '');
    _medicamentosController =
        TextEditingController(text: p.medicamentos ?? '');
    _alergiasController = TextEditingController(text: p.alergias ?? '');
    _cirurgiasController = TextEditingController(text: p.cirurgias ?? '');
    _habitosVidaController = TextEditingController(text: p.habitosVida ?? '');
  }

  @override
  void dispose() {
    _telefoneController.dispose();
    _enderecoController.dispose();
    _queixaController.dispose();
    _historicoController.dispose();
    _histPregressoController.dispose();
    _ocupacaoController.dispose();
    _dorController.dispose();
    _comorbidadesController.dispose();
    _medicamentosController.dispose();
    _alergiasController.dispose();
    _cirurgiasController.dispose();
    _habitosVidaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.paciente;
    return Scaffold(
      body: Column(
        children: [
          FisioPageHeader(
            title: 'Editar Paciente',
            subtitle: p.nome,
            onBack: () => Navigator.pop(context),
            closeIcon: true,
          ),
          Expanded(
            child: FisioResponsiveCenter(
              maxWidth: 680,
              child: AbsorbPointer(
                absorbing: _salvando,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                  children: [
                    // Seção: Dados Pessoais (somente leitura)
                    _construirTituloSecao(
                      'Dados Pessoais',
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nome, CPF, data de nascimento e gênero não podem ser '
                      'alterados após o cadastro.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _campoTravado(
                      chave: 'campo_nome',
                      rotulo: 'Nome Completo',
                      valor: p.nome,
                      icone: Icons.badge_outlined,
                    ),
                    const SizedBox(height: 12),

                    _campoTravado(
                      chave: 'campo_cpf',
                      rotulo: 'CPF',
                      valor: p.cpf,
                      icone: Icons.fingerprint_rounded,
                    ),
                    const SizedBox(height: 12),

                    _campoTravado(
                      chave: 'campo_data_nascimento',
                      rotulo: 'Data de Nascimento',
                      valor: UtilitariosData.formatarDataBr(p.dataNascimento),
                      icone: Icons.cake_outlined,
                    ),
                    const SizedBox(height: 12),

                    _campoTravado(
                      chave: 'campo_genero',
                      rotulo: 'Gênero',
                      valor: p.genero ?? 'Não informado',
                      icone: Icons.transgender,
                    ),
                    const SizedBox(height: 12),

                    // Campos editáveis de contato/endereço
                    TextFormField(
                      key: const Key('campo_telefone'),
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone *',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '(00) 00000-0000',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _telefoneFormatter,
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_endereco'),
                      controller: _enderecoController,
                      decoration: const InputDecoration(
                        labelText: 'Endereço *',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.words,
                    ),

                    const SizedBox(height: 28),

                    // Seção: Anamnese Clínica
                    _construirTituloSecao(
                      'Anamnese Clínica',
                      Icons.medical_information_outlined,
                    ),
                    const SizedBox(height: 12),

                    _construirSubtituloSecao('Sintomas e Queixas'),
                    const SizedBox(height: 8),

                    TextFormField(
                      key: const Key('campo_queixa'),
                      controller: _queixaController,
                      decoration: const InputDecoration(
                        labelText: 'Queixa Principal (QP)',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_hda'),
                      controller: _historicoController,
                      decoration: const InputDecoration(
                        labelText: 'Histórico da Doença Atual (HDA)',
                        hintText: 'EVA, fatores de piora/melhora...',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_hp'),
                      controller: _histPregressoController,
                      decoration: const InputDecoration(
                        labelText: 'História Pregressa (HP)',
                        hintText: 'Antecedentes, comorbidades prévias...',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_ocupacao'),
                      controller: _ocupacaoController,
                      decoration: const InputDecoration(
                        labelText: 'Ocupação / Profissão',
                        prefixIcon: Icon(Icons.work_outline),
                        hintText: 'Ex: Professor, Motorista, Aposentado...',
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_escala_dor'),
                      controller: _dorController,
                      decoration: const InputDecoration(
                        labelText: 'Escala de dor (0-10)',
                        hintText: '0 a 10',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        FormatterEscalaDor(),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _construirSubtituloSecao('Histórico Clínico'),
                    const SizedBox(height: 8),

                    TextFormField(
                      key: const Key('campo_comorbidades'),
                      controller: _comorbidadesController,
                      decoration: const InputDecoration(
                        labelText: 'Comorbidades/Doenças Prévias',
                        hintText: 'Ex: Hipertensão, Diabetes, Cardiopatias...',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_medicamentos'),
                      controller: _medicamentosController,
                      decoration: const InputDecoration(
                        labelText: 'Medicamentos em Uso',
                        hintText: 'Liste os medicamentos atuais...',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_alergias'),
                      controller: _alergiasController,
                      decoration: const InputDecoration(
                        labelText: 'Alergias',
                        hintText: 'Ex: Dipirona, Látex, Iodo...',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      key: const Key('campo_cirurgias'),
                      controller: _cirurgiasController,
                      decoration: const InputDecoration(
                        labelText: 'Cirurgias/Traumas Prévios',
                        hintText:
                            'Ex: Fraturas, implantes metálicos, cirurgias...',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 20),

                    _construirSubtituloSecao('Estilo de Vida'),
                    const SizedBox(height: 8),

                    TextFormField(
                      key: const Key('campo_habitos'),
                      controller: _habitosVidaController,
                      decoration: const InputDecoration(
                        labelText: 'Hábitos de Vida / Atividade Física',
                        hintText:
                            'Sedentarismo, frequência de exercícios, profissão...',
                      ),
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
          // Botão Salvar fixo no final da tela
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  key: const Key('btn_salvar_edicao'),
                  onPressed: _salvando ? null : _salvarAlteracoes,
                  icon: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded),
                  label: Text(_salvando ? 'Salvando...' : 'Salvar Alterações'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoTravado({
    required String chave,
    required String rotulo,
    required String valor,
    required IconData icone,
  }) {
    return TextFormField(
      key: Key(chave),
      enabled: false,
      initialValue: valor,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixIcon: Icon(icone),
        suffixIcon: Icon(Icons.lock_outline, color: Colors.grey.shade500),
        helperText: 'Campo não editável',
      ),
    );
  }

  Widget _construirTituloSecao(String titulo, IconData icone) {
    return FisioSectionTitle(title: titulo, icon: icone);
  }

  Widget _construirSubtituloSecao(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: FisioCores.primary,
      ),
    );
  }

  List<String> _listarCamposFaltando() {
    final faltando = <String>[];

    final digitosTel =
        _telefoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    if (digitosTel.isEmpty) {
      faltando.add('Telefone');
    } else if (digitosTel.length < 10) {
      faltando.add('Telefone inválido (mínimo 10 dígitos)');
    }

    if (_enderecoController.text.trim().isEmpty) faltando.add('Endereço');
    if (_dorController.text.trim().isEmpty) {
      faltando.add('Escala de dor (0-10)');
    }

    return faltando;
  }

  void _mostrarDialogCamposFaltando(List<String> campos) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Campos obrigatórios'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verifique os seguintes campos:'),
            const SizedBox(height: 12),
            ...campos.map(
              (c) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(c),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _trimOuNull(String texto) {
    final t = texto.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _salvarAlteracoes() async {
    final faltando = _listarCamposFaltando();
    if (faltando.isNotEmpty) {
      _mostrarDialogCamposFaltando(faltando);
      return;
    }

    setState(() => _salvando = true);

    final original = widget.paciente;
    // Constrói diretamente (em vez de copiarCom) para permitir limpar campos
    // opcionais para null. Identidade preservada do paciente original.
    final atualizado = Paciente(
      idPaciente: original.idPaciente,
      nome: original.nome,
      telefone: _telefoneController.text.trim(),
      dataNascimento: original.dataNascimento,
      cpf: original.cpf,
      endereco: _enderecoController.text.trim(),
      queixaPrincipal: _trimOuNull(_queixaController.text),
      histDoencaAtual: _trimOuNull(_historicoController.text),
      histPregresso: _trimOuNull(_histPregressoController.text),
      ocupacao: _trimOuNull(_ocupacaoController.text),
      genero: original.genero,
      dor: _trimOuNull(_dorController.text),
      comorbidades: _trimOuNull(_comorbidadesController.text),
      medicamentos: _trimOuNull(_medicamentosController.text),
      alergias: _trimOuNull(_alergiasController.text),
      cirurgias: _trimOuNull(_cirurgiasController.text),
      habitosVida: _trimOuNull(_habitosVidaController.text),
      situacao: original.situacao,
      dataCadastro: original.dataCadastro,
    );

    try {
      await atualizarPacienteReal(ref, atualizado);
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paciente atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ocorreu um erro inesperado. Tente novamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
