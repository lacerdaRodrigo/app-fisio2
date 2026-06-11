import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../componentes/design_system.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../utilitarios/formatters.dart';
import '../utilitarios/validador_cpf.dart';

class TelaCadastroPaciente extends ConsumerStatefulWidget {
  const TelaCadastroPaciente({super.key});

  @override
  ConsumerState<TelaCadastroPaciente> createState() =>
      _TelaCadastroPacienteState();
}

class _TelaCadastroPacienteState extends ConsumerState<TelaCadastroPaciente> {
  final _chaveFormulario = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _cpfController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _queixaController = TextEditingController();
  String _genero = 'Masculino';
  final _dorController = TextEditingController();
  final _historicoController = TextEditingController();
  final _comorbidadesController = TextEditingController();
  final _medicamentosController = TextEditingController();
  final _alergiasController = TextEditingController();
  final _cirurgiasController = TextEditingController();
  final _habitosVidaController = TextEditingController();
  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {'#': RegExp(r'[0-9]')},
  );
  final _telefoneFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String _rua = '';
  String _bairro = '';
  String _numero = '';
  String _cidade = '';

  String get _enderecoCompleto {
    final partes = <String>[
      if (_rua.isNotEmpty) _rua,
      if (_numero.isNotEmpty) _numero,
      if (_bairro.isNotEmpty) _bairro,
      if (_cidade.isNotEmpty) _cidade,
    ];
    return partes.isEmpty ? '' : partes.join(', ');
  }

  DateTime? _dataNascimento;
  bool _salvando = false;

  @override
  void dispose() {
    _nomeController.dispose();
    _cpfController.dispose();
    _telefoneController.dispose();
    _queixaController.dispose();
    _dorController.dispose();
    _historicoController.dispose();
    _comorbidadesController.dispose();
    _medicamentosController.dispose();
    _alergiasController.dispose();
    _cirurgiasController.dispose();
    _habitosVidaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FisioPageHeader(
            title: 'Novo Paciente',
            subtitle: 'Dados pessoais e anamnese clínica',
            onBack: () => Navigator.pop(context),
            closeIcon: true,
          ),
          Expanded(
            child: Form(
              key: _chaveFormulario,
              child: FisioResponsiveCenter(
                maxWidth: 680,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 96),
                  children: [
                    // Seção: Dados Pessoais
                    _construirTituloSecao(
                      'Dados Pessoais',
                      Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo *',
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nome é obrigatório.'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _cpfController,
                      decoration: const InputDecoration(
                        labelText: 'CPF *',
                        prefixIcon: Icon(Icons.fingerprint_rounded),
                        hintText: '000.000.000-00',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _cpfFormatter,
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'CPF é obrigatório.';
                        // Remove formatting for validation
                        final cpf = v.replaceAll(RegExp(r'[^\d]'), '');
                        if (!ValidadorCpf.validar(cpf)) return 'CPF inválido.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
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
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Telefone é obrigatório.'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Data de Nascimento
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: _dataNascimento ?? DateTime(1990),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          locale: const Locale('pt', 'BR'),
                        ).then((data) {
                          if (data != null) {
                            setState(() => _dataNascimento = data);
                          }
                        });
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Data de Nascimento',
                          prefixIcon: Icon(Icons.cake_outlined),
                        ),
                        child: Text(
                          _dataNascimento != null
                              ? '${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}'
                              : 'Selecionar data',
                          style: TextStyle(
                            color: _dataNascimento != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _mostrarModalEndereco(),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Endereço *',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          suffixIcon: const Icon(
                            Icons.edit_location_alt_rounded,
                          ),
                        ),
                        child: Text(
                          _enderecoCompleto.isEmpty
                              ? 'Toque para preencher endereço'
                              : _enderecoCompleto,
                          style: TextStyle(
                            color: _enderecoCompleto.isNotEmpty
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Seção: Anamnese Clínica
                    _construirTituloSecao(
                      'Anamnese Clínica',
                      Icons.medical_information_outlined,
                    ),
                    const SizedBox(height: 12),

                    // Subseção: Sintomas e Queixas
                    _construirSubtituloSecao('Sintomas e Queixas'),
                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _queixaController,
                      decoration: const InputDecoration(
                        labelText: 'Queixa Principal (QP)',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: _historicoController,
                      decoration: const InputDecoration(
                        labelText: 'Histórico da Doença Atual (HDA)',
                        hintText: 'EVA, fatores de piora/melhora...',
                      ),
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: _genero,
                      decoration: const InputDecoration(
                        labelText: 'Gênero',
                        prefixIcon: Icon(Icons.transgender),
                      ),
                      items: ['Masculino', 'Feminino', 'Outro'].map((
                        String value,
                      ) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _genero = value!;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione o gênero';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Informe a intensidade da dor';
                        }
                        final dor = int.tryParse(value);
                        if (dor == null || dor < 0 || dor > 10) {
                          return 'A dor deve ser entre 0 e 10';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Subseção: Histórico Clínico
                    _construirSubtituloSecao('Histórico Clínico'),
                    const SizedBox(height: 8),

                    TextFormField(
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

                    // Subseção: Estilo de Vida
                    _construirSubtituloSecao('Estilo de Vida'),
                    const SizedBox(height: 8),

                    TextFormField(
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

                    // Botão Salvar
                    SizedBox(
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _salvando ? null : _salvarPaciente,
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
                        label: Text(
                          _salvando ? 'Salvando...' : 'Salvar Paciente',
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
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
        fontWeight: FontWeight.w800,
        color: FisioCores.primary,
      ),
    );
  }

  Future<void> _mostrarModalEndereco() async {
    final rua = _rua;
    final bairro = _bairro;
    final numero = _numero;
    final cidade = _cidade;

    final resultado = await showDialog<_Endereco>(
      context: context,
      builder: (ctx) => _ModalEndereco(
        rua: rua,
        bairro: bairro,
        numero: numero,
        cidade: cidade,
      ),
    );

    if (resultado != null) {
      setState(() {
        _rua = resultado.rua;
        _bairro = resultado.bairro;
        _numero = resultado.numero;
        _cidade = resultado.cidade;
      });
    }
  }

  Future<void> _salvarPaciente() async {
    if (!_chaveFormulario.currentState!.validate()) return;
    if (_dataNascimento == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento.')),
      );
      return;
    }
    if (_enderecoCompleto.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Preencha o endereço.')));
      return;
    }

    setState(() => _salvando = true);

    final pacientes = ref.read(provedorListaPacientes);
    final cpf = _cpfController.text.trim();
    final cpfJaCadastrado = pacientes.any((paciente) => paciente.cpf == cpf);

    if (cpfJaCadastrado) {
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Este CPF já está cadastrado.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final novoPaciente = Paciente(
      idPaciente: 'P${(pacientes.length + 1).toString().padLeft(3, '0')}',
      nome: _nomeController.text.trim(),
      telefone: _telefoneController.text.trim(),
      dataNascimento: _dataNascimento!,
      cpf: cpf,
      endereco: _enderecoCompleto,
      queixaPrincipal: _queixaController.text.trim().isEmpty
          ? null
          : _queixaController.text.trim(),
      histDoencaAtual: _historicoController.text.trim().isEmpty
          ? null
          : _historicoController.text.trim(),
      comorbidades: _comorbidadesController.text.trim().isEmpty
          ? null
          : _comorbidadesController.text.trim(),
      medicamentos: _medicamentosController.text.trim().isEmpty
          ? null
          : _medicamentosController.text.trim(),
      alergias: _alergiasController.text.trim().isEmpty
          ? null
          : _alergiasController.text.trim(),
      cirurgias: _cirurgiasController.text.trim().isEmpty
          ? null
          : _cirurgiasController.text.trim(),
      habitosVida: _habitosVidaController.text.trim().isEmpty
          ? null
          : _habitosVidaController.text.trim(),
      genero: _genero,
      dor: _dorController.text.trim().isEmpty
          ? null
          : _dorController.text.trim(),
    );

    try {
      await salvarPacienteReal(ref, novoPaciente);
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paciente cadastrado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Falha ao salvar paciente: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _Endereco {
  final String rua;
  final String bairro;
  final String numero;
  final String cidade;

  _Endereco({
    required this.rua,
    required this.bairro,
    required this.numero,
    required this.cidade,
  });
}

class _ModalEndereco extends StatefulWidget {
  final String rua;
  final String bairro;
  final String numero;
  final String cidade;

  const _ModalEndereco({
    required this.rua,
    required this.bairro,
    required this.numero,
    required this.cidade,
  });

  @override
  State<_ModalEndereco> createState() => _ModalEnderecoState();
}

class _ModalEnderecoState extends State<_ModalEndereco> {
  late final TextEditingController _ruaController;
  late final TextEditingController _bairroController;
  late final TextEditingController _numeroController;
  late final TextEditingController _cidadeController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ruaController = TextEditingController(text: widget.rua);
    _bairroController = TextEditingController(text: widget.bairro);
    _numeroController = TextEditingController(text: widget.numero);
    _cidadeController = TextEditingController(text: widget.cidade);
  }

  @override
  void dispose() {
    _ruaController.dispose();
    _bairroController.dispose();
    _numeroController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Icon(
            Icons.edit_location_alt_rounded,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          const Text('Editar Endereço'),
        ],
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _ruaController,
                decoration: const InputDecoration(labelText: 'Rua/Avenida *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe a rua/avenida.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _numeroController,
                decoration: const InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bairroController,
                decoration: const InputDecoration(labelText: 'Bairro *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe o bairro.'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cidadeController,
                decoration: const InputDecoration(labelText: 'Cidade *'),
                textCapitalization: TextCapitalization.words,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe a cidade.'
                    : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _Endereco(
                rua: _ruaController.text.trim(),
                bairro: _bairroController.text.trim(),
                numero: _numeroController.text.trim(),
                cidade: _cidadeController.text.trim(),
              ),
            );
          },
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Confirmar'),
        ),
      ],
    );
  }
}
