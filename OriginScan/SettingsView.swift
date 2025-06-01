import SwiftUI

struct SettingsView: View {
    @AppStorage("autoSearchAfterScan") private var autoSearchAfterScan: Bool = true
    @AppStorage("quickScan") private var quickScan: Bool = false
    
    var body: some View {
        List {
            Section {
                NavigationLink(destination: CountrySettingsView()) {
                    Label(NSLocalizedString("countrySettings", comment: ""), systemImage: "globe")
                }
            }
            
            Section {
                Toggle(isOn: $autoSearchAfterScan) {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("autoSearchAfterScan", comment: ""))
                        Text(NSLocalizedString("autoSearchAfterScanDescription", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Toggle(isOn: $quickScan) {
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("quickScan", comment: ""))
                        Text(NSLocalizedString("quickScanDescription", comment: ""))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("settings", comment: ""))
    }
}

#Preview {
    NavigationView {
        SettingsView()
    }
} 