import Foundation
import Combine

class TokenManager: ObservableObject {
    static let shared = TokenManager()
    
    private let userDefaults = UserDefaults.standard
    private let accessTokenKey = "access_token"
    private let refreshTokenKey = "refresh_token"
    private let userIdKey = "user_id"
    
    @Published private(set) var isLoggedIn = false
    
    private init() {
        isLoggedIn = getAccessToken() != nil
    }
    
    func getAccessToken() -> String? {
        return userDefaults.string(forKey: accessTokenKey)
    }
    
    func getUserId() -> String? {
        let userId = userDefaults.string(forKey: userIdKey)
        return userId
    }
    
    func logStorageStatus() {
        let storedUserId = userDefaults.string(forKey: userIdKey)
      
    }
    
    func getAccessTokenSync() -> String? {
        return getAccessToken()
    }
    
    func isLoggedIn() async -> Bool {
        return getAccessToken() != nil
    }
    
    func clearAll() {
        userDefaults.removeObject(forKey: accessTokenKey)
        userDefaults.removeObject(forKey: refreshTokenKey)
        userDefaults.removeObject(forKey: userIdKey)
        isLoggedIn = false
    }
    
    func saveTokens(access: String, refresh: String, userId: String? = nil) {
        userDefaults.set(access, forKey: accessTokenKey)
        userDefaults.set(refresh, forKey: refreshTokenKey)
        if let userId = userId {
            userDefaults.set(userId, forKey: userIdKey)
        }
        isLoggedIn = true
    }
    
    func saveAccessToken(_ token: String, userId: String? = nil) {
        userDefaults.set(token, forKey: accessTokenKey)
        if let userId = userId {
            userDefaults.set(userId, forKey: userIdKey)
        }
        isLoggedIn = true
    }
}
