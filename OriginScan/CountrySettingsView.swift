import SwiftUI

struct CountrySettingsView: View {
    @StateObject private var settings = Settings.shared
    @State private var searchText = ""
    @State private var showingSupportedCountries = true
    
    private var filteredCountries: [(code: String, name: String)] {
        let allCountries = CountryUtils.countryList
        let filtered = searchText.isEmpty ? allCountries : allCountries.filter { country in
            country.name.localizedCaseInsensitiveContains(searchText) ||
            country.code.localizedCaseInsensitiveContains(searchText)
        }
        
        return filtered.sorted { country1, country2 in
            let isSelected1 = showingSupportedCountries ? 
                settings.supportedCountries.contains(country1.code) :
                settings.boycottedCountries.contains(country1.code)
            let isSelected2 = showingSupportedCountries ? 
                settings.supportedCountries.contains(country2.code) :
                settings.boycottedCountries.contains(country2.code)
            
            if isSelected1 != isSelected2 {
                return isSelected1 // Selected countries come first
            }
            return country1.name < country2.name // Then sort alphabetically
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Picker("Country List", selection: $showingSupportedCountries) {
                Text(NSLocalizedString("supportedCountries", comment: "")).tag(true)
                Text(NSLocalizedString("boycottedCountries", comment: "")).tag(false)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List {
                ForEach(filteredCountries, id: \.code) { country in
                    HStack(spacing: 16) {
                        Text(CountryUtils.flagEmoji(for: country.code))
                            .font(.system(size: 40))
                            .frame(width: 48, height: 48)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(country.name)
                                .font(.headline)
                            if let localizedName = Locale.current.localizedString(forRegionCode: country.code),
                               localizedName != country.name {
                                Text(localizedName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if showingSupportedCountries {
                            if settings.supportedCountries.contains(country.code) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            }
                        } else {
                            if settings.boycottedCountries.contains(country.code) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                    .font(.title2)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if showingSupportedCountries {
                            settings.toggleSupportedCountry(country.code)
                        } else {
                            settings.toggleBoycottedCountry(country.code)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .searchable(text: $searchText, prompt: NSLocalizedString("searchCountries", comment: ""))
        .navigationTitle(showingSupportedCountries ? 
            NSLocalizedString("supportedCountries", comment: "") : 
            NSLocalizedString("boycottedCountries", comment: ""))
    }
}

#Preview {
    NavigationView {
        CountrySettingsView()
    }
} 