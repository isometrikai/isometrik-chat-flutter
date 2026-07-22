package com.example.isometrik_chat_flutter

import android.content.Context

/**
 * Persists auth/config for background delivery acks (FCM / WorkManager).
 *
 * Reuses the same headers as Flutter [tokenCommonHeader]:
 * licenseKey, appSecret, userToken.
 */
object DeliveryReceiptConfigStore {
    private const val PREFS = "ism_delivery_receipt_config"

    private const val KEY_BASE_URL = "baseUrl"
    private const val KEY_USER_TOKEN = "userToken"
    private const val KEY_LICENSE_KEY = "licenseKey"
    private const val KEY_APP_SECRET = "appSecret"
    private const val KEY_USER_ID = "userId"

    fun save(
        context: Context,
        baseUrl: String,
        userToken: String,
        licenseKey: String,
        appSecret: String,
        userId: String,
    ) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_BASE_URL, baseUrl.trimEnd('/'))
            .putString(KEY_USER_TOKEN, userToken)
            .putString(KEY_LICENSE_KEY, licenseKey)
            .putString(KEY_APP_SECRET, appSecret)
            .putString(KEY_USER_ID, userId)
            .apply()
    }

    fun clear(context: Context) {
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .edit()
            .clear()
            .apply()
    }

    fun isConfigured(context: Context): Boolean {
        val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
        return !prefs.getString(KEY_BASE_URL, "").isNullOrEmpty() &&
            !prefs.getString(KEY_USER_TOKEN, "").isNullOrEmpty()
    }

    fun baseUrl(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_BASE_URL, null)

    fun userToken(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_USER_TOKEN, null)

    fun licenseKey(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_LICENSE_KEY, null)

    fun appSecret(context: Context): String? =
        context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
            .getString(KEY_APP_SECRET, null)
}
