import 'package:get/get.dart';

class TranslationKeys {
  const TranslationKeys._();

  static const String login = 'Login';
  static const String signUp = 'Sign up';
  static const String register = 'Register';
  static const String required = 'Required';
  static const String email = 'Email';
  static const String userName = 'User name';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String invalid = 'Invalid';
  static const String mustContain = 'Must contain';
  static const String number = 'Number';
  static const String lowercase = 'Lowercase';
  static const String uppercase = 'Uppercase';
  static const String symbol = 'symbol';
  static const String lengthCharacters = 'lengthCharacters';
  static const String inviteToChat = 'Invite to';
}

class Strings {
  const Strings._();

  static const String name = 'ChatApp';
  static String login = TranslationKeys.login.tr;
  static String signUp = TranslationKeys.signUp.tr;
  static String userName = TranslationKeys.userName.tr;
  static String register = TranslationKeys.register.tr;
  static String required = TranslationKeys.required.tr;
  static String email = TranslationKeys.email.tr;
  static String password = TranslationKeys.password.tr;
  static String confirmPassword = TranslationKeys.confirmPassword;
  static String invalid = TranslationKeys.invalid.tr;
  static String number = TranslationKeys.number.tr;
  static String lowercase = TranslationKeys.lowercase.tr;
  static String uppercase = TranslationKeys.uppercase.tr;
  static String symbol = TranslationKeys.symbol.tr;
  static String lengthCharacters = TranslationKeys.lengthCharacters.tr;
  static String inviteToChat = TranslationKeys.inviteToChat.tr;

  static String passwordMustContain(String character) =>
      TranslationKeys.mustContain.trParams({'character': character});
}
