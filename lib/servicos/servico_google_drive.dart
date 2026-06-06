import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

class ServicoGoogleDrive {
  static const nomeBanco = '__saas_fisio_db__';

  final drive.DriveApi _api;

  ServicoGoogleDrive(http.Client cliente) : _api = drive.DriveApi(cliente);

  Future<String?> buscarPlanilhaBanco() async {
    final resultado = await _api.files.list(
      q: "name='$nomeBanco' and mimeType='application/vnd.google-apps.spreadsheet' and trashed=false",
      spaces: 'drive',
      pageSize: 1,
      $fields: 'files(id,name)',
    );

    final arquivos = resultado.files ?? [];
    if (arquivos.isEmpty) return null;
    return arquivos.first.id;
  }
}
