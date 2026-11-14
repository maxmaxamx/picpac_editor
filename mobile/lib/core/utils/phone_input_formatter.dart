import 'package:flutter/services.dart';

/// Маска ввода белорусского номера телефона: +375 (XX) XXX-XX-XX
class BelarusPhoneFormatter extends TextInputFormatter {
  const BelarusPhoneFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Если начинается с 375, убираем код страны для форматирования
    if (digitsOnly.startsWith('375')) {
      digitsOnly = digitsOnly.substring(3);
    }

    if (digitsOnly.length > 9) {
      digitsOnly = digitsOnly.substring(0, 9);
    }

    final buffer = StringBuffer('+375 ');

    if (digitsOnly.isNotEmpty) {
      buffer.write('(');
      if (digitsOnly.length <= 2) {
        buffer.write(digitsOnly);
      } else {
        buffer.write(digitsOnly.substring(0, 2));
        buffer.write(') ');

        if (digitsOnly.length <= 5) {
          buffer.write(digitsOnly.substring(2));
        } else {
          buffer.write(digitsOnly.substring(2, 5));
          buffer.write('-');

          if (digitsOnly.length <= 7) {
            buffer.write(digitsOnly.substring(5));
          } else {
            buffer.write(digitsOnly.substring(5, 7));
            buffer.write('-');
            buffer.write(digitsOnly.substring(7));
          }
        }
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

