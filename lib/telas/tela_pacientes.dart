import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import 'tela_cadastro_paciente.dart';
import '../componentes/modal_detalhes_paciente.dart';

class TelaPacientes extends ConsumerStatefulWidget {
  const TelaPacientes({super.key});

  @override
  ConsumerState<TelaPacientes> createState() => _TelaPacientesState();
}

class _TelaPacientesState extends ConsumerState<TelaPacientes> {
  bool _mostrarArquivados = false;

  @override
  Widget build(BuildContext context) {
    final pacientes = ref.watch(provedorListaPacientes);
    final termoBusca = ref.watch(provedorBusca);
    final theme = Theme.of(context);
    final qtdeAtivos = pacientes.where((p) => p.estaAtivo).length;

    final pacientesFiltrados = pacientes.where((p) {
      if (_mostrarArquivados) {
        if (p.estaAtivo) return false;
      } else {
        if (!p.estaAtivo) return false;
      }
      if (termoBusca.isEmpty) return true;
      final termo = termoBusca.toLowerCase();
      return p.nome.toLowerCase().contains(termo) || p.cpf.contains(termo);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Text(
                    'Meus Pacientes',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$qtdeAtivos ativos',
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Arquivados'),
                    selected: _mostrarArquivados,
                    onSelected: (v) =>
                        setState(() => _mostrarArquivados = v),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            // Buscador
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                onChanged: (valor) =>
                    ref.read(provedorBusca.notifier).definir(valor),
                decoration: InputDecoration(
                  hintText: 'Buscar por nome ou CPF...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: termoBusca.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              ref.read(provedorBusca.notifier).definir(''),
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ),

            // Lista de Pacientes
            Expanded(
              child: pacientesFiltrados.isEmpty
                  ? _construirEstadoVazio(theme)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final paciente = pacientesFiltrados[index];
                        return _construirCardPaciente(context, paciente);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TelaCadastroPaciente()),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }

  Widget _construirEstadoVazio(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum paciente encontrado.',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em "+" para cadastrar.',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
        ],
      ),
    );
  }

Widget _construirCardPaciente(BuildContext context, Paciente paciente) {
  final idade = paciente.calcularIdade();
  final iniciais = paciente.nome
      .split(' ')
      .map((n) => n.isNotEmpty ? n[0] : '')
      .take(2)
      .join();
  final cores = [
    const Color(0xFF00796B),
    const Color(0xFF5C6BC0),
    const Color(0xFFFF8F00),
    const Color(0xFFE91E63),
  ];
  final cor = cores[paciente.nome.length % cores.length];
  final estaArquivado = !paciente.estaAtivo;

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => mostrarModalDetalhesPaciente(context, paciente),
        child: Container(
          constraints: const BoxConstraints(minHeight: 80),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: cor.withValues(alpha: 0.15),
                child: Text(
                  iniciais.toUpperCase(),
                  style: TextStyle(
                    color: cor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            paciente.nome,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (estaArquivado) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4),
                            ),
                              child: Text(
                                'Arquivado',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Opacity(
                      opacity: estaArquivado ? 0.6 : 1,
                      child: Text(
                        '$idade anos • ${paciente.cpf}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    ),
  );
}
}
