import 'package:http/http.dart' as http;

class ClienteGoogleAutenticado extends http.BaseClient {
  final Future<Map<String, String>> Function() _obterHeaders;
  final http.Client _interno;

  ClienteGoogleAutenticado(this._obterHeaders, {http.Client? interno})
    : _interno = interno ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.addAll(await _obterHeaders());
    return _interno.send(request);
  }

  @override
  void close() {
    _interno.close();
    super.close();
  }
}
