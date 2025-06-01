import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://scorpioplayer.com"
    
    private init() {}
    
    func fetchIssuingCountry(for barcode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let hashedUserId = LogService.shared.hashedUserId
        guard let url = URL(string: "\(baseURL)/api/ean/issuing-country?ean=\(barcode)&id=\(hashedUserId)") else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(NetworkError.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.invalidData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let issuingCountry = json["issuingCountry"] as? String {
                    completion(.success(issuingCountry))
                } else {
                    completion(.failure(NetworkError.invalidData))
                }
            } catch {
                completion(.failure(NetworkError.invalidData))
            }
        }
        
        task.resume()
    }

    func fetchIssuingCountry(for barcode: String) async throws -> CountryInfo {
        let hashedUserId = LogService.shared.hashedUserId
        guard let url = URL(string: "\(baseURL)/api/country/\(barcode)?id=\(hashedUserId)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let countryInfo = try JSONDecoder().decode(CountryInfo.self, from: data)
        
        // Check if the country is supported or boycotted
        let settings = Settings.shared
        if !settings.isCountrySupported(countryInfo.countryCode) {
            throw NetworkError.countryNotSupported
        }
        if settings.isCountryBoycotted(countryInfo.countryCode) {
            throw NetworkError.countryBoycotted
        }
        
        return countryInfo
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case countryNotFound
    case countryNotSupported
    case countryBoycotted
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return NSLocalizedString("errorInvalidURL", comment: "")
        case .invalidResponse:
            return NSLocalizedString("errorInvalidResponse", comment: "")
        case .invalidData:
            return NSLocalizedString("errorInvalidData", comment: "")
        case .countryNotFound:
            return NSLocalizedString("errorCountryNotFound", comment: "")
        case .countryNotSupported:
            return NSLocalizedString("errorCountryNotSupported", comment: "")
        case .countryBoycotted:
            return NSLocalizedString("errorCountryBoycotted", comment: "")
        case .networkError(let error):
            return error.localizedDescription
        }
    }
} 