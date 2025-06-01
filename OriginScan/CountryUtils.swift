import Foundation

struct CountryDisplayNames {
    let english: String
    let localized: String
}

class CountryUtils {
    static func displayNames(for countryCode: String) -> (english: String, localized: String) {
        let locale = Locale(identifier: "en")
        let currentLocale = Locale.current
        
        let englishName = locale.localizedString(forRegionCode: countryCode) ?? countryCode
        let localizedName = currentLocale.localizedString(forRegionCode: countryCode) ?? englishName
        
        return (english: englishName, localized: localizedName)
    }

    static var countryList: [(code: String, name: String)] {
        let codes = Locale.isoRegionCodes
        return codes.map { code in
            let name = Locale(identifier: "en").localizedString(forRegionCode: code) ?? code
            return (code: code, name: name)
        }.sorted { $0.name < $1.name }
    }

    static func flagEmoji(for countryCode: String) -> String {
        let base: UInt32 = 127397
        var flagString = ""
        for scalar in countryCode.uppercased().unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flagString.append(String(scalarValue))
            }
        }
        return flagString
    }
} 