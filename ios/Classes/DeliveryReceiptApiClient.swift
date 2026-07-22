import Foundation

/// Native client for the existing SDK delivered-indicator API:
/// `PUT {baseUrl}/chat/indicator/delivered`
enum DeliveryReceiptApiClient {
    private static let deliveredPath = "/chat/indicator/delivered"
    private static let timeout: TimeInterval = 20

    @discardableResult
    static func ackDelivered(
        messageId: String,
        conversationId: String,
        appGroupId: String?
    ) -> Bool {
        guard
            let config = DeliveryReceiptConfigStore.config(appGroupId: appGroupId),
            let baseUrl = config["baseUrl"],
            let userToken = config["userToken"],
            !messageId.isEmpty,
            !conversationId.isEmpty,
            let url = URL(string: baseUrl + deliveredPath)
        else { return false }

        var request = URLRequest(url: url, timeoutInterval: timeout)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(config["licenseKey"] ?? "", forHTTPHeaderField: "licenseKey")
        request.setValue(config["appSecret"] ?? "", forHTTPHeaderField: "appSecret")
        request.setValue(userToken, forHTTPHeaderField: "userToken")

        let body: [String: String] = [
            "messageId": messageId,
            "conversationId": conversationId,
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let semaphore = DispatchSemaphore(value: 0)
        var success = false

        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let http = response as? HTTPURLResponse {
                success = (200...299).contains(http.statusCode)
            }
            semaphore.signal()
        }.resume()

        _ = semaphore.wait(timeout: .now() + timeout + 1)
        return success
    }
}
