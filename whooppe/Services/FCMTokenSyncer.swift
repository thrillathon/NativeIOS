import Foundation
import UIKit
import FirebaseMessaging

class FCMTokenSyncer: NSObject {
    static let shared = FCMTokenSyncer()
    
    private let baseURL = "https://backendmongo-tau.vercel.app/api"

    func syncFcmToken() {
        print("🔔 [FCM] Requesting FCM token...")
        Messaging.messaging().token { [weak self] token, error in
            if let error = error {
                print("🔴 [FCM] Token retrieval error: \(error.localizedDescription)")
                return
            }
            guard let token = token else {
                print("🟡 [FCM] Token is nil — APNs may not be registered yet")
                return
            }
            print("✅ [FCM] Token received: \(token)")
            self?.sendTokenToServer(token: token)
        }
    }
    
    /// Register / update the FCM token on the backend.
    func sendTokenToServer(token: String) {
        guard let url = URL(string: "\(baseURL)/notifications/register-token") else {
            print("🔴 [FCM] Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let authToken = TokenManager.shared.getAccessToken() {
            request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? "unknown"
        let deviceType = "ios"

        var body: [String: String] = [
            "token": token,
            "deviceId": deviceId,
            "deviceType": deviceType
        ]
        if let userId = TokenManager.shared.getUserId() {
            body["userId"] = userId
        }

        print("📤 [FCM] Registering token to backend...")
        print("   token    : \(token)")
        print("   deviceId : \(deviceId)")
        print("   deviceType: \(deviceType)")
        print("   userId   : \(TokenManager.shared.getUserId() ?? "guest")")

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("🔴 [FCM] Network error: \(error.localizedDescription)")
                return
            }
            if let http = response as? HTTPURLResponse {
                let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? "(empty)"
                if (200...299).contains(http.statusCode) {
                    print("✅ [FCM] Token registered — HTTP \(http.statusCode)")
                    print("   Response: \(body)")
                } else {
                    print("🔴 [FCM] Registration failed — HTTP \(http.statusCode)")
                    print("   Response: \(body)")
                }
            }
        }.resume()
    }
}


