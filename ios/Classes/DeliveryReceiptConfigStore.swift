import Foundation

/// Shared credential storage for background delivery acks (App Group on iOS).
///
/// Matches Flutter [IsmChatDeliveryReceiptBridge.syncNativeCredentials] keys.
enum DeliveryReceiptConfigStore {
    private static let prefsKey = "ism_delivery_receipt_config"

    static func save(
        baseUrl: String,
        userToken: String,
        licenseKey: String,
        appSecret: String,
        userId: String,
        appGroupId: String
    ) {
        let defaults = suite(appGroupId: appGroupId) ?? UserDefaults.standard
        defaults.set([
            "baseUrl": baseUrl.trimmingCharacters(in: CharacterSet(charactersIn: "/")),
            "userToken": userToken,
            "licenseKey": licenseKey,
            "appSecret": appSecret,
            "userId": userId,
            "appGroupId": appGroupId,
        ], forKey: prefsKey)
    }

    static func clear(appGroupId: String?) {
        let defaults = suite(appGroupId: appGroupId) ?? UserDefaults.standard
        defaults.removeObject(forKey: prefsKey)
    }

    static func config(appGroupId: String?) -> [String: String]? {
        let defaults = suite(appGroupId: appGroupId) ?? UserDefaults.standard
        guard let raw = defaults.dictionary(forKey: prefsKey) as? [String: String] else {
            return nil
        }
        guard
            let baseUrl = raw["baseUrl"], !baseUrl.isEmpty,
            let userToken = raw["userToken"], !userToken.isEmpty
        else { return nil }
        return raw
    }

    private static func suite(appGroupId: String?) -> UserDefaults? {
        guard let id = appGroupId, !id.isEmpty else { return nil }
        return UserDefaults(suiteName: id)
    }
}
