import SwiftUI

struct PurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseService = PurchaseService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "barcode.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                
                Text("Upgrade to Premium")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Get 100 additional scans for just $2.99")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                
                if let error = purchaseService.purchaseError {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Button(action: {
                    Task {
                        await purchaseService.purchaseScans()
                    }
                }) {
                    HStack {
                        if purchaseService.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Purchase 100 Scans")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(purchaseService.isPurchasing)
                .padding(.horizontal)
                
                Button("Maybe Later") {
                    dismiss()
                }
                .foregroundColor(.secondary)
            }
            .padding()
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
} 