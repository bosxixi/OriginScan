import Foundation
import UIKit

class LogService {
    static let shared = LogService()
    private let baseURL = "https://scorpioplayer.com"
    
    // Persistent user ID (GUID)
    private var persistentUserId: String {
        if let existingId = UserDefaults.standard.string(forKey: "persistentUserId") {
            return existingId
        } else {
            let newId = UUID().uuidString
            UserDefaults.standard.set(newId, forKey: "persistentUserId")
            return newId
        }
    }
    
    // Hashed version of the user ID (6 alphanumeric uppercase)
    var hashedUserId: String {
        let data = persistentUserId.data(using: .utf8)!
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> UInt32 in
            var hash: UInt32 = 5381
            for byte in bytes {
                hash = ((hash << 5) &+ hash) &+ UInt32(byte)
            }
            return hash
        }
        let hashString = String(format: "%06X", abs(Int(hash)) % 0x1000000)
        return hashString
    }
    
    // User device name
    private var deviceName: String {
        return UIDevice.current.name
    }
    
    // Device type
    private var deviceType: String {
        return UIDevice.current.model
    }
    
    // User language
    private var userLanguage: String {
        return getLanguageCode()
    }
    
    // User country location
    private var userCountry: String {
        return getRegionCode()
    }
    
    private init() {}
    
    /// Helper to get the current app version from the bundle
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        return "\(version) (\(build))"
    }
    
    private func getLanguageCode() -> String {
        return Locale.current.language.languageCode?.identifier ?? "unknown"
    }
    
    private func getRegionCode() -> String {
        return Locale.current.region?.identifier ?? "unknown"
    }
    
    @MainActor
    func logEvent(method: String, properties: [String: String], source: String = "originscan") {
        guard let url = URL(string: "\(baseURL)/api/log/event?method=\(method)&source=\(source)") else {
            print("Invalid URL for logging event")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Merge app version, persistent user ID, hashed user ID, device name, device type, language, and country into properties
        var mergedProperties = properties
        mergedProperties["appVersion"] = appVersion
        mergedProperties["userId"] = persistentUserId
        mergedProperties["hashedUserId"] = hashedUserId
        mergedProperties["deviceName"] = deviceName
        mergedProperties["deviceType"] = deviceType
        mergedProperties["language"] = userLanguage
        mergedProperties["country"] = userCountry
        mergedProperties["remainingScans"] = String(PurchaseService.shared.remainingScans)
        mergedProperties["hasGrantedCameraPermission"] = String(CameraPermissionService.shared.hasGrantedCameraPermission)
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: mergedProperties)
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
    @MainActor
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
    @MainActor
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
    @MainActor
    func logError(error: Error, context: String) {
        let properties: [String: String] = [
            "error": error.localizedDescription,
            "context": context,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        logEvent(method: "Error", properties: properties)
    }
    
    /// Logs an IPA display name event
    /// - Parameter displayName: The display name of the IPA
    @MainActor
    func logIPADisplayName(displayName: String) {
        let properties: [String: String] = [
            "displayName": displayName,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        logEvent(method: "IPADisplayName", properties: properties)
    }
    
    /// Logs an impression event
    /// - Parameters:
    ///   - itemId: The ID of the item that was shown
    ///   - itemType: The type of the item (e.g., "purchase", "feature")
    @MainActor
    func logImpression(itemId: String, itemType: String) {
        let properties: [String: String] = [
            "itemId": itemId,
            "itemType": itemType,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        logEvent(method: "Impression", properties: properties)
    }
    
    /// Logs a click event
    /// - Parameters:
    ///   - itemId: The ID of the item that was clicked
    ///   - itemType: The type of the item (e.g., "purchase", "feature")
    @MainActor
    func logClick(itemId: String, itemType: String) {
        let properties: [String: String] = [
            "itemId": itemId,
            "itemType": itemType,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        logEvent(method: "Click", properties: properties)
    }
    
    /// Logs a conversion event
    /// - Parameters:
    ///   - itemId: The ID of the item that was converted
    ///   - itemType: The type of the item (e.g., "purchase", "feature")
    ///   - value: Optional value associated with the conversion (e.g., purchase amount)
    @MainActor
    func logConversion(itemId: String, itemType: String, value: String? = nil) {
        var properties: [String: String] = [
            "itemId": itemId,
            "itemType": itemType,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        if let value = value {
            properties["value"] = value
        }
        logEvent(method: "Conversion", properties: properties)
    }
} 
