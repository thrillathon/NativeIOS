import Foundation
import Combine

class SessionManager: ObservableObject {
    static let shared = SessionManager()
    
    private let sessionExpiredSubject = PassthroughSubject<Void, Never>()
    var sessionExpired: AnyPublisher<Void, Never> {
        sessionExpiredSubject.eraseToAnyPublisher()
    }
    var onSessionExpired: (() -> Void)?
    
    private init() {}
    
    func handleUnauthorized() {
        DispatchQueue.main.async {
            self.sessionExpiredSubject.send()
            self.onSessionExpired?()
        }
    }
}
