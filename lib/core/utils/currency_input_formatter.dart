import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// TextInputFormatter để định dạng tiền Việt Nam (1.000, 10.000, ...)
class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('vi_VN');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Loại bỏ tất cả ký tự không phải số
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue();
    }

    // Parse thành số
    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    // Format theo định dạng Việt Nam
    final formatted = _formatter.format(number);

    // Tính toán vị trí cursor mới
    int cursorPosition = formatted.length;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}

/// Helper function để parse số từ formatted string
int parseCurrencyInput(String formattedText) {
  final digitsOnly = formattedText.replaceAll(RegExp(r'[^\d]'), '');
  return int.tryParse(digitsOnly) ?? 0;
}
