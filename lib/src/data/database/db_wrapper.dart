import 'dart:io';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Create this in the apps main function.

typedef IsmChatMessageBoxType = List<String>;
typedef IsmChatConversationTypeMap = String;

class IsmChatDBWrapper {
  IsmChatDBWrapper._create(this.collection);

  /// The Store of this presenter.
  late final BoxCollection collection;

  static const String _userBox = 'user';
  static const String _conversationBox = 'conversation';
  static const String _pendingBox = 'pending';

  /// A Box of user Details.
  late final CollectionBox<IsmChatConversationTypeMap> userDetailsBox;

  /// A Box of Conversation model
  late final CollectionBox<IsmChatConversationTypeMap> chatConversationBox;

  /// A Box of Pending message.
  late final CollectionBox<IsmChatMessageBoxType> pendingMessageBox;

  Future<void> _createBox() async {
    var data = await Future.wait<dynamic>([
      Future.wait([
        collection.openBox<IsmChatConversationTypeMap>(_userBox),
        collection.openBox<IsmChatConversationTypeMap>(_conversationBox),
      ]),
      Future.wait([
        collection.openBox<IsmChatMessageBoxType>(_pendingBox),
      ]),
    ]);
    var boxes = data[0] as List<CollectionBox<IsmChatConversationTypeMap>>;
    var boxes2 = data[1] as List<CollectionBox<IsmChatMessageBoxType>>;
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
      mqttController.mqttHelper.unsubscribeTopics(
          [mqttController.messageTopic, mqttController.statusTopic]);
      mqttController.mqttHelper.disconnect();
    }
    await clearChatLocalDb();
    IsmChatLog.success('[DELETED] - All entries are removed from database');
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
      conversation = conversation.copyWith(messages: []);
      await saveConversation(conversation: conversation);
    }
    if (Get.isRegistered<IsmChatPageController>()) {
      await Get.find<IsmChatPageController>().getMessagesFromDB(conversationId);
    }
  }

  Future<List<IsmChatConversationModel>> getAllConversations() async {
    var keys = await chatConversationBox.getAllKeys();
    var conversations = await chatConversationBox.getAll(keys);

    if (conversations.isEmpty) {
      return [];
    }

    return conversations
        .map((e) => IsmChatConversationModel.fromJson(e!))
        .toList();
  }

  Future<List<IsmChatMessageModel>> getAllPendingMessages() async {
    var keys = await pendingMessageBox.getAllKeys();
    var pendingMessages = await pendingMessageBox.getAll(keys);

    if (pendingMessages.isEmpty) {
      return [];
    }

    var allPendingMessage = pendingMessages.merge();
    return allPendingMessage.map(IsmChatMessageModel.fromJson).toList();
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
    List<String>? listMap;

    switch (dbBox) {
      case IsmChatDbBox.main:
        map = await chatConversationBox.get(conversationId);
        break;
      case IsmChatDbBox.pending:
        listMap = await pendingMessageBox.get(conversationId);
        break;
    }

    if (dbBox == IsmChatDbBox.main) {
      if (map == null) {
        return null;
      }

      return IsmChatConversationModel.fromJson(map);
    }
    if (listMap == null || listMap.isEmpty) {
      return null;
    }

    conversations = IsmChatConversationModel(
      conversationId: conversationId,
      messages: listMap.map(IsmChatMessageModel.fromJson).toList(),
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
              conversation.messages?.isEmpty == true
                  ? []
                  : conversation.messages?.map((e) => e.toJson()).toList() ??
                      []);
          break;
      }
      return true;
    } catch (e, st) {
      IsmChatLog.error('$e $st');
      return false;
    }
  }

  Future<List<IsmChatMessageModel>?> getMessage(String conversationId,
      [IsmChatDbBox dbBox = IsmChatDbBox.main]) async {
    if (conversationId.isEmpty) {
      return null;
    }
    List<IsmChatMessageModel>? messgges;
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
        (message.messageId!.trim().isEmpty &&
            message.conversationId!.trim().isEmpty)) {
      return;
    }

    switch (dbBox) {
      case IsmChatDbBox.main:
        var conversation = await getConversation(
            conversationId: message.conversationId, dbBox: dbBox);

        conversation?.messages?.add(message);
        await saveConversation(conversation: conversation!, dbBox: dbBox);
        break;
      case IsmChatDbBox.pending:
        var conversation = await getConversation(
            conversationId: message.conversationId, dbBox: dbBox);

        if (conversation == null) {
          var pendingConversation = IsmChatConversationModel(
              conversationId: message.conversationId, messages: [message]);
          await saveConversation(
              conversation: pendingConversation, dbBox: dbBox);
          return;
        }
        conversation.messages?.add(message);

        await saveConversation(conversation: conversation, dbBox: dbBox);
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
          conversationModel.conversationId!,
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
        );

        await saveConversation(conversation: conversation);
      }
    } catch (e, st) {
      IsmChatLog.error('$e \n$st');
    }
  }

  Future<void> removePendingMessage(
    String conversationId,
    List<IsmChatMessageModel> messages, [
    IsmChatDbBox dbBox = IsmChatDbBox.pending,
  ]) async {
    if (dbBox == IsmChatDbBox.pending) {
      var pendingMessge = await getConversation(
        conversationId: conversationId,
        dbBox: dbBox,
      );

      if (pendingMessge != null) {
        var pendingMessages = pendingMessge.messages!;
        for (var x in messages) {
          pendingMessages.removeWhere((e) => e.sentAt == x.sentAt);
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
        var forwardMessages = forwardMessge.messages!;
        for (var x in messages) {
          forwardMessages.removeWhere((e) => e.sentAt == x.sentAt);
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
          await chatConversationBox.delete(conversationId);
        }
        break;
    }
  }
}
