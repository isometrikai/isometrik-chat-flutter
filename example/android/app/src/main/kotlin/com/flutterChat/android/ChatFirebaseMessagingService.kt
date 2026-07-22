package com.flutterChat.android

import com.example.isometrik_chat_flutter.DeliveryAckWorker
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

/**
 * Example FCM service — acks delivery in background via existing
 * `PUT /chat/indicator/delivered` (enqueued through WorkManager).
 *
 * Push payload must include `messageId` + `conversationId` as data fields.
 */
class ChatFirebaseMessagingService : FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        val data = message.data
        val messageId = data["messageId"]
            ?: data["message_id"]
            ?: return
        val conversationId = data["conversationId"]
            ?: data["conversation_id"]
            ?: return

        DeliveryAckWorker.enqueue(
            applicationContext,
            messageId = messageId,
            conversationId = conversationId,
        )
    }
}
