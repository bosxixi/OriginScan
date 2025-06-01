import Foundation
import Combine

class Settings: ObservableObject {
    static let shared = Settings()
    
    private let userDefaults = UserDefaults.standard
    private let supportedCountriesKey = "supportedCountries"
    private let boycottedCountriesKey = "boycottedCountries"
    
    @Published var supportedCountries: [String] = []
    @Published var boycottedCountries: [String] = []
    
    private init() {
        supportedCountries = userDefaults.stringArray(forKey: supportedCountriesKey) ?? []
        boycottedCountries = userDefaults.stringArray(forKey: boycottedCountriesKey) ?? []
    }
    
    func isCountrySupported(_ countryCode: String) -> Bool {
        supportedCountries.contains(countryCode)
    }
    
    func isCountryBoycotted(_ countryCode: String) -> Bool {
        boycottedCountries.contains(countryCode)
    }
    
    func setCountrySupported(_ countryCode: String, supported: Bool) {
        if supported {
            if !supportedCountries.contains(countryCode) {
                supportedCountries.append(countryCode)
            }
        } else {
            supportedCountries.removeAll { $0 == countryCode }
        }
        userDefaults.set(supportedCountries, forKey: supportedCountriesKey)
        objectWillChange.send()
    }
    
    func setCountryBoycotted(_ countryCode: String, boycotted: Bool) {
        if boycotted {
            if !boycottedCountries.contains(countryCode) {
                boycottedCountries.append(countryCode)
            }
        } else {
            boycottedCountries.removeAll { $0 == countryCode }
        }
        userDefaults.set(boycottedCountries, forKey: boycottedCountriesKey)
        objectWillChange.send()
    }
    
    func toggleSupportedCountry(_ countryCode: String) {
        let isSupported = isCountrySupported(countryCode)
        setCountrySupported(countryCode, supported: !isSupported)
    }
    
    func toggleBoycottedCountry(_ countryCode: String) {
        let isBoycotted = isCountryBoycotted(countryCode)
        setCountryBoycotted(countryCode, boycotted: !isBoycotted)
    }
} 