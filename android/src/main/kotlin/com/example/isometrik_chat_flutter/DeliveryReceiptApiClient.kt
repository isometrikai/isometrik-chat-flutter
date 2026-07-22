package com.example.isometrik_chat_flutter

import android.content.Context
import org.json.JSONObject
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL

/**
 * Native HTTP client for the existing SDK delivered-indicator API:
 * `PUT {baseUrl}/chat/indicator/delivered`
 */
object DeliveryReceiptApiClient {
    private const val DELIVERED_PATH = "/chat/indicator/delivered"
    private const val TIMEOUT_MS = 20_000

    /**
     * @return true when the server accepted the delivery ack (2xx).
     */
    fun ackDelivered(
        context: Context,
        messageId: String,
        conversationId: String,
    ): Boolean {
        if (!DeliveryReceiptConfigStore.isConfigured(context)) return false
        if (messageId.isBlank() || conversationId.isBlank()) return false

        val baseUrl = DeliveryReceiptConfigStore.baseUrl(context) ?: return false
        val url = URL("$baseUrl$DELIVERED_PATH")
        val connection = (url.openConnection() as HttpURLConnection).apply {
            requestMethod = "PUT"
            connectTimeout = TIMEOUT_MS
            readTimeout = TIMEOUT_MS
            doOutput = true
            setRequestProperty("Content-Type", "application/json")
            setRequestProperty(
                "licenseKey",
                DeliveryReceiptConfigStore.licenseKey(context) ?: "",
            )
            setRequestProperty(
                "appSecret",
                DeliveryReceiptConfigStore.appSecret(context) ?: "",
            )
            setRequestProperty(
                "userToken",
                DeliveryReceiptConfigStore.userToken(context) ?: "",
            )
        }

        return try {
            val body = JSONObject()
                .put("messageId", messageId)
                .put("conversationId", conversationId)
                .toString()

            OutputStreamWriter(connection.outputStream, Charsets.UTF_8).use { writer ->
                writer.write(body)
            }

            val code = connection.responseCode
            code in 200..299
        } catch (_: Exception) {
            false
        } finally {
            connection.disconnect()
        }
    }
}
