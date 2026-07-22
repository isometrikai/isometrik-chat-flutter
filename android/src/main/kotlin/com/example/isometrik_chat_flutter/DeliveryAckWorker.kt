package com.example.isometrik_chat_flutter

import android.content.Context
import androidx.work.CoroutineWorker
import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.ExistingWorkPolicy

/**
 * WorkManager job that acks delivery via the existing delivered-indicator API.
 *
 * Enqueued from FCM [onMessageReceived] so the ack survives process death.
 */
class DeliveryAckWorker(
    appContext: Context,
    params: WorkerParameters,
) : CoroutineWorker(appContext, params) {

    override suspend fun doWork(): Result {
        val messageId = inputData.getString(KEY_MESSAGE_ID).orEmpty()
        val conversationId = inputData.getString(KEY_CONVERSATION_ID).orEmpty()
        if (messageId.isBlank() || conversationId.isBlank()) {
            return Result.failure()
        }

        val success = DeliveryReceiptApiClient.ackDelivered(
            applicationContext,
            messageId,
            conversationId,
        )
        return if (success) Result.success() else Result.retry()
    }

    companion object {
        private const val KEY_MESSAGE_ID = "messageId"
        private const val KEY_CONVERSATION_ID = "conversationId"
        private const val WORK_PREFIX = "ism_delivery_ack_"

        fun enqueue(
            context: Context,
            messageId: String,
            conversationId: String,
        ) {
            if (messageId.isBlank() || conversationId.isBlank()) return

            val input = Data.Builder()
                .putString(KEY_MESSAGE_ID, messageId)
                .putString(KEY_CONVERSATION_ID, conversationId)
                .build()

            val request = OneTimeWorkRequestBuilder<DeliveryAckWorker>()
                .setInputData(input)
                .build()

            // Unique work per message — idempotent retries are safe.
            WorkManager.getInstance(context).enqueueUniqueWork(
                "$WORK_PREFIX$messageId",
                ExistingWorkPolicy.REPLACE,
                request,
            )
        }
    }
}
