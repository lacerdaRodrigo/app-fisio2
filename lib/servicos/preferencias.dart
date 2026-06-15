import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

class Preferencias {
  static const _chavePlanilhaId = 'planilha_id';

  static Future<String?> lerPlanilhaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_chavePlanilhaId);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao ler planilha_id do SharedPreferences',
        error: e,
        stackTrace: stackTrace,
        name: 'Preferencias',
      );
      return null;
    }
  }

  static Future<void> salvarPlanilhaId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chavePlanilhaId, id);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao salvar planilha_id no SharedPreferences',
        error: e,
        stackTrace: stackTrace,
        name: 'Preferencias',
      );
      rethrow;
    }
  }

  static Future<void> limparPlanilhaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chavePlanilhaId);
    } catch (e, stackTrace) {
      developer.log(
        'Erro ao limpar planilha_id do SharedPreferences',
        error: e,
        stackTrace: stackTrace,
        name: 'Preferencias',
      );
    }
  }
}
