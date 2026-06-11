import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system.dart';
import '../modelos/paciente.dart';
import '../provedores/provedores_dados.dart';
import '../componentes/modal_detalhes_paciente.dart';

enum FiltroPacientes { todos, ativos, arquivados }

class TelaPacientes extends ConsumerStatefulWidget {
  final FiltroPacientes filtroInicial;

  const TelaPacientes({super.key, this.filtroInicial = FiltroPacientes.ativos});

  @override
  ConsumerState<TelaPacientes> createState() => _TelaPacientesState();
}

class _TelaPacientesState extends ConsumerState<TelaPacientes> {
  late FiltroPacientes _filtro;

  @override
  void initState() {
    super.initState();
    _filtro = widget.filtroInicial;
  }

  @override
  void didUpdateWidget(covariant TelaPacientes oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filtroInicial != widget.filtroInicial) {
      _filtro = widget.filtroInicial;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pacientes = ref.watch(provedorListaPacientes);
    final termoBusca = ref.watch(provedorBusca);
    final theme = Theme.of(context);
    final qtdeAtivos = pacientes.where((p) => p.estaAtivo).length;

    final pacientesFiltrados = pacientes.where((p) {
      switch (_filtro) {
        case FiltroPacientes.todos:
          break;
        case FiltroPacientes.ativos:
          if (!p.estaAtivo) return false;
          break;
        case FiltroPacientes.arquivados:
          if (p.estaAtivo) return false;
          break;
      }
      if (termoBusca.isEmpty) return true;
      final termo = termoBusca.toLowerCase();
      return p.nome.toLowerCase().contains(termo) || p.cpf.contains(termo);
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.055),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      Text(
                        'Meus Pacientes',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: FisioCores.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: FisioCores.primary.withValues(alpha: 0.14),
                          ),
                        ),
                        child: Text(
                          _filtro == FiltroPacientes.todos
                              ? '${pacientes.length} total'
                              : '$qtdeAtivos ativos',
                          style: const TextStyle(
                            color: Color(0xFF0D9488),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _construirFiltroChip('Todos', FiltroPacientes.todos),
                      const SizedBox(width: 8),
                      _construirFiltroChip('Ativos', FiltroPacientes.ativos),
                      const SizedBox(width: 8),
                      _construirFiltroChip(
                        'Arquivados',
                        FiltroPacientes.arquivados,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Buscador
                  TextField(
                    onChanged: (valor) =>
                        ref.read(provedorBusca.notifier).definir(valor),
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou CPF...',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                      ),
                      suffixIcon: termoBusca.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: Color(0xFF94A3B8),
                              ),
                              onPressed: () =>
                                  ref.read(provedorBusca.notifier).definir(''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Pacientes
            Expanded(
              child: pacientesFiltrados.isEmpty
                  ? _construirEstadoVazio(theme)
                  : FisioResponsiveCenter(
                      maxWidth: 620,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
                        itemCount: pacientesFiltrados.length,
                        itemBuilder: (context, index) {
                          final paciente = pacientesFiltrados[index];
                          return _construirCardPaciente(context, paciente);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirFiltroChip(String label, FiltroPacientes filtro) {
    final selecionado = _filtro == filtro;

    return GestureDetector(
      onTap: () => setState(() {
        if (_filtro == FiltroPacientes.arquivados &&
            filtro == FiltroPacientes.arquivados) {
          _filtro = FiltroPacientes.ativos;
          return;
        }

        _filtro = filtro;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selecionado ? FisioCores.primaryDark : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selecionado
                ? FisioCores.primaryDark
                : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selecionado ? Colors.white : FisioCores.textSecondary,
          ),
        ),
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
    final cor = fisioAvatarColor(paciente.nome);
    final estaArquivado = !paciente.estaAtivo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => mostrarModalDetalhesPaciente(context, paciente),
        child: Opacity(
          opacity: estaArquivado ? 0.6 : 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: FisioDecoracoes.card(),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cor.withValues(alpha: 0.16)),
                  ),
                  child: Center(
                    child: Text(
                      iniciais.toUpperCase(),
                      style: TextStyle(
                        color: cor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
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
                                color: FisioCores.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (estaArquivado) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
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
                      Text(
                        '$idade anos • ${paciente.cpf}',
                        style: const TextStyle(
                          color: FisioCores.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
