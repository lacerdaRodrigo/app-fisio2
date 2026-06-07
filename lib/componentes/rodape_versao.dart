const String _appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '0.0.0',
);

String get appVersao => 'v${_appVersion.split('+').first}';


