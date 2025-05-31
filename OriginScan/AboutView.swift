import SwiftUI

struct AboutView: View {
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        return "\(version) (\(build))"
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image("AppLogo")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(20)
                .padding(.top, 40)
            
            Text(NSLocalizedString("originScan", comment: ""))
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version \(appVersion)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("\(NSLocalizedString("deviceCode", comment: "")): \(LogService.shared.hashedUserId)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text(NSLocalizedString("aboutText", comment: ""))
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
            Spacer()
        }
        .navigationTitle(NSLocalizedString("about", comment: ""))
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
} 