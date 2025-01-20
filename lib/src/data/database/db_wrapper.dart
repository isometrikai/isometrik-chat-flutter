import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Create this in the apps main function.
class IsmChatDBWrapper {
  IsmChatDBWrapper._create(this.collection);

  /// The Store of this presenter.
  late final BoxCollection collection;

  static const String _userBox = 'user';
  static const String _conversationBox = 'conversation';
  static const String _pendingBox = 'pending';

  /// A Box of user Details.
  late final CollectionBox<IsmChatConversationMap> userDetailsBox;

  /// A Box of Conversation model
  late final CollectionBox<IsmChatConversationMap> chatConversationBox;

  /// A Box of Pending message.
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

  /// Create an instance of HiveBox to use throughout the presenter.
  static Future<IsmChatDBWrapper> create([String? databaseName]) async {
    var dbName = databaseName ?? IsmChatConfig.dbName;
    BoxCollection? collection;
    Directory? directory;
    if (!kIsWeb) {
      directory = await getApplicationDocumentsDirectory();
      collection = await BoxCollection.open(
        dbName,
        {
          _userBox,
          _conversationBox,
          _pendingBox,
        },
        path: '${directory.path}/$dbName',
      );
    } else {
      collection = await BoxCollection.open(
        dbName,
        {
          _userBox,
          _conversationBox,
          _pendingBox,
        },
      );
    }
    if (!kIsWeb) {
      IsmChatLog.success(
          '[CREATED] - Hive databse at ${directory?.path}/$dbName');
    }
    var instance = IsmChatDBWrapper._create(collection);
    await instance._createBox();
    return instance;
  }

  Map<String, List<IsmChatMessageModel>> pendingMessages = {};

  Map<String, List<IsmChatMessageModel>> forwardMessages = {};

  /// delete chat object box
  Future<void> deleteChatLocalDb() async {
    if (!IsmChatConfig.shouldSetupMqtt) {
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
    var conversation = await getConversation(conversationId: conversationId);
    if (conversation != null) {
      conversation = conversation.copyWith(messages: {});
      await saveConversation(conversation: conversation);
    }
    if (Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.tag)) {
      await Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
          .getMessagesFromDB(conversationId);
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

  Future<IsmChatConversationModel?> getConversation({
    String? conversationId,
    IsmChatDbBox dbBox = IsmChatDbBox.main,
  }) async {
    if (conversationId == null || conversationId.trim().isEmpty) {
      return null;
    }
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
            await getConversation(conversationId: conversationId, dbBox: dbBox);
        if (mainConversation != null) {
          messgges = mainConversation.messages;
        }
        break;
      case IsmChatDbBox.pending:
        var pendingConversation =
            await getConversation(conversationId: conversationId, dbBox: dbBox);
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
    var messageMap = {
      '${message.metaData?.messageSentAt ?? DateTime.now().millisecondsSinceEpoch}':
          message
    };
    switch (dbBox) {
      case IsmChatDbBox.main:
        var conversationMain = await getConversation(
            conversationId: message.conversationId, dbBox: dbBox);
        if (conversationMain == null) return;
        final mesasges = conversationMain.messages ?? {};
        mesasges.addEntries(messageMap.entries);
        conversationMain = conversationMain.copyWith(
          messages: mesasges,
        );
        await saveConversation(conversation: conversationMain, dbBox: dbBox);
        break;
      case IsmChatDbBox.pending:
        var conversationPending = await getConversation(
            conversationId: message.conversationId, dbBox: dbBox);
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
        var conversation = await getConversation(
            conversationId: conversationModel.conversationId);
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
        conversationId: conversationId,
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
        conversationId: conversationId,
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
        var conversation =
            await getConversation(conversationId: conversationId, dbBox: dbBox);

        if (conversation != null) {
          await chatConversationBox.delete(conversationId);
        }

        break;
      case IsmChatDbBox.pending:
        var pendingConversation =
            await getConversation(conversationId: conversationId, dbBox: dbBox);
        if (pendingConversation != null) {
          await pendingMessageBox.delete(conversationId);
        }
        break;
    }
  }
}
