import 'package:patrol/patrol.dart';

/// Configuração centralizada para testes E2E com Patrol
class E2EConfig {
  /// Timeout padrão para operações de UI
  static const defaultTimeout = Duration(seconds: 5);

  /// Timeout para operações que envolvem Google Sign-In (mais longo)
  static const authTimeout = Duration(seconds: 15);

  /// Timeout para operações de rede
  static const networkTimeout = Duration(seconds: 10);

  /// Package name do app Android
  static const androidPackage = 'com.rodrigo.fisio_care';

  /// Bundle ID do app iOS
  static const iosBundleId = 'com.rodrigo.fisio-care';

  /// Espera padrão entre ações (para melhor observabilidade)
  static const defaultWait = Duration(milliseconds: 300);

  /// Delay para dar tempo ao Google Sign-In aparecer
  static const googleSignInDelay = Duration(seconds: 3);

  /// Seletores comuns reutilizáveis
  static class Selectors {
    static const appTitle = 'FisioCare';
    static const loginButton = 'Entrar com Google';
    static const termsCheckbox = 'Termos de Uso';
    static const dashboardGreeting = 'Boa noite';
    static const pacientesTab = 'Pacientes';
    static const configTab = 'Configurações';
    static const logoutButton = 'Sair da conta';
  }

  /// Configurações do Patrol para diferentes dispositivos
  static PatrolTestConfig getPatrolConfig() {
    return PatrolTestConfig(
      /// Habilita screenshots automáticos ao falhar
      screenshotsOnFailure: true,

      /// Habilita logs detalhados
      enableWaitForAnimation: true,

      /// Timeout global para operações
      existsTimeout: defaultTimeout,
    );
  }
}
