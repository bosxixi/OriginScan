import SwiftUI

struct MenuView: View {
    @State private var showSettings: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            NavigationLink(destination: HistoryView()) {
                Label(NSLocalizedString("history", comment: ""), systemImage: "clock.arrow.circlepath")
            }
            NavigationLink(destination: SettingsView()) {
                Label(NSLocalizedString("settings", comment: ""), systemImage: "gear")
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