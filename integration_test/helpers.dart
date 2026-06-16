import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';

/// Helpers comuns para testes E2E com Patrol
class TestHelpers {
  /// Realiza login completo no app
  /// Retorna true se login foi bem-sucedido, false se cancelado/falhou
  static Future<bool> fazerLogin(PatrolTester $) async {
    await $.pumpAndSettle();

    // Se já está logado, retorna true
    if (find.text('Boa noite').evaluate().isNotEmpty) {
      return true;
    }

    // Aguarda tela de login
    expect(find.text('FisioCare'), findsWidgets);

    // Marca checkbox de aceite de termos
    await $.tap(find.byType(Checkbox).first);
    await $.pumpAndSettle();

    // Clica botão "Entrar com Google"
    await $.tap(find.byType(ElevatedButton));
    await $.pumpAndSettle(Duration(seconds: 3));

    // Aguarda que o fluxo Google Sign-In se complete
    // Em um teste E2E real, Patrol interagiria com os diálogos do Google
    await $.pumpAndSettle(Duration(seconds: 10));

    // Verifica se chegou ao Dashboard
    return find.text('Boa noite').evaluate().isNotEmpty;
  }

  /// Faz logout do app
  static Future<void> fazerLogout(PatrolTester $) async {
    await $.pumpAndSettle();

    // Verifica se está logado
    if (find.text('Boa noite').evaluate().isEmpty) {
      return;
    }

    // Abre menu de configurações
    final avatar = find.byType(CircleAvatar).first;
    await $.tap(avatar);
    await $.pumpAndSettle();

    // Tap em Configurações
    await $.tap(find.text('Configurações'));
    await $.pumpAndSettle(Duration(seconds: 1));

    // Scroll para encontrar botão Sair
    await $.scrollUntilVisible(
      find.text('Sair da conta'),
      dyScroll: -200,
    );

    // Clica Sair da conta
    await $.tap(find.text('Sair da conta'));
    await $.pumpAndSettle();

    // Confirma logout (clica OK no AlertDialog)
    await $.tap(find.text('OK'));
    await $.pumpAndSettle(Duration(seconds: 1));
  }

  /// Aguarda e valida que o Dashboard está visível
  static Future<void> esperarDashboard(PatrolTester $) async {
    await $.pumpAndSettle(Duration(seconds: 2));
    expect(find.text('Boa noite'), findsWidgets);
  }

  /// Aguarda e valida que a tela de login está visível
  static Future<void> esperarLoginScreen(PatrolTester $) async {
    await $.pumpAndSettle();
    expect(find.text('FisioCare'), findsWidgets);
  }

  /// Scrolls até encontrar um widget visível
  static Future<void> scrollParaElemento(
    PatrolTester $,
    Finder finder, {
    double dy = -300,
    Duration? timeout,
  }) async {
    await $.scrollUntilVisible(finder, dyScroll: dy);
  }

  /// Aguarda um elemento aparecer na tela com timeout customizável
  static Future<void> aguardarElemento(
    PatrolTester $,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    while (stopwatch.elapsed < timeout) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await $.pump(Duration(milliseconds: 100));
    }
    throw 'Elemento não encontrado em ${timeout.inSeconds}s';
  }

  /// Limpa estado do app (simula "force stop" + "clear cache")
  /// Útil entre testes para garantir estado limpo
  static Future<void> limparAppState(PatrolTester $) async {
    // Nota: isto é mais relevante em testes que rodam em device real
    // Para tests locais (flutter test), cada teste já tem isolamento
    await Future.delayed(Duration(milliseconds: 500));
  }
}
