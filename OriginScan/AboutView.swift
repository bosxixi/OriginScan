import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("about", comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(NSLocalizedString("publisher", comment: ""))
                .font(.title2)
            Text(NSLocalizedString("supportEmail", comment: ""))
                .font(.title2)
            Text(NSLocalizedString("appName", comment: ""))
                .font(.title2)
            Text(NSLocalizedString("appVersion", comment: ""))
                .font(.title2)
        }
        .padding()
    }
}

#Preview {
    AboutView()
} 