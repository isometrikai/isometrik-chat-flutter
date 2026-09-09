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
///
/// Packs are the shared `const` maps in `chat_locale_*.dart` — do not mutate
/// them; [setLocale] only re-points [_pack] at another const map.
///
/// Unsupported locales always fall back to English so [locale] matches the
/// pack actually shown (avoids “German locale + English strings” mismatch).
class IsmChatL10n {
  IsmChatL10n._();

  static Locale _locale = const Locale('en');
  static Map<String, String> _pack = kIsmChatLocaleEn;

  /// Bumps when locale changes so GetX `Obx` listeners can rebuild.
  static final RxInt revision = 0.obs;

  static Locale get locale => _locale;

  /// Language codes the SDK ships packs for (`en`, `fr`, `pt`).
  static const supportedLanguageCodes = ['en', 'fr', 'pt'];

  /// Default when the host passes an empty or unsupported [Locale].
  static const Locale fallbackLocale = Locale('en');

  /// Whether [locale] maps to a built-in pack (`en` / `fr` / `pt`).
  ///
  /// Reuse this before updating host [MaterialApp.locale] so app + SDK agree.
  static bool isSupportedLocale(Locale locale) {
    final code = locale.languageCode.toLowerCase().trim();
    return code.isNotEmpty && supportedLanguageCodes.contains(code);
  }

  /// Resolve a UI string. Falls back to English, then the [key] itself.
  static String get(String key) =>
      _pack[key] ?? kIsmChatLocaleEn[key] ?? key;

  /// Switch SDK UI language. Prefer language code: `fr`, `pt`, `en`.
  ///
  /// Unsupported / empty language codes fall back to [fallbackLocale].
  /// Triggers [revision] and refreshes GetX widgets currently on screen.
  static void setLocale(Locale locale) {
    final next = isSupportedLocale(locale)
        ? _normalize(locale)
        : fallbackLocale;
    final nextPack = _resolvePack(next);
    // Use Map.== (not identical): safer if packs are ever wrapped/copied, and
    // avoids skipping a needed update when references differ but content matches.
    // Also compare country so Locale('en','US') → Locale('en','GB') is applied.
    if (_locale.languageCode == next.languageCode &&
        _locale.countryCode == next.countryCode &&
        _pack == nextPack) {
      return;
    }
    _locale = next;
    _pack = nextPack;
    revision.value++;
    // Rebuild open GetX views so titles/labels pick up the new pack.
    Get.forceAppUpdate();
  }

  /// Canonical language + optional country (never empty-string country).
  /// Caller must pass a supported locale (see [isSupportedLocale]).
  static Locale _normalize(Locale locale) {
    final code = locale.languageCode.toLowerCase().trim();
    final country = _normalizeCountryCode(locale.countryCode);
    return country == null ? Locale(code) : Locale(code, country);
  }

  /// Flutter treats `countryCode: ''` poorly vs `null`; normalize empty → null.
  static String? _normalizeCountryCode(String? countryCode) {
    if (countryCode == null) return null;
    final trimmed = countryCode.trim();
    return trimmed.isEmpty ? null : trimmed;
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
