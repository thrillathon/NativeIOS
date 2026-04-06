import Foundation
import Combine

struct AdData: Identifiable, Codable {
    let id: String
    let imageUrl: String
    let title: String
    let description: String?
    let actionUrl: String?
    let displayType: String
    let platform: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case imageUrl
        case title
        case description
        case actionUrl
        case displayType
        case platform
    }
}
