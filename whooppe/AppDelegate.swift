import UIKit
import UserNotifications
// import Firebase
// import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    static let notificationChannelId = "blink_default"
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize Firebase - Commented out
        // FirebaseApp.configure()
        
        UNUserNotificationCenter.current().delegate = self
        
        // Messaging delegate - Commented out
        // Messaging.messaging().delegate = self
        
        requestNotificationPermission()
        
        // Comment out FCM sync for now
        // FCMTokenSyncer.shared.syncFcmToken()
        
        return true
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            print("Notification permission granted: \(granted)")
            if let error = error {
                print("Notification error: \(error.localizedDescription)")
            }
        }
    }
    
    // Comment out Messaging delegate methods
    /*
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken else { return }
        print("FCM Token: \(token)")
        FCMTokenSyncer.shared.sendTokenToServer(token: token)
    }
    */
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
}
