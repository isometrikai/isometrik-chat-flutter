library isometrik_chat_flutter;

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_platform_interface.dart';

export 'src/app/app.dart';
export 'src/controllers/controllers.dart';
export 'src/data/data.dart';
export 'src/models/models.dart';
export 'src/repositories/repositories.dart';
export 'src/res/res.dart';
export 'src/utilities/utilities.dart';
export 'src/view_models/view_models.dart';
export 'src/views/views.dart';
export 'src/widgets/widgets.dart';

class IsometrikChat {
  Future<String?> getPlatformVersion() =>
      ChatComponentPlatform.instance.getPlatformVersion();

  static Future<void> initialize({bool useDatabase = true}) async {
    IsmChatConfig.useDatabase = !kIsWeb && useDatabase;
    Get.put(IsmChatDeviceConfig()).init();

    IsmChatConfig.dbWrapper = await IsmChatDBWrapper.create();

    IsmChatConfig.isInitialized = true;
  }
}
