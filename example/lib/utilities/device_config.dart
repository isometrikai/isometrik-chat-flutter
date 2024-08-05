import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class DeviceConfig {
  void init() async {
    _info = DeviceInfoPlugin();
    if (kIsWeb) {
      _webDeviceInfo = await _info.webBrowserInfo;
    } else if (GetPlatform.isAndroid) {
      _androidDeviceInfo = await _info.androidInfo;
    } else if (GetPlatform.isIOS) {
      _iosDeviceInfo = await _info.iosInfo;
    }
  }

  DeviceInfoPlugin _info = DeviceInfoPlugin();

  /// To get android device info
  AndroidDeviceInfo? _androidDeviceInfo;

  /// To get iOS device info
  IosDeviceInfo? _iosDeviceInfo;

  WebBrowserInfo? _webDeviceInfo;

  /// Device id
  String? get deviceId => kIsWeb
      ? _webDeviceInfo?.appVersion!.substring(0, 3)
      : GetPlatform.isAndroid
          ? _androidDeviceInfo?.id
          : _iosDeviceInfo?.identifierForVendor;

  /// Device make brand
  String? get deviceMake => kIsWeb
      ? _webDeviceInfo?.browserName.name
      : GetPlatform.isAndroid
          ? _androidDeviceInfo?.brand
          : 'Apple';

  /// Device Model
  String? get deviceModel => kIsWeb
      ? _webDeviceInfo?.platform
      : GetPlatform.isAndroid
          ? _androidDeviceInfo?.model
          : _iosDeviceInfo?.utsname.machine;

  /// Device is a type of 1 for Android and 2 for iOS
  String get deviceTypeCode => kIsWeb
      ? '3'
      : GetPlatform.isAndroid
          ? '1'
          : '2';

  /// Device OS
  String get deviceOs => kIsWeb
      ? '${_webDeviceInfo?.appVersion}'
      : GetPlatform.isAndroid
          ? '${_androidDeviceInfo?.version.codename}'
          : '${_iosDeviceInfo?.systemVersion}';
}
