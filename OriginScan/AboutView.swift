import SwiftUI
import MessageUI

struct AboutView: View {
    @State private var isMailComposerPresented = false

    var body: some View {
        VStack(spacing: 20) {
            Text(NSLocalizedString("about", comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)
            Text(NSLocalizedString("publisher", comment: ""))
                .font(.title2)
            Button(action: {
                isMailComposerPresented = true
            }) {
                Text(NSLocalizedString("supportEmail", comment: ""))
                    .font(.title2)
                    .foregroundColor(.blue)
                    .underline()
            }
            Text(NSLocalizedString("appName", comment: ""))
                .font(.title2)
            Text(NSLocalizedString("appVersion", comment: ""))
                .font(.title2)
        }
        .padding()
        .sheet(isPresented: $isMailComposerPresented) {
            MailComposerView()
        }
    }
}

struct MailComposerView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposer = MFMailComposeViewController()
        mailComposer.setToRecipients(["support@scorpioplayer.com"])
        mailComposer.setSubject("\(NSLocalizedString("appName", comment: "")) - \(NSLocalizedString("appVersion", comment: ""))")
        mailComposer.mailComposeDelegate = context.coordinator
        return mailComposer
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    }
}

#Preview {
    AboutView()
} 