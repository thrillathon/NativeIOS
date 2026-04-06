import Foundation
import Combine

struct Event: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let description: String?
    let date: String
    let time: String
    let venue: String
    let city: String?
    let state: String?
    let locationLink: String
    let language: String?
    let category: String?
    let ageLimit: String?
    let coverImage: String
    let ticketPrice: Double?
    let basePrice: Double?
    let status: String?
    let adImageUrls: [String]?
    let isFavorite: Bool?
    
    // MARK: - Initializer for mock data creation
    init(
        id: String,
        name: String,
        description: String? = nil,
        date: String,
        time: String,
        venue: String,
        city: String? = nil,
        state: String? = nil,
        locationLink: String,
        language: String? = nil,
        category: String? = nil,
        ageLimit: String? = nil,
        coverImage: String,
        ticketPrice: Double? = nil,
        basePrice: Double? = nil,
        status: String? = nil,
        adImageUrls: [String]? = nil,
        isFavorite: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.date = date
        self.time = time
        self.venue = venue
        self.city = city
        self.state = state
        self.locationLink = locationLink
        self.language = language
        self.category = category
        self.ageLimit = ageLimit
        self.coverImage = coverImage
        self.ticketPrice = ticketPrice
        self.basePrice = basePrice
        self.status = status
        self.adImageUrls = adImageUrls
        self.isFavorite = isFavorite
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case name
        case description
        case date
        case time = "startTime"
        case venue = "location"
        case city
        case state
        case locationLink = "locationlink"
        case language
        case category
        case ageLimit
        case coverImage
        case ticketPrice
        case basePrice
        case status
        case adImageUrls
        case isFavorite
        case seatings
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        
        // Helper function to parse ISO 8601 and format in IST
        func formatDateTimeFromISO(_ isoString: String?) -> (date: String, time: String) {
            guard let isoString = isoString else {
                return ("TBD", "TBD")
            }
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            guard let dateObj = formatter.date(from: isoString) else {
                return (isoString, isoString)
            }
            
            // Create IST timezone
            let istTimeZone = TimeZone(identifier: "Asia/Kolkata") ?? TimeZone(secondsFromGMT: 5*3600 + 30*60)!
            
            // Format date
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = istTimeZone
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let formattedDate = dateFormatter.string(from: dateObj)
            
            // Format time
            let timeFormatter = DateFormatter()
            timeFormatter.timeZone = istTimeZone
            timeFormatter.dateFormat = "h:mm a"
            let formattedTime = timeFormatter.string(from: dateObj)
            
            return (formattedDate, formattedTime)
        }
        
        // Handle date and time from ISO timestamp
        if let timeString = try container.decodeIfPresent(String.self, forKey: .time) {
            let result = formatDateTimeFromISO(timeString)
            date = result.date
            time = result.time
        } else {
            date = "TBD"
            time = "TBD"
        }
        
        venue = try container.decodeIfPresent(String.self, forKey: .venue) ?? "TBD"
        city = try container.decodeIfPresent(String.self, forKey: .city)
        state = try container.decodeIfPresent(String.self, forKey: .state)
        locationLink = try container.decodeIfPresent(String.self, forKey: .locationLink) ?? ""
        language = try container.decodeIfPresent(String.self, forKey: .language) ?? "English"
        category = try container.decodeIfPresent(String.self, forKey: .category)
        ageLimit = try container.decodeIfPresent(String.self, forKey: .ageLimit) ?? "18+"
        
        // Handle coverImage - may need to prepend base URL
        var coverImageUrl = try container.decodeIfPresent(String.self, forKey: .coverImage) ?? ""
        if coverImageUrl.hasPrefix("/api") {
            coverImageUrl = "https://backendmongo-tau.vercel.app" + coverImageUrl
        }
        coverImage = coverImageUrl
        
        // Extract ticketPrice from seatings if available
        if let seatings = try container.decodeIfPresent([[String: AnyCodable]].self, forKey: .seatings) {
            ticketPrice = seatings.first?["price"]?.doubleValue
        } else {
            ticketPrice = nil
        }
        
        basePrice = try container.decodeIfPresent(Double.self, forKey: .basePrice)
        status = try container.decodeIfPresent(String.self, forKey: .status) ?? "UPCOMING"
        adImageUrls = try container.decodeIfPresent([String].self, forKey: .adImageUrls)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(date, forKey: .date)
        try container.encode(time, forKey: .time)
        try container.encode(venue, forKey: .venue)
        try container.encodeIfPresent(city, forKey: .city)
        try container.encodeIfPresent(state, forKey: .state)
        try container.encode(locationLink, forKey: .locationLink)
        try container.encodeIfPresent(language, forKey: .language)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(ageLimit, forKey: .ageLimit)
        try container.encode(coverImage, forKey: .coverImage)
        try container.encodeIfPresent(ticketPrice, forKey: .ticketPrice)
        try container.encodeIfPresent(basePrice, forKey: .basePrice)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(adImageUrls, forKey: .adImageUrls)
        try container.encodeIfPresent(isFavorite, forKey: .isFavorite)
    }
}

// Helper for AnyCodable
enum AnyCodable: Codable {
    case int(Int)
    case double(Double)
    case string(String)
    case bool(Bool)
    case null
    
    var doubleValue: Double? {
        switch self {
        case .double(let value):
            return value
        case .int(let value):
            return Double(value)
        default:
            return nil
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if container.decodeNil() {
            self = .null
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode AnyCodable")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}

struct TicketType: Identifiable, Codable {
    let id: String
    let name: String
    let price: Double
    let status: TicketStatus
    let statusText: String?
    let totalSeats: Int?
    let seatsSold: Int?
    let remainingSeats: Int?
    
    enum TicketStatus: String, Codable {
        case available = "available"
        case soldOut = "sold_out"
        case fastFilling = "fast_filling"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "seatType"
        case price
        case status
        case statusText
        case totalSeats
        case seatsSold
        case remainingSeats
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(Double.self, forKey: .price)
        
        let statusStr = try container.decode(String.self, forKey: .status).lowercased()
        status = TicketStatus(rawValue: statusStr) ?? .available
        
        statusText = try container.decodeIfPresent(String.self, forKey: .statusText)
        totalSeats = try container.decodeIfPresent(Int.self, forKey: .totalSeats)
        seatsSold = try container.decodeIfPresent(Int.self, forKey: .seatsSold)
        remainingSeats = try container.decodeIfPresent(Int.self, forKey: .remainingSeats)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(status.rawValue, forKey: .status)
        try container.encodeIfPresent(statusText, forKey: .statusText)
        try container.encodeIfPresent(totalSeats, forKey: .totalSeats)
        try container.encodeIfPresent(seatsSold, forKey: .seatsSold)
        try container.encodeIfPresent(remainingSeats, forKey: .remainingSeats)
    }
}

struct ConvenienceFeeResponse: Codable {
    let status: String
    let message: String?
    let data: ConvenienceFeeData
}

struct ConvenienceFeeData: Codable {
    let baseAmount: Double
    let feePercentage: Double?
    let convenienceFee: Double
    let gstPercentage: Double?
    let gstOnFee: Double
    let totalFee: Double
    let totalAmount: Double
    let breakdown: FeeBreakdown?
    
    enum CodingKeys: String, CodingKey {
        case baseAmount
        case feePercentage
        case convenienceFee
        case gstPercentage
        case gstOnFee
        case totalFee
        case totalAmount
        case breakdown
    }
}

struct FeeBreakdown: Codable {
    let base: Double
    let convenienceFee: Double
    let gst: Double
    let total: Double
}
