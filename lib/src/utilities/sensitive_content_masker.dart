import 'package:isometrik_chat_flutter/src/models/meta_data_model.dart';

/// Masks emails, phone numbers, and social profile URLs in message text.
///
/// **Reuse:** Call [mask] / [applyIfEnabled] from any send path that needs the
/// same privacy rules. Keep [localUnmaskedBodyKey] only in local DB / pending
/// meta — strip it with [stripLocalUnmaskedFromMeta] before API payloads.
///
/// Expected formats (asterisk count matches hidden length):
/// - `nilpatel@gmail.com` → `********@gmail.com`
/// - `9876543210` → `******3210`
/// - `+91 9876543210` (space) → `+91 ******3210` (last 4 of national number)
/// - `+919876543210` (no space) → `+9198******10` (first 4 + last 2 digits)
/// - `instagram.com/nilpatel` → `instagram.com/********`
/// - `facebook.com/nilpatel` → `facebook.com/********`
/// - `x.com/nilpatel` → `x.com/********`
/// - `linkedin.com/in/nilpatel` → `linkedin.com/in/********`
class IsmChatSensitiveContentMasker {
  IsmChatSensitiveContentMasker._();

  /// Local-only meta key holding the original body for pending retries / API.
  /// Never leave this on outbound API meta payloads.
  static const String localUnmaskedBodyKey = '__ismLocalUnmaskedBody';

  /// Social profile URLs (optional scheme / www).
  static final RegExp _socialRegExp = RegExp(
    r'((?:https?:\/\/)?(?:www\.)?)'
    r'(?:'
    r'(instagram\.com|facebook\.com|x\.com|twitter\.com)\/([A-Za-z0-9._]+)'
    r'|'
    r'(linkedin\.com)\/in\/([A-Za-z0-9._-]+)'
    r')',
    caseSensitive: false,
  );

  static final RegExp _emailRegExp = RegExp(
    r'\b([A-Z0-9._%+-]+)@([A-Z0-9.-]+\.[A-Z]{2,})\b',
    caseSensitive: false,
  );

  /// `+91 9876543210` / `+91-9876543210` — space or hyphen between code and number.
  static final RegExp _phonePlusWithSeparatorRegExp = RegExp(
    r'(\+\d{1,3})([\s\-]+)(\d{9,13})\b',
  );

  /// `+919876543210` — `+` with digits and no separator.
  static final RegExp _phonePlusContinuousRegExp = RegExp(
    r'\+(\d{10,15})\b',
  );

  /// Bare national / long numbers (9–13 digits).
  static final RegExp _phonePlainRegExp = RegExp(r'(?<![\d+])(\d{9,13})\b');

  /// Applies masking when [enabled] is true; otherwise returns [input] unchanged.
  static String applyIfEnabled(String input, {required bool enabled}) {
    if (!enabled || input.isEmpty) return input;
    return mask(input);
  }

  /// Masks all supported sensitive patterns in [input].
  static String mask(String input) {
    if (input.isEmpty) return input;

    var result = input;

    result = result.replaceAllMapped(_socialRegExp, (match) {
      final prefix = match.group(1) ?? '';
      final host = match.group(2) ?? match.group(4) ?? '';
      final user = match.group(3) ?? match.group(5) ?? '';
      if (user.isEmpty || host.isEmpty) return match.group(0) ?? '';
      final stars = '*' * user.length;
      final hostLower = host.toLowerCase();
      if (hostLower == 'linkedin.com') {
        return '${prefix}linkedin.com/in/$stars';
      }
      return '$prefix$host/$stars';
    });

    result = result.replaceAllMapped(_emailRegExp, (match) {
      final local = match.group(1) ?? '';
      final domain = match.group(2) ?? '';
      if (local.isEmpty || domain.isEmpty) return match.group(0) ?? '';
      return '${'*' * local.length}@$domain';
    });

    // Spaced / hyphenated country code: keep code + separator, mask national (last 4).
    result = result.replaceAllMapped(_phonePlusWithSeparatorRegExp, (match) {
      final code = match.group(1) ?? '';
      final sep = match.group(2) ?? ' ';
      final number = match.group(3) ?? '';
      if (number.isEmpty) return match.group(0) ?? '';
      return '$code$sep${_maskPhoneKeepLast4(number)}';
    });

    // Continuous `+9198…`: show first 4 digits + last 2 digits.
    result = result.replaceAllMapped(_phonePlusContinuousRegExp, (match) {
      final digits = match.group(1) ?? '';
      if (digits.isEmpty) return match.group(0) ?? '';
      return '+${_maskPhoneKeepFirst4Last2(digits)}';
    });

    result = result.replaceAllMapped(_phonePlainRegExp, (match) {
      final number = match.group(1) ?? '';
      return _maskPhoneKeepLast4(number);
    });

    return result;
  }

  /// `9876543210` → `******3210` (hide all but last 4).
  static String _maskPhoneKeepLast4(String digits) {
    if (digits.length <= 4) return '*' * digits.length;
    return '${'*' * (digits.length - 4)}${digits.substring(digits.length - 4)}';
  }

  /// `919876543210` → `9198******10` (keep first 4 + last 2).
  static String _maskPhoneKeepFirst4Last2(String digits) {
    if (digits.length <= 6) {
      // Too short to split meaningfully — still hide the middle when possible.
      if (digits.length <= 2) return '*' * digits.length;
      final last2 = digits.substring(digits.length - 2);
      final headLen = digits.length > 4 ? 4 : digits.length - 2;
      final head = digits.substring(0, headLen);
      final middleLen = digits.length - headLen - 2;
      return '$head${'*' * (middleLen > 0 ? middleLen : 0)}$last2';
    }
    final head = digits.substring(0, 4);
    final tail = digits.substring(digits.length - 2);
    final middleLen = digits.length - 6;
    return '$head${'*' * middleLen}$tail';
  }

  /// Body to send to the backend: prefer local unmasked original when present.
  static String resolveApiBody({
    required String storedBody,
    IsmChatMetaData? metaData,
  }) {
    final original =
        metaData?.customMetaData?[localUnmaskedBodyKey]?.toString();
    if (original != null && original.isNotEmpty) return original;
    return storedBody;
  }

  /// Meta for API / push — drops local-only unmasked body key.
  static IsmChatMetaData? stripLocalUnmaskedFromMeta(IsmChatMetaData? meta) {
    if (meta == null) return null;
    final custom = meta.customMetaData;
    if (custom == null || !custom.containsKey(localUnmaskedBodyKey)) {
      return meta;
    }
    final cleaned = Map<String, dynamic>.from(custom)
      ..remove(localUnmaskedBodyKey);
    return meta.copyWith(
      customMetaData: cleaned.isEmpty ? {} : cleaned,
    );
  }

  /// Builds meta that keeps original text for pending retry (local DB only).
  static IsmChatMetaData attachLocalUnmasked({
    required IsmChatMetaData? meta,
    required String originalBody,
  }) {
    final base = meta ?? IsmChatMetaData();
    final custom = Map<String, dynamic>.from(base.customMetaData ?? {});
    custom[localUnmaskedBodyKey] = originalBody;
    return base.copyWith(customMetaData: custom);
  }
}
