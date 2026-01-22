import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Database wrapper for local data storage.
///
/// This class provides an abstraction layer over the Hive database (BoxCollection)
/// for storing chat data locally. It manages three main data boxes:
/// - User details box
/// - Conversation box
/// - Pending messages box
///
/// **Architecture:**
/// - Uses Hive (BoxCollection) for local storage
/// - Provides type-safe access to stored data
/// - Handles database initialization and box creation
///
/// **Usage:**
/// ```dart
/// // Create database instance (typically in app initialization)
/// final db = await IsmChatDBWrapper.create('chat_db');
///
/// // Save conversation
/// await db.saveConversation(conversation);
///
/// // Get conversations
/// final conversations = await db.getConversations();
/// ```
///
/// **Data Boxes:**
/// - `_userBox`: Stores user details
/// - `_conversationBox`: Stores conversation data
/// - `_pendingBox`: Stores pending messages (messages queued for sending)
///
/// **See Also:**
/// - [MODULE_DATA.md] - Data module documentation
/// - [ARCHITECTURE.md] - Architecture documentation
///
/// **Note:** Create this instance in the app's main function or during
/// SDK initialization to ensure the database is ready before use.
class IsmChatDBWrapper {
  /// Private constructor for creating a database wrapper instance.
  ///
  /// **Parameters:**
  /// - `collection`: The BoxCollection instance from Hive.
  ///
  /// **Note:** Use [create] factory method to create instances.
  IsmChatDBWrapper._create(this.collection);

  /// The Hive BoxCollection instance for this database.
  ///
  /// This collection manages all the data boxes (user, conversation, pending).
  /// It's initialized when the database is created.
  late final BoxCollection collection;

  /// Box name constant for user details storage.
  static const String _userBox = 'user';

  /// Box name constant for conversation storage.
  static const String _conversationBox = 'conversation';

  /// Box name constant for pending messages storage.
  static const String _pendingBox = 'pending';

  /// Box for storing user details.
  ///
  /// This box stores user information including profile data, online status,
  /// and other user-related metadata.
  late final CollectionBox<IsmChatConversationMap> userDetailsBox;

  /// Box for storing conversation data.
  ///
  /// This box stores all conversation information including conversation metadata,
  /// members, and associated messages.
  late final CollectionBox<IsmChatConversationMap> chatConversationBox;

  /// Box for storing pending messages.
  ///
  /// This box stores messages that are queued for sending (e.g., when offline
  /// or when network is unavailable). These messages are sent when connectivity
  /// is restored.
  late final CollectionBox<IsmChatMessageMap> pendingMessageBox;

  Future<void> _createBox() async {
    var data = await Future.wait<dynamic>([
      Future.wait([
        collection.openBox<IsmChatConversationMap>(_userBox),
        collection.openBox<IsmChatConversationMap>(_conversationBox),
      ]),
      Future.wait([
        collection.openBox<IsmChatMessageMap>(_pendingBox),
      ]),
    ]);
    var boxes = data[0] as List<CollectionBox<IsmChatConversationMap>>;
    var boxes2 = data[1] as List<CollectionBox<IsmChatMessageMap>>;
    userDetailsBox = boxes[0];
    chatConversationBox = boxes[1];
    pendingMessageBox = boxes2[0];
  }

  /// Creates a new database wrapper instance.
  ///
  /// This factory method initializes the Hive database and creates all necessary
  /// boxes. It should be called during app initialization (typically in the
  /// main function or SDK initialization).
  ///
  /// **Parameters:**
  /// - `databaseName`: Optional database name. If not provided, uses the default
  ///   name from [IsmChatConfig.dbName].
  ///
  /// **Returns:**
  /// - `Future<IsmChatDBWrapper>`: The initialized database wrapper instance.
  ///
  /// **Example:**
  /// ```dart
  /// final db = await IsmChatDBWrapper.create('my_chat_db');
  /// ```
  ///
  /// **Platform Support:**
  /// - **Web**: Uses IndexedDB via Hive
  /// - **Mobile**: Uses file-based storage via Hive
  ///
  /// **Throws:**
  /// - May throw exceptions if database initialization fails.
  static Future<IsmChatDBWrapper> create([String? databaseName]) async {
    final dbName = databaseName ?? IsmChatConfig.dbName;
    BoxCollection? collection;
    if (kIsWeb) {
      try {
        collection = await BoxCollection.open(
          dbName,
          {
            _userBox,
            _conversationBox,
            _pendingBox,
          },
        );
      } catch (_, __) {
        IsmChatLog.error('IsmChat DB Create Error :- $_', __);
      }
    } else {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$dbName';
        collection = await BoxCollection.open(
          dbName,
          {
            _userBox,
            _conversationBox,
            _pendingBox,
          },
          path: path,
        );
        IsmChatLog.success(
          '[CREATED] - IsmChat databse at $path',
        );
      } catch (_, __) {
        IsmChatLog.error('IsmChat DB Create Error :- $_', __);
      }
    }
    if (collection == null) throw Exception('Error Creating IsmChat Database');
    final instance = IsmChatDBWrapper._create(collection);
    await instance._createBox();
    return instance;
  }

  Map<String, List<IsmChatMessageModel>> pendingMessages = {};

  Map<String, List<IsmChatMessageModel>> forwardMessages = {};

  /// delete chat Hive box
  Future<void> deleteChatLocalDb() async {
    if (IsmChatConfig.shouldSetupMqtt &&
        Get.isRegistered<IsmChatMqttController>()) {
      final mqttController = Get.find<IsmChatMqttController>();
      if (mqttController.connectionState == IsmChatConnectionState.connected) {
        mqttController.mqttHelper
            .unsubscribeTopics(mqttController.subscribedTopics);
        IsmChatLog.success('MQTT Topics Unsubscribed Successfully');
        mqttController.mqttHelper.disconnect();
      }
    }
    await clearChatLocalDb();
  }

  Future<void> clearChatLocalDb() async {
    await userDetailsBox.clear();
    await chatConversationBox.clear();
    await pendingMessageBox.clear();
    IsmChatLog.success('[CLEARED] - All entries are removed from database');
  }

  ///  clear all messages for perticular user
  Future<void> clearAllMessage({required String conversationId}) async {
    var conversation = await getConversation(conversationId);
    if (conversation != null) {
      final messages = conversation.messages?.values.toList() ?? [];
      if (messages.isNotEmpty) {
        final blockedMessage = messages.last;
        final isBlockedMessage =
            blockedMessage.customType == IsmChatCustomMessageType.block;
        conversation = conversation.copyWith(
          metaData: conversation.metaData?.copyWith(
            blockedMessage: isBlockedMessage ? blockedMessage : null,
          ),
        );
      }
      conversation = conversation.copyWith(messages: {});
      await saveConversation(conversation: conversation);
    }
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.getMessagesFromDB(conversationId);
    }
  }

  Future<List<IsmChatConversationModel>> getAllConversations() async {
    var keys = await chatConversationBox.getAllKeys();
    var conversations = await chatConversationBox.getAll(keys);

    if (conversations.isEmpty) {
      return [];
    }

    return conversations
        .map((e) => IsmChatConversationModel.fromJson(e ?? ''))
        .toList();
  }

  Future<IsmChatMessages> getAllPendingMessages() async {
    final keys = await pendingMessageBox.getAllKeys();
    final pendingMessages = await pendingMessageBox.getAll(keys);
    if (pendingMessages.isEmpty) return {};
    if (pendingMessages.first == null) return {};
    return pendingMessages.first?.messageMap ?? {};
  }

  Future<IsmChatConversationModel?> getConversation(
    String conversationId, {
    IsmChatDbBox dbBox = IsmChatDbBox.main,
  }) async {
    if (conversationId.isEmpty) return null;
    IsmChatConversationModel? conversations;
    String? map;
    Map<dynamic, dynamic>? messageMap;
    switch (dbBox) {
      case IsmChatDbBox.main:
        map = await chatConversationBox.get(conversationId);
        break;
      case IsmChatDbBox.pending:
        messageMap = await pendingMessageBox.get(conversationId);
        break;
    }

    if (dbBox == IsmChatDbBox.main) {
      if (map == null) {
        return null;
      }
      return IsmChatConversationModel.fromJson(map);
    }
    if (messageMap == null || messageMap.isEmpty) {
      return null;
    }
    conversations = IsmChatConversationModel(
      conversationId: conversationId,
      messages: {
        for (var entry in messageMap.entries)
          entry.key: IsmChatMessageModel.fromJson(entry.value)
      },
    );
    return conversations;
  }

  Future<bool> saveConversation({
    required IsmChatConversationModel conversation,
    IsmChatDbBox dbBox = IsmChatDbBox.main,
  }) async {
    if (conversation.conversationId == null ||
        conversation.conversationId!.trim().isEmpty) {
      return false;
    }

    try {
      switch (dbBox) {
        case IsmChatDbBox.main:
          await chatConversationBox.put(
                  conversation.conversationId ?? '', conversation.toJson())
              as Map<String, dynamic>?;
          break;
        case IsmChatDbBox.pending:
          await pendingMessageBox.put(
              conversation.conversationId ?? '',
              conversation.messages != null
                  ? {
                      for (var entry in conversation.messages!.entries)
                        entry.key: entry.value.toJson()
                    }
                  : {});
          break;
      }
      return true;
    } catch (e, st) {
      IsmChatLog.error('$e $st');
      return false;
    }
  }

  Future<IsmChatMessages?> getMessage(String conversationId,
      [IsmChatDbBox dbBox = IsmChatDbBox.main]) async {
    if (conversationId.isEmpty) {
      return null;
    }
    Map<String, IsmChatMessageModel>? messgges;
    switch (dbBox) {
      case IsmChatDbBox.main:
        var mainConversation =
            await getConversation(conversationId, dbBox: dbBox);
        if (mainConversation != null) {
          messgges = mainConversation.messages;
        }
        break;
      case IsmChatDbBox.pending:
        var pendingConversation =
            await getConversation(conversationId, dbBox: dbBox);
        if (pendingConversation != null) {
          messgges = pendingConversation.messages;
        }
        break;
    }
    return messgges;
  }

  Future<void> saveMessage(
    IsmChatMessageModel message, [
    IsmChatDbBox dbBox = IsmChatDbBox.main,
  ]) async {
    if ((message.messageId == null && message.conversationId == null) ||
        (message.messageId?.trim().isEmpty == true &&
            message.conversationId?.trim().isEmpty == true)) {
      return;
    }

    var messageMap = {message.key: message};
    switch (dbBox) {
      case IsmChatDbBox.main:
        var conversationMain =
            await getConversation(message.conversationId ?? '', dbBox: dbBox);
        if (conversationMain == null) return;
        final mesasges = conversationMain.messages ?? {};
        mesasges.addEntries(messageMap.entries);
        conversationMain = conversationMain.copyWith(
          messages: mesasges,
        );
        await saveConversation(conversation: conversationMain, dbBox: dbBox);
        break;
      case IsmChatDbBox.pending:
        var conversationPending =
            await getConversation(message.conversationId ?? '', dbBox: dbBox);
        if (conversationPending == null) {
          var pendingConversation = IsmChatConversationModel(
              conversationId: message.conversationId, messages: messageMap);
          await saveConversation(
              conversation: pendingConversation, dbBox: dbBox);
          return;
        }
        final mesasges = conversationPending.messages ?? {};
        mesasges.addEntries(messageMap.entries);
        conversationPending = conversationPending.copyWith(
          messages: mesasges,
        );
        await saveConversation(conversation: conversationPending, dbBox: dbBox);
        break;
    }
  }

  /// Create Db with user
  Future<void> createAndUpdateConversation(
    IsmChatConversationModel conversationModel,
  ) async {
    try {
      var resposne = await getAllConversations();

      if (resposne.isEmpty) {
        await chatConversationBox.put(
          conversationModel.conversationId ?? '',
          conversationModel.toJson(),
        );
      } else {
        var conversation =
            await getConversation(conversationModel.conversationId ?? '');
        if (conversation == null) {
          await saveConversation(conversation: conversationModel);
          return;
        }
        conversation = conversation.copyWith(
          conversationImageUrl: conversationModel.conversationImageUrl,
          conversationTitle: conversationModel.conversationTitle,
          isGroup: conversationModel.isGroup,
          membersCount: conversationModel.membersCount,
          lastMessageDetails: conversationModel.lastMessageDetails,
          messagingDisabled: conversationModel.messagingDisabled,
          unreadMessagesCount: conversationModel.unreadMessagesCount,
          opponentDetails: conversationModel.opponentDetails,
          lastMessageSentAt: conversationModel.lastMessageSentAt,
          config: conversationModel.config,
          metaData: conversationModel.metaData,
          customType: conversationModel.customType,
          members: conversationModel.members,
        );

        await saveConversation(conversation: conversation);
      }
    } catch (e, st) {
      IsmChatLog.error('$e \n$st');
    }
  }

  Future<void> removePendingMessage(
    String conversationId,
    IsmChatMessages messages, [
    IsmChatDbBox dbBox = IsmChatDbBox.pending,
  ]) async {
    if (dbBox == IsmChatDbBox.pending) {
      var pendingMessge = await getConversation(
        conversationId,
        dbBox: dbBox,
      );

      if (pendingMessge != null) {
        var pendingMessages = pendingMessge.messages ?? {};
        for (var x in messages.entries) {
          pendingMessages
              .removeWhere((key, value) => value.sentAt == x.value.sentAt);
        }
        var conversation = IsmChatConversationModel(
            conversationId: conversationId, messages: pendingMessages);
        await saveConversation(conversation: conversation, dbBox: dbBox);
      }
    } else {
      var forwardMessge = await getConversation(
        conversationId,
        dbBox: dbBox,
      );
      if (forwardMessge != null) {
        var forwardMessages = forwardMessge.messages ?? {};
        for (var x in messages.entries) {
          forwardMessages
              .removeWhere((key, value) => value.sentAt == x.value.sentAt);
        }
        var conversation = IsmChatConversationModel(
            conversationId: conversationId, messages: forwardMessages);
        await saveConversation(conversation: conversation, dbBox: dbBox);
      }
    }
  }

  Future<void> removeConversation(String conversationId,
      [IsmChatDbBox dbBox = IsmChatDbBox.main]) async {
    switch (dbBox) {
      case IsmChatDbBox.main:
        var conversation = await getConversation(conversationId, dbBox: dbBox);

        if (conversation != null) {
          await chatConversationBox.delete(conversationId);
        }

        break;
      case IsmChatDbBox.pending:
        var pendingConversation =
            await getConversation(conversationId, dbBox: dbBox);
        if (pendingConversation != null) {
          await pendingMessageBox.delete(conversationId);
        }
        break;
    }
  }
}
