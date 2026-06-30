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
    final estadoCarregamento = ref.watch(provedorCarregamentoDados);
    final theme = Theme.of(context);
    final qtdeAtivos = pacientes.where((p) => p.estaAtivo).length;
    final qtdeArquivados = pacientes.where((p) => !p.estaAtivo).length;

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
                  bottomLeft: Radius.circular(FisioRaios.lg),
                  bottomRight: Radius.circular(FisioRaios.lg),
                ),
                boxShadow: FisioSombras.card,
              ),
              child: Column(
                children: [
                  // Cabeçalho
                  Row(
                    children: [
                      const Text(
                        'Meus Pacientes',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: FisioCores.textPrimary,
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
                          () {
                            switch (_filtro) {
                              case FiltroPacientes.todos:
                                return '${pacientes.length} total';
                              case FiltroPacientes.ativos:
                                return '$qtdeAtivos ativos';
                              case FiltroPacientes.arquivados:
                                return '$qtdeArquivados arquivados';
                            }
                          }(),
                          style: const TextStyle(
                            color: FisioCores.primary,
                            fontWeight: FontWeight.w600,
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
                        color: FisioCores.textMuted,
                      ),
                      suffixIcon: termoBusca.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: FisioCores.textMuted,
                              ),
                              onPressed: () =>
                                  ref.read(provedorBusca.notifier).definir(''),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FisioRaios.base),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: FisioCores.inputFill,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Pacientes
            Expanded(
              child: estadoCarregamento.status == StatusCarregamentoDados.carregando
                  ? const Center(child: CircularProgressIndicator())
                  : pacientesFiltrados.isEmpty
                      ? _construirEstadoVazio(theme)
                      : FisioResponsiveCenter(
                          maxWidth: FisioPontoQuebra.tablet,
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
          color: selecionado ? FisioCores.primary : FisioCores.inputFill,
          borderRadius: BorderRadius.circular(FisioRaios.lg),
          border: Border.all(
            color: selecionado
                ? FisioCores.primary
                : FisioCores.border,
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
    final iniciais = fisioIniciais(paciente.nome);
    final cor = fisioAvatarColor(paciente.nome);
    final estaArquivado = !paciente.estaAtivo;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(FisioRaios.base),
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
                  decoration: FisioDecoracoes.tinted(cor),
                  child: Center(
                    child: Text(
                      iniciais,
                      style: TextStyle(
                        color: cor,
                        fontWeight: FontWeight.w700,
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
