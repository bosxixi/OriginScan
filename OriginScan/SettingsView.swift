import SwiftUI

struct SettingsView: View {
    @AppStorage("autoSearchAfterScan") private var autoSearchAfterScan: Bool = true
    
    var body: some View {
        Form {
            Section {
                Toggle(NSLocalizedString("autoSearchAfterScan", comment: ""), isOn: $autoSearchAfterScan)
            } footer: {
                Text(NSLocalizedString("autoSearchAfterScanDescription", comment: ""))
                    .font(.caption)
                    .foregroundColor(.secondary)
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