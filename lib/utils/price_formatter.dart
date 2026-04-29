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

    // If only a decimal point is entered, convert to "0."
    if (newValue.text == '.') {
      return const TextEditingValue(
        text: '0.',
        selection: TextSelection.collapsed(offset: 2),
      );
    }

    // Filter out everything except numbers and a single decimal point
    String filteredText = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    
    // Check if more than one decimal point exists
    if (filteredText.split('.').length > 2) {
      return oldValue;
    }

    // Split into integer and fractional parts
    List<String> parts = filteredText.split('.');
    String integerPart = parts[0];
    String? fractionalPart = parts.length > 1 ? parts[1] : null;

    // Handle leading zero if integer part is empty but decimal exists
    if (integerPart.isEmpty && parts.length > 1) {
      integerPart = '0';
    } else if (integerPart.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Format integer part with commas
    String formattedInteger;
    try {
      // Limit to max double to avoid overflow
      if (integerPart.length > 15) {
        integerPart = integerPart.substring(0, 15);
      }
      formattedInteger = _formatter.format(int.parse(integerPart));
    } catch (e) {
      formattedInteger = integerPart;
    }

    // Reconstruct the full string
    String formattedText = formattedInteger;
    if (parts.length > 1) {
      formattedText += '.';
      if (fractionalPart != null) {
        // Limit cents to 2 digits
        if (fractionalPart.length > 2) {
          fractionalPart = fractionalPart.substring(0, 2);
        }
        formattedText += fractionalPart;
      }
    }

    // Calculate new cursor position
    // A simple way to handle this is to count how many digits were before the cursor in the new text
    // and then place the cursor after that many digits in the formatted text, accounting for commas.
    int cursorPosition = newValue.selection.end;
    int digitsBeforeCursor = newValue.text.substring(0, cursorPosition).replaceAll(RegExp(r'[^0-9.]'), '').length;
    
    int newSelectionIndex = 0;
    int digitsCount = 0;
    for (int i = 0; i < formattedText.length; i++) {
      if (RegExp(r'[0-9.]').hasMatch(formattedText[i])) {
        digitsCount++;
      }
      newSelectionIndex = i + 1;
      if (digitsCount >= digitsBeforeCursor) {
        break;
      }
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: newSelectionIndex),
    );
  }
}

