import 'package:shared_preferences/shared_preferences.dart';

class Preferencias {
  static const _chavePlanilhaId = 'planilha_id';

  static Future<String?> lerPlanilhaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_chavePlanilhaId);
    } catch (_) {
      return null;
    }
  }

  static Future<void> salvarPlanilhaId(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_chavePlanilhaId, id);
    } catch (_) {}
  }

  static Future<void> limparPlanilhaId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chavePlanilhaId);
    } catch (_) {}
  }
}
