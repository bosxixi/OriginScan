import SwiftUI

struct MenuView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("autoSearchAfterScan") private var autoSearchAfterScan: Bool = true
    @AppStorage("quickScan") private var quickScan: Bool = false

    var body: some View {
        List {
            NavigationLink(destination: HistoryView()) {
                Label(NSLocalizedString("history", comment: ""), systemImage: "clock.arrow.circlepath")
            }
            Section {
                NavigationLink(destination: CountrySettingsView()) {
                    Label(NSLocalizedString("countrySettings", comment: ""), systemImage: "globe")
                }
                NavigationLink(destination: PurchaseView(showCloseButton: false)) {
                    Label(NSLocalizedString("purchaseMoreScans", comment: ""), systemImage: "cart")
                }
            }
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
            Section {
                NavigationLink(destination: PrivacyPolicyView()) {
                    Label(NSLocalizedString("privacyPolicy", comment: ""), systemImage: "hand.raised")
                }
            }
            NavigationLink(destination: AboutView()) {
                Label(NSLocalizedString("about", comment: ""), systemImage: "info.circle")
            }
        }
        .navigationTitle(NSLocalizedString("settings", comment: ""))
        .navigationBarItems(trailing: Button(NSLocalizedString("close", comment: "")) {
            dismiss()
        })
    }
}

#Preview {
    MenuView()
} 