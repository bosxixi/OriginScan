import Foundation

struct CountryDisplayNames {
    let english: String
    let localized: String
}

class CountryUtils {
    static func displayNames(for countryCode: String) -> CountryDisplayNames {
        let uppercasedCode = countryCode.uppercased()
        let englishName = Locale(identifier: "en").localizedString(forRegionCode: uppercasedCode) ?? uppercasedCode
        let userLocale = Locale.current
        let localizedName = userLocale.localizedString(forRegionCode: uppercasedCode) ?? uppercasedCode
        return CountryDisplayNames(english: englishName, localized: localizedName)
    }
} 