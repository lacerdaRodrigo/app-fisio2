import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../componentes/design_system_fisio.dart';

/// Tela Configurações — perfil, base de dados (planilha), preferências e conta.
class TelaConfiguracoes extends ConsumerStatefulWidget {
  final String nome;
  final String email;
  final String nomePlanilha;
  final VoidCallback? onSincronizar;
  final VoidCallback? onAbrirDrive;
  final VoidCallback? onSair;
  final VoidCallback? onPrivacidade;
  final VoidCallback? onTermos;
  final VoidCallback? onExportar;

  const TelaConfiguracoes({
    super.key,
    required this.nome,
    required this.email,
    this.nomePlanilha = '__saas_fisio_home_care',
    this.onSincronizar,
    this.onAbrirDrive,
    this.onSair,
    this.onPrivacidade,
    this.onTermos,
    this.onExportar,
  });

  @override
  ConsumerState<TelaConfiguracoes> createState() => _TelaConfiguracoesState();
}

class _TelaConfiguracoesState extends ConsumerState<TelaConfiguracoes> {
  bool _notif = true;
  bool _lembrete = true;
  bool _escuro = false;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FisioCores.surface,
      child: FisioResponsiveCenter(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FisioGradientHeader(
              eyebrow: 'Conta',
              titulo: 'Configurações',
              bottom: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(fisioIniciais(widget.nome),
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.nome,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          Text(widget.email,
                              style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.75))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const FisioSectionLabel('Base de dados'),
                  const SizedBox(height: 9),
                  FisioCard(
                    radius: 16,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: FisioCores.success.withValues(alpha: 0.13),
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: const Icon(Icons.grid_on_rounded,
                                  color: FisioCores.success, size: 18),
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Planilha conectada',
                                      style: TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: FisioCores.textPrimary)),
                                  Text(widget.nomePlanilha,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: FisioCores.textMuted)),
                                ],
                              ),
                            ),
                            const FisioStatusPill(
                                label: 'Ativa', cor: FisioCores.success),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                                child: _botaoSecundario(
                                    'Sincronizar', widget.onSincronizar)),
                            const SizedBox(width: 8),
                            Expanded(
                                child: _botaoSecundario(
                                    'Abrir no Drive', widget.onAbrirDrive)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const FisioSectionLabel('Preferências'),
                  const SizedBox(height: 9),
                  FisioCard(
                    radius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _switchTile(Icons.notifications_rounded, FisioCores.primary,
                            'Notificações', 'Alertas de sessões e pendências',
                            _notif, (v) => setState(() => _notif = v)),
                        _divisor(),
                        _switchTile(Icons.edit_note_rounded, FisioCores.warning,
                            'Lembrete de evolução', 'Avisar após cada atendimento',
                            _lembrete, (v) => setState(() => _lembrete = v)),
                        _divisor(),
                        _switchTile(Icons.dark_mode_rounded, const Color(0xFF6366F1),
                            'Tema escuro', 'Seguir sistema',
                            _escuro, (v) => setState(() => _escuro = v),
                            ultimo: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const FisioSectionLabel('Privacidade e conta'),
                  const SizedBox(height: 9),
                  FisioCard(
                    radius: 16,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _linkTile('Política de Privacidade', widget.onPrivacidade),
                        _divisor(),
                        _linkTile('Termos de Uso', widget.onTermos),
                        _divisor(),
                        _linkTile('Exportar meus dados', widget.onExportar),
                        _divisor(),
                        _linkTile('Sair da conta', widget.onSair, danger: true,
                            ultimo: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text('Fisio Home Care · v1.0.0',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB6C2CC))),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoSecundario(String label, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF475569))),
      ),
    );
  }

  Widget _switchTile(IconData icon, Color cor, String titulo, String sub,
      bool valor, ValueChanged<bool> onChanged,
      {bool ultimo = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: cor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo,
                    style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: FisioCores.textPrimary)),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: FisioCores.textMuted)),
              ],
            ),
          ),
          Switch(
            value: valor,
            activeColor: Colors.white,
            activeTrackColor: FisioCores.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _linkTile(String titulo, VoidCallback? onTap,
      {bool danger = false, bool ultimo = false}) {
    final cor = danger ? FisioCores.danger : FisioCores.textPrimary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(titulo,
                  style: TextStyle(
                      fontSize: 13.5, fontWeight: FontWeight.w700, color: cor)),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18,
                color: danger ? FisioCores.danger : const Color(0xFFCBD5E1)),
          ],
        ),
      ),
    );
  }

  Widget _divisor() =>
      const Divider(height: 1, color: Color(0xFFF1F5F9));
}
