import Foundation

// #if canImport(FirebaseMessaging)
// import FirebaseCore
// import FirebaseMessaging
//
// class FCMTokenSyncer: NSObject {
//     static let shared = FCMTokenSyncer()
//     
//     func syncFcmToken() {
//         Messaging.messaging().token { token, error in
//             if let error = error {
//                 print("FCM token retrieval error: \(error)")
//                 return
//             }
//             if let token = token {
//                 self.sendTokenToServer(token: token)
//             } else {
//                 print("FCM token is nil")
//             }
//         }
//     }
//     
//     func sendTokenToServer(token: String) {
//         // API call to sync token with backend
//         print("FCM Token: \(token)")
//     }
// }
//
// #else

// Fallback implementation when FirebaseMessaging isn't available
class FCMTokenSyncer: NSObject {
    static let shared = FCMTokenSyncer()
    
    func syncFcmToken() {
        // FirebaseMessaging not available; log and no-op to keep build green
        print("FirebaseMessaging not available. Skipping FCM token sync.")
    }
    
    func sendTokenToServer(token: String) {
        // API call to sync token with backend (unreachable without Messaging)
        print("FCM Token (no Messaging SDK): \(token)")
    }
}


