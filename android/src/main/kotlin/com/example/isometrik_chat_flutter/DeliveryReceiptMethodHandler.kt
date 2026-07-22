package com.example.isometrik_chat_flutter

import android.content.Context
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * Method channel for background delivery receipt credential sync + native ack enqueue.
 *
 * Channel: `isometrik_chat_flutter/delivery_receipts`
 */
class DeliveryReceiptMethodHandler(private var context: Context?) :
    MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val ctx = context
        if (ctx == null) {
            result.error("NO_CONTEXT", "Plugin not attached", null)
            return
        }

        when (call.method) {
            "syncDeliveryReceiptConfig" -> {
                val args = call.arguments as? Map<*, *>
                if (args == null) {
                    result.error("INVALID_ARGS", "Expected map", null)
                    return
                }
                DeliveryReceiptConfigStore.save(
                    ctx,
                    baseUrl = args["baseUrl"]?.toString().orEmpty(),
                    userToken = args["userToken"]?.toString().orEmpty(),
                    licenseKey = args["licenseKey"]?.toString().orEmpty(),
                    appSecret = args["appSecret"]?.toString().orEmpty(),
                    userId = args["userId"]?.toString().orEmpty(),
                )
                result.success(null)
            }

            "clearDeliveryReceiptConfig" -> {
                DeliveryReceiptConfigStore.clear(ctx)
                result.success(null)
            }

            "ackDelivered" -> {
                val args = call.arguments as? Map<*, *>
                val messageId = args?.get("messageId")?.toString().orEmpty()
                val conversationId = args?.get("conversationId")?.toString().orEmpty()
                DeliveryAckWorker.enqueue(ctx, messageId, conversationId)
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    fun attach(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
    }

    fun detach() {
        context = null
    }
}
