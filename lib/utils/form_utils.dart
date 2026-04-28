import 'package:flutter/material.dart';

class FormUtility {
  /// Scrolls to the first FormField that has an error in the given context.
  static void scrollToFirstError(BuildContext context) {
    Element? firstErrorElement;

    void _visit(Element element) {
      if (firstErrorElement != null) return;

      if (element is StatefulElement && element.state is FormFieldState) {
        final state = element.state as FormFieldState;
        if (state.hasError) {
          firstErrorElement = element;
          return;
        }
      }
      element.visitChildren(_visit);
    }

    context.visitChildElements(_visit);

    if (firstErrorElement != null) {
      Scrollable.ensureVisible(
        firstErrorElement!,
        duration: const Duration(milliseconds: 500),
        alignment: 0.2,
        curve: Curves.easeInOut,
      );
    }
  }
}
