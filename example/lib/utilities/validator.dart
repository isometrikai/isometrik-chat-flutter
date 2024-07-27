import 'package:chat_component_example/res/strings.dart';
import 'package:get/get.dart';

class AppValidator {
  const AppValidator._();

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.required;
    }
    if (!GetUtils.isEmail(value)) {
      return '${Strings.invalid} ${Strings.email}';
    }
    return null;
  }

  static String? userName(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.required;
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return Strings.required;
    }
    if (value.length < 8) {
      return Strings.passwordMustContain(Strings.lengthCharacters);
    }
    if (!value.contains(RegExp('[a-z]'))) {
      return Strings.passwordMustContain(Strings.lowercase);
    }
    if (!value.contains(RegExp('[A-Z]'))) {
      return Strings.passwordMustContain(Strings.uppercase);
    }
    if (!value.contains(RegExp('[0-9]'))) {
      return Strings.passwordMustContain(Strings.number);
    }
    // This Regex is to match special symbols
    if (!value.contains(RegExp('[^((0-9)|(a-z)|(A-Z)|)]'))) {
      return Strings.passwordMustContain(Strings.symbol);
    }
    return null;
  }
}
