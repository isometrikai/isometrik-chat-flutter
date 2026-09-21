import 'dart:async';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/variables.dart';

/// Calls mixin for IsmChatMqttEventMixin.
///
/// This mixin contains methods for handling one-to-one call events.
mixin IsmChatMqttEventCallsMixin {
  /// Handles a one to one call event.
  ///
  /// * `actionModel`: The one to one call event model to handle
  /// * `payload`: Raw MQTT map. Hang-up Status events (`meetingEnded*`) are
  ///   not a new chat row — reuse this to patch the existing bubble so
  ///   "Ringing" does not stick after `meetingEndedDueToNoUserPublishing`.
  void handleOneToOneCall(
    IsmChatMqttActionModel actionModel, {
    Map<String, dynamic>? payload,
  }) async {
    final self = this;
    if (self is IsmChatMqttEventUtilitiesMixin &&
        self is IsmChatMqttEventVariablesMixin) {
      final utils = self as IsmChatMqttEventUtilitiesMixin;
      final vars = self as IsmChatMqttEventVariablesMixin;
      if (vars.messageId == actionModel.sentAt.toString()) return;
      vars.messageId = actionModel.sentAt.toString();

      final actionName = actionModel.action.toString();
      final meetingId = actionModel.meetingId ??
          payload?['meetingId']?.toString() ??
          payload?['meeting_id']?.toString();
      // Ended MQTT events (e.g. meetingEndedDueToNoUserPublishing) are often
      // not a new chat row. Persist + reload so "Ringing" / Join does not
      // stick after hang-up. Do not refetch history: API may still return
      // meetingCreated and overwrite the ended action.
      if (actionName.startsWith('meetingEnded')) {
        final endedMessage = _endedCallMessageFrom(
          actionModel: actionModel,
          payload: payload,
        );
        await _persistEndedCallMessage(endedMessage);
        IsmChatCallMeetingLiveness.markEnded(meetingId);
        _refreshLiveCallTiles(meetingId);
        return;
      }

      if (actionName == IsmChatActionEvents.joinRequestAccept.name) {
        IsmChatCallMeetingLiveness.markConnected(meetingId);
        _refreshLiveCallTiles(meetingId);
        return;
      }

      if (actionName == IsmChatActionEvents.meetingCreated.name) {
        IsmChatCallMeetingLiveness.markLive(meetingId);
        _refreshLiveCallTiles(meetingId);
      }

      if (!IsmChatUtility.conversationControllerRegistered) {
        return;
      }
      final isInitiator = utils.isSenderMe(actionModel.initiatorId);
      if (!isInitiator) {
        unawaited(IsmChatUtility.conversationController.getChatConversations());
      }
      if (!IsmChatUtility.chatPageControllerRegistered) {
        return;
      }
      final controller = IsmChatUtility.chatPageController;
      if (controller.conversation?.conversationId ==
              actionModel.conversationId &&
          controller.messages.isNotEmpty) {
        await controller.getMessagesFromAPI(
          lastMessageTimestamp: controller.messages.last.sentAt,
        );
      }
    }
  }

  /// Build a mergeable call bubble from the Status hang-up payload.
  ///
  /// Reuse: [IsmChatMessageModel.fromMap] already parses `callDurations`,
  /// `meetingId`, `customType`. Copy root `missedByMembers` into
  /// `metaData.customMetaData` so chat tiles can read them (backend sends
  /// that list on the payload root, not inside metaData).
  IsmChatMessageModel _endedCallMessageFrom({
    required IsmChatMqttActionModel actionModel,
    Map<String, dynamic>? payload,
  }) {
    final actionName = actionModel.action.toString();
    if (payload != null && payload.isNotEmpty) {
      try {
        var message = IsmChatMessageModel.fromMap(payload);
        message = _withCallEndCustomMeta(message, payload);
        final durations = CallDuration.listFrom(payload['callDurations']);
        return message.copyWith(
          action: actionName,
          conversationId: _firstNonEmpty(
            message.conversationId,
            actionModel.conversationId,
          ),
          meetingId: _firstNonEmpty(message.meetingId, actionModel.meetingId),
          customType: message.customType ?? actionModel.customType,
          callDurations:
              durations.isNotEmpty ? durations : message.callDurations,
          audioOnly: payload['audioOnly'] == true ? true : message.audioOnly,
        );
      } catch (e, st) {
        IsmChatLog.error('Failed to parse meetingEnded payload: $e', st);
      }
      final fallback = IsmChatMessageModel(
        body: '',
        sentAt: actionModel.sentAt,
        conversationId: actionModel.conversationId ??
            payload['conversationId']?.toString() ??
            '',
        meetingId: _firstNonEmpty(
              actionModel.meetingId,
              payload['meetingId']?.toString() ??
                  payload['meeting_id']?.toString(),
            ) ??
            '',
        action: actionName,
        customType: actionModel.customType ??
            (payload['customType'] != null
                ? IsmChatCustomMessageType.fromMap(payload['customType'])
                : IsmChatCustomMessageType.oneToOneCall),
        sentByMe: false,
        callDurations: CallDuration.listFrom(payload['callDurations']),
        initiatorId: actionModel.initiatorId ??
            payload['initiatorId']?.toString() ??
            '',
        audioOnly: payload['audioOnly'] == true,
      );
      return _withCallEndCustomMeta(fallback, payload);
    }
    return IsmChatMessageModel(
      body: '',
      sentAt: actionModel.sentAt,
      conversationId: actionModel.conversationId ?? '',
      meetingId: actionModel.meetingId ?? '',
      action: actionName,
      customType:
          actionModel.customType ?? IsmChatCustomMessageType.oneToOneCall,
      sentByMe: false,
    );
  }

  IsmChatMessageModel _withCallEndCustomMeta(
    IsmChatMessageModel message,
    Map<String, dynamic> payload,
  ) {
    final custom = Map<String, dynamic>.from(
      message.metaData?.customMetaData ?? const <String, dynamic>{},
    );
    final missed = payload['missedByMembers'];
    if (missed is List) {
      custom['missedByMembers'] = missed;
    }
    final action = payload['action'];
    if (action != null) {
      custom['action'] = action.toString();
    }
    final durations = CallDuration.listFrom(payload['callDurations']);
    if (durations.isNotEmpty) {
      custom['callDurations'] = durations.map((e) => e.toMap()).toList();
    }
    if (custom.isEmpty) return message;
    final meta = message.metaData ?? IsmChatMetaData();
    return message.copyWith(
      metaData: meta.copyWith(customMetaData: custom),
      callDurations:
          durations.isNotEmpty ? durations : message.callDurations,
    );
  }

  /// Persist hang-up onto the existing [meetingId] row, then refresh open chat.
  ///
  /// Patch the open bubble **before** Hive so `meetingEndedDueToNoUserPublishing`
  /// with `callDurations` shows `mm:ss` immediately (DB reload can lag).
  Future<void> _persistEndedCallMessage(IsmChatMessageModel message) async {
    final conversationId = message.conversationId ?? '';
    if (conversationId.isEmpty) return;

    _applyEndedCallToOpenChat(message);
    _applyEndedCallToConversationList(message);
    IsmChatCallMeetingLiveness.markEnded(message.meetingId);
    await IsmChatConfig.dbWrapper?.upsertCallMessage(message);

    if (IsmChatUtility.conversationControllerRegistered) {
      unawaited(
        IsmChatUtility.conversationController.getConversationsFromDB(),
      );
    }

    if (!IsmChatUtility.chatPageControllerRegistered) return;
    final controller = IsmChatUtility.chatPageController;
    if (controller.conversation?.conversationId != conversationId) return;
    await controller.getMessagesFromDB(conversationId);
  }

  /// Copy hang-up action + per-member durations onto the visible bubble.
  void _applyEndedCallToOpenChat(IsmChatMessageModel ended) {
    if (!IsmChatUtility.chatPageControllerRegistered) return;
    final chat = IsmChatUtility.chatPageController;
    if (chat.conversation?.conversationId != ended.conversationId) return;
    final meetingId = ended.meetingId?.trim() ?? '';
    if (meetingId.isEmpty) return;

    var changed = false;
    final next = <IsmChatMessageModel>[];
    for (final m in chat.messages) {
      if ((m.meetingId ?? '').trim() != meetingId) {
        next.add(m);
        continue;
      }
      changed = true;
      final durations = (ended.callDurations?.isNotEmpty ?? false)
          ? ended.callDurations
          : m.callDurations;
      next.add(
        m.copyWith(
          action: ended.action ?? m.action,
          callDurations: durations,
          metaData: _mergedCallEndMeta(
            existing: m.metaData,
            incoming: ended.metaData,
            durations: durations,
          ),
          customType: ended.customType ?? m.customType,
          initiatorId: _firstNonEmpty(ended.initiatorId, m.initiatorId),
          audioOnly: ended.audioOnly ?? m.audioOnly,
        ),
      );
    }
    if (!changed) return;
    chat.messages = next;
    chat.update();
  }

  /// Keep conversation-list last-message in sync with hang-up durations.
  void _applyEndedCallToConversationList(IsmChatMessageModel ended) {
    if (!IsmChatUtility.conversationControllerRegistered) return;
    final controller = IsmChatUtility.conversationController;
    final conversationId = ended.conversationId ?? '';
    final meetingId = ended.meetingId?.trim() ?? '';
    if (conversationId.isEmpty || meetingId.isEmpty) return;

    var changed = false;
    final next = <IsmChatConversationModel>[];
    for (final conv in controller.conversations) {
      if (conv.conversationId != conversationId) {
        next.add(conv);
        continue;
      }
      final last = conv.lastMessageDetails;
      if (last == null) {
        next.add(conv);
        continue;
      }
      final lastMeeting = last.meetingId?.trim() ?? '';
      final sameCall = lastMeeting == meetingId ||
          (lastMeeting.isEmpty &&
              (last.customType == IsmChatCustomMessageType.oneToOneCall ||
                  last.customType == IsmChatCustomMessageType.audioCall ||
                  last.customType == IsmChatCustomMessageType.videoCall ||
                  last.customType == IsmChatCustomMessageType.groupCall));
      if (!sameCall) {
        next.add(conv);
        continue;
      }
      changed = true;
      final durations = (ended.callDurations?.isNotEmpty ?? false)
          ? ended.callDurations
          : last.callDurations;
      next.add(
        conv.copyWith(
          lastMessageDetails: last.copyWith(
            action: ended.action ?? last.action,
            meetingId: meetingId,
            callDurations: durations,
            metaData: ended.metaData ?? last.metaData,
          ),
        ),
      );
    }
    if (!changed) return;
    controller.conversations = next;
    controller.update();
  }

  IsmChatMetaData _mergedCallEndMeta({
    required IsmChatMetaData? existing,
    required IsmChatMetaData? incoming,
    required List<CallDuration>? durations,
  }) {
    final custom = Map<String, dynamic>.from(
      existing?.customMetaData ?? const <String, dynamic>{},
    );
    final incomingCustom = incoming?.customMetaData;
    if (incomingCustom != null) {
      custom.addAll(incomingCustom);
    }
    if (durations != null && durations.isNotEmpty) {
      custom['callDurations'] = durations.map((e) => e.toMap()).toList();
    }
    final base = incoming ?? existing ?? IsmChatMetaData();
    return base.copyWith(customMetaData: custom);
  }

  String? _firstNonEmpty(String? a, String? b) {
    if (a != null && a.trim().isNotEmpty) return a;
    if (b != null && b.trim().isNotEmpty) return b;
    return a ?? b;
  }

  /// Rebuild conversation list + open chat so Ringing flips to In call without
  /// waiting for a new chat row (`joinRequestAccept` has no conversationId).
  void _refreshLiveCallTiles(String? meetingId) {
    if (IsmChatUtility.conversationControllerRegistered) {
      final conversations = IsmChatUtility.conversationController;
      conversations.conversations = List<IsmChatConversationModel>.from(
        conversations.conversations,
      );
      conversations.update();
    }
    if (!IsmChatUtility.chatPageControllerRegistered) return;
    final chat = IsmChatUtility.chatPageController;
    final id = meetingId?.trim() ?? '';
    if (id.isEmpty ||
        chat.messages.any((m) => (m.meetingId ?? '').trim() == id)) {
      chat.messages = List<IsmChatMessageModel>.from(chat.messages);
      chat.update();
    }
  }
}
