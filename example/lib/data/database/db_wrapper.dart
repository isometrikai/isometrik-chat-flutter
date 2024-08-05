import 'dart:io';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Create this in the apps main function.

class DBWrapper {
  DBWrapper._create(this.collection);

  /// The Store of this presenter.
  late final BoxCollection collection;

  static const String _userBox = 'userData';

  /// A Box of user Details.
  late final CollectionBox<String> userDetailsBox;

  Future<void> _createBox() async {
    var data = await collection.openBox<String>(_userBox);
    var boxes = data;
    userDetailsBox = boxes;
  }

  static Future<DBWrapper> create([String? databaseName]) async {
    var dbName = databaseName ?? 'isometrik_flutter_chat_example';
    Directory? directory;

    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
    }
    final collection = await BoxCollection.open(
      dbName,
      {
        _userBox,
      },
      path: directory != null ? '${directory.path}/$dbName' : null,
    );

    var instance = DBWrapper._create(collection);
    await instance._createBox();
    return instance;
  }

  /// delete chat object box
  Future<void> deleteChatLocalDb() async {
    await userDetailsBox.clear();
    IsmChatLog.success('[CLEARED] - All entries are removed from database');
  }
}
