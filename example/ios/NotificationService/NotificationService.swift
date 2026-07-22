//
//  NotificationService.swift
//  NotificationService
//
//  Acks delivery while the app is killed via existing SDK API:
//  PUT {baseUrl}/chat/indicator/delivered
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    /// Must match Runner + [IsmChatDeliveryReceiptBridge.appGroupId].
    private static let appGroupId = "group.com.flutterChatDemo.ios"

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        let userInfo = request.content.userInfo
        let messageId = stringValue(userInfo["messageId"]) ?? stringValue(userInfo["message_id"])
        let conversationId = stringValue(userInfo["conversationId"])
            ?? stringValue(userInfo["conversation_id"])

        if let messageId, let conversationId {
            _ = ackDelivered(messageId: messageId, conversationId: conversationId)
        }

        if let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler, let bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // MARK: - Existing delivered-indicator API (same as Flutter SDK)

    private func ackDelivered(messageId: String, conversationId: String) -> Bool {
        guard
            let config = loadConfig(),
            let baseUrl = config["baseUrl"],
            let userToken = config["userToken"],
            let url = URL(string: baseUrl + "/chat/indicator/delivered")
        else { return false }

        var request = URLRequest(url: url, timeoutInterval: 20)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config["licenseKey"] ?? "", forHTTPHeaderField: "licenseKey")
        request.setValue(config["appSecret"] ?? "", forHTTPHeaderField: "appSecret")
        request.setValue(userToken, forHTTPHeaderField: "userToken")
        request.httpBody = try? JSONSerialization.data(withJSONObject: [
            "messageId": messageId,
            "conversationId": conversationId,
        ])

        let semaphore = DispatchSemaphore(value: 0)
        var success = false
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse {
                success = (200...299).contains(http.statusCode)
            }
            semaphore.signal()
        }.resume()
        _ = semaphore.wait(timeout: .now() + 21)
        return success
    }

    private func loadConfig() -> [String: String]? {
        let defaults = UserDefaults(suiteName: Self.appGroupId)
        guard let raw = defaults?.dictionary(forKey: "ism_delivery_receipt_config") as? [String: String],
              !(raw["baseUrl"] ?? "").isEmpty,
              !(raw["userToken"] ?? "").isEmpty
        else { return nil }
        return raw
    }

    private func stringValue(_ value: Any?) -> String? {
        if let s = value as? String, !s.isEmpty { return s }
        if let n = value as? NSNumber { return n.stringValue }
        return nil
    }
}
