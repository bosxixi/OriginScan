import SwiftUI
import MessageUI

struct AboutView: View {
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "unknown"
        return "\(version) (\(build))"
    }
    
    private var appName: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "OriginScan"
    }
    
    @State private var isShowingMailView = false
    
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
            
            Button(action: {
                if MFMailComposeViewController.canSendMail() {
                    isShowingMailView = true
                } else {
                    let subject = "\(appName) \(appVersion)"
                    let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? subject
                    if let url = URL(string: "mailto:support@scorpioplayer.com?subject=\(subjectEncoded)") {
                        UIApplication.shared.open(url)
                    }
                }
            }) {
                Text(NSLocalizedString("contactUs", comment: ""))
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            Spacer()
        }
        .navigationTitle(NSLocalizedString("about", comment: ""))
        .sheet(isPresented: $isShowingMailView) {
            MailView(isShowing: $isShowingMailView, subject: "\(appName) \(appVersion)")
        }
    }
}

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    let subject: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(["support@scorpioplayer.com"])
        vc.setSubject(subject)
        return vc
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(isShowing: $isShowing)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        @Binding var isShowing: Bool
        
        init(isShowing: Binding<Bool>) {
            _isShowing = isShowing
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            isShowing = false
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
} 