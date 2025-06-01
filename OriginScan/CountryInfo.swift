import Foundation

struct CountryInfo: Decodable {
    let countryCode: String
    let countryName: String
    
    enum CodingKeys: String, CodingKey {
        case countryCode = "country_code"
        case countryName = "country_name"
    }
} 