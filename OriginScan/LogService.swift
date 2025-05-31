import Foundation

class LogService {
    static let shared = LogService()
    private let baseURL = "https://scorpioplayer.com"
    
    private init() {}
    
    /// Logs an event with properties to the backend API
    /// - Parameters:
    ///   - method: The method/event name
    ///   - properties: Properties as key-value pairs
    ///   - source: The source of the log (defaults to "ios")
    func logEvent(method: String, properties: [String: String], source: String = "originscan") {
        guard let url = URL(string: "\(baseURL)/api/log/event?method=\(method)&source=\(source)") else {
            print("Invalid URL for logging event")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: properties)
            request.httpBody = jsonData
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error logging event: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode != 200 {
                        print("Failed to log event. Status code: \(httpResponse.statusCode)")
                    }
                }
            }
            
            task.resume()
        } catch {
            print("Error serializing properties: \(error.localizedDescription)")
        }
    }
    
    /// Logs a barcode scan event
    /// - Parameter barcode: The scanned barcode
    func logBarcodeScan(barcode: String) {
        let properties: [String: String] = [
            "barcode": barcode,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        logEvent(method: "BarcodeScan", properties: properties)
    }
    
    /// Logs a country search event
    /// - Parameters:
    ///   - barcode: The barcode that was searched
    ///   - country: The country that was found
    func logCountrySearch(barcode: String, country: String) {
        let properties: [String: String] = [
            "barcode": barcode,
            "country": country,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        logEvent(method: "CountrySearch", properties: properties)
    }
    
    /// Logs an error event
    /// - Parameters:
    ///   - error: The error that occurred
    ///   - context: Additional context about where the error occurred
    func logError(error: Error, context: String) {
        let properties: [String: String] = [
            "error": error.localizedDescription,
            "context": context,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        logEvent(method: "Error", properties: properties)
    }
} 
