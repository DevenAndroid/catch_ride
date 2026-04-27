import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class PriceInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('en_US');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only numbers and one decimal point
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    
    // Handle multiple decimal points (only allow the first one)
    if (newText.split('.').length > 2) {
      newText = oldValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    }

    // Split into integer and fractional parts
    List<String> parts = newText.split('.');
    String integerPart = parts[0];
    String? fractionalPart = parts.length > 1 ? parts[1] : null;

    if (integerPart.isEmpty && fractionalPart != null) {
      integerPart = '0';
    } else if (integerPart.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Format integer part with commas
    String formattedInteger = _formatter.format(int.parse(integerPart));

    // Combine with fractional part if it exists
    String formattedText = formattedInteger;
    if (fractionalPart != null) {
      // Limit fractional part to 2 digits for cents
      if (fractionalPart.length > 2) {
        fractionalPart = fractionalPart.substring(0, 2);
      }
      formattedText += '.$fractionalPart';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
