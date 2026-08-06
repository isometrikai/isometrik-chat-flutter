import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/src/res/l10n/chat_locale_en.dart';
import 'package:isometrik_chat_flutter/src/res/l10n/chat_locale_fr.dart';
import 'package:isometrik_chat_flutter/src/res/l10n/chat_locale_pt.dart';

/// SDK UI localization (titles / labels / dialogs). Does **not** translate
/// chat message bodies from the server.
///
/// Built-in packs: `en` (fallback), `fr`, `pt`.
///
/// Host app should call [setLocale] when the user changes language in settings:
/// ```dart
/// IsmChatL10n.setLocale(const Locale('fr'));
/// // or: IsmChat.i.setLocale(const Locale('fr'));
/// ```
class IsmChatL10n {
  IsmChatL10n._();

  static Locale _locale = const Locale('en');
  static Map<String, String> _pack = kIsmChatLocaleEn;

  /// Bumps when locale changes so GetX `Obx` listeners can rebuild.
  static final RxInt revision = 0.obs;

  static Locale get locale => _locale;

  /// Language codes the SDK ships packs for (`en`, `fr`, `pt`).
  static const supportedLanguageCodes = ['en', 'fr', 'pt'];

  /// Resolve a UI string. Falls back to English, then the [key] itself.
  static String get(String key) =>
      _pack[key] ?? kIsmChatLocaleEn[key] ?? key;

  /// Switch SDK UI language. Prefer language code: `fr`, `pt`, `en`.
  ///
  /// Unknown languages fall back to English. Triggers [revision] and
  /// refreshes GetX widgets currently on screen.
  static void setLocale(Locale locale) {
    final next = _normalize(locale);
    final nextPack = _resolvePack(next);
    if (_locale.languageCode == next.languageCode &&
        identical(_pack, nextPack)) {
      return;
    }
    _locale = next;
    _pack = nextPack;
    revision.value++;
    // Rebuild open GetX views so titles/labels pick up the new pack.
    Get.forceAppUpdate();
  }

  static Locale _normalize(Locale locale) {
    final code = locale.languageCode.toLowerCase();
    if (code == 'pt' || code == 'fr' || code == 'en') {
      return Locale(code, locale.countryCode);
    }
    return locale;
  }

  static Map<String, String> _resolvePack(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'fr':
        return kIsmChatLocaleFr;
      case 'pt':
        return kIsmChatLocalePt;
      case 'en':
      default:
        return kIsmChatLocaleEn;
    }
  }
}
