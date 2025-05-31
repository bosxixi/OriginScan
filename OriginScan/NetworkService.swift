import Foundation

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    func fetchIssuingCountry(for barcode: String, completion: @escaping (Result<String, Error>) -> Void) {
        let hashedUserId = LogService.shared.hashedUserId
        guard let url = URL(string: "https://scorpioplayer.com/api/ean/issuing-country?ean=\(barcode)&id=\(hashedUserId)") else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0, userInfo: nil)))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let issuingCountry = json["issuingCountry"] as? String {
                    completion(.success(issuingCountry))
                } else {
                    completion(.failure(NSError(domain: "Invalid JSON", code: 0, userInfo: nil)))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
} 