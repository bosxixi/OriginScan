import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        WebView(url: URL(string: "https://originscan.scorpioplayer.com/privacy")!)
            .navigationTitle("Privacy Policy")
    }
} 