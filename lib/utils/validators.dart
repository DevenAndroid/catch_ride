import 'package:form_field_validator/form_field_validator.dart';

class Validations {
  static final phoneValidator = MultiValidator([
    RequiredValidator(errorText: 'Phone number is required'),
    PatternValidator(
      r'^[0-9]+$',
      errorText: 'Phone number must contain only digits',
    ),
    MinLengthValidator(10, errorText: 'Phone number must be exactly 10 digits'),
    MaxLengthValidator(10, errorText: 'Phone number must be exactly 10 digits'),
  ]);

  static final requiredValidator = RequiredValidator(
    errorText: 'This field is required',
  );

  static final urlValidator = PatternValidator(
    r'^(https?:\/\/)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}([\/a-zA-Z0-9#?%=&._-]*)*$',
    errorText: 'Please enter a valid URL',
  );

  static final facebookValidator = PatternValidator(
    r'^(https?:\/\/)?(www\.)?(facebook\.com|fb\.com)\/.+$',
    errorText: 'Please enter a valid Facebook URL',
  );

  static final instagramValidator = PatternValidator(
    r'^@?([a-zA-Z0-9._]{1,30})$',
    errorText: 'Please enter a valid Instagram username (e.g. @username)',
  );
}
