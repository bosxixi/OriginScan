import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("About")
                .font(.largeTitle)
                .fontWeight(.bold)
            Text("Publisher: ScorpioPlayer")
                .font(.title2)
            Text("Support Email: support@scorpioplayer.com")
                .font(.title2)
            Text("App Name: OriginScan")
                .font(.title2)
            Text("App Version: 1.0")
                .font(.title2)
        }
        .padding()
    }
}

#Preview {
    AboutView()
} 