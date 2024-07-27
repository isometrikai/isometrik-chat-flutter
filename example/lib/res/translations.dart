import 'package:chat_component_example/res/strings.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          TranslationKeys.login: 'Login',
          TranslationKeys.signUp: 'SignUp',
          TranslationKeys.register: 'Register',
          TranslationKeys.required: '*Required',
          TranslationKeys.email: 'Email',
          TranslationKeys.password: 'Password',
          TranslationKeys.invalid: 'Invalid',
          TranslationKeys.number: 'Number (0-9)',
          TranslationKeys.lowercase: 'Lowercase alphabets (a-z)',
          TranslationKeys.uppercase: 'Uppercase alphabets (A-Z)',
          TranslationKeys.symbol: 'Special symbols (@,\$,! etc)',
          TranslationKeys.lengthCharacters: 'atleast 8 characters',
          TranslationKeys.mustContain: 'Password must contain @character',
          TranslationKeys.inviteToChat: 'Invite to',
        },
      };
}
