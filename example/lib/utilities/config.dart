// ignore_for_file: avoid_setters_without_getters

import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/main.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';

import '../models/models.dart';

class AppConfig {
  const AppConfig._();

  static UserDetailsModel? userDetail;

  /// Locales the example [MaterialApp] and chat SDK packs both support.
  /// Reuse this list anywhere we need the same allow-list (do not duplicate).
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// Fallback when [appLocale] is null, empty, or not in [supportedLocales].
  static const Locale defaultLocale = Locale('en');

  /// Example app + SDK UI language.
  ///
  /// Always kept as a validated entry from [supportedLocales] (see [resolveLocale]).
  /// Driven initially by [Constants.languageCode].
  static Locale appLocale =
      resolveLocale(Locale(Constants.languageCode));

  /// Drives [MaterialApp.locale] rebuilds when language changes after startup.
  /// Prefer [setLocale] / [applyLocale] over assigning [appLocale] alone.
  static final ValueNotifier<Locale> localeListenable =
      ValueNotifier<Locale>(appLocale);

  /// Maps an arbitrary (possibly null/invalid) locale onto [supportedLocales].
  ///
  /// Reusable for MaterialApp, SDK sync, and any future language picker.
  static Locale resolveLocale(Locale? locale) {
    if (locale == null) {
      return defaultLocale;
    }
    final code = locale.languageCode.trim().toLowerCase();
    if (code.isEmpty) {
      return defaultLocale;
    }
    for (final supported in supportedLocales) {
      if (supported.languageCode == code) {
        // Keep country when present (e.g. pt_BR); language code is what we match.
        return Locale(code, locale.countryCode);
      }
    }
    return defaultLocale;
  }

  /// Sets app + SDK locale and notifies [localeListenable] so MaterialApp updates.
  static void setLocale(Locale locale) {
    final next = resolveLocale(locale);
    appLocale = next;
    localeListenable.value = next;
    IsmChat.i.setLocale(next);
  }

  /// Re-applies current [appLocale] (normalized) to the chat SDK and MaterialApp.
  ///
  /// Returns a [Future] so startup can `await` it and avoid the first frame
  /// running with an unapplied / stale locale after async work (e.g. [getUserData]).
  /// Callers that load language prefs should assign [appLocale] first, then await this.
  ///
  /// Safe to call after async init or when config may have been assigned directly.
  static Future<void> applyLocale() async {
    setLocale(appLocale);
  }

  static Future<void> getUserData() async {
    var data = await dbWrapper!.userDetailsBox.get(IsmChatStrings.user);

    if (data == null) {
      return;
    }

    userDetail = UserDetailsModel.fromJson(data);
    // IsmChatLog.success(userDetail?.userToken);
    // IsmChatLog.success(userDetail?.toMap());
  }
}
