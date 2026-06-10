import 'package:flutter/services.dart';

class FormatterEscalaDor extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final valor = int.tryParse(newValue.text);
    if (valor == null || valor < 0 || valor > 10) {
      return oldValue;
    }
    return newValue;
  }
}
