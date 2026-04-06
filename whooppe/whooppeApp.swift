import SwiftUI
// #if canImport(FirebaseCore)
// import FirebaseCore
// #endif

@main
struct WhooppeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var tokenManager = TokenManager.shared
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var networkMonitor = NetworkMonitor.shared
    
    init() {
        // #if canImport(FirebaseCore)
        // FirebaseApp.configure()
        // #endif
        setupImageLoader()
    }
    
    var body: some Scene {
        WindowGroup {
            MainContentView()
                .environmentObject(tokenManager)
                .environmentObject(sessionManager)
                .environmentObject(networkMonitor)
                .preferredColorScheme(.light)
        }
    }
    
    private func setupImageLoader() {
        // Configure Kingfisher cache
        // let cache = ImageCache.default
        // cache.memoryStorage.config.totalCostLimit = 250 * 1024 * 1024
        // cache.diskStorage.config.sizeLimit = 50 * 1024 * 1024
    }
}

