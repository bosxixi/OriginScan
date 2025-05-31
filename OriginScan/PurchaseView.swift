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
                    LogService.shared.logClick(itemId: "purchaseButton", itemType: "purchase")
                    Task {
                        await purchaseService.purchaseScans()
                        if purchaseService.purchaseError == nil {
                            LogService.shared.logConversion(itemId: "purchaseButton", itemType: "purchase", value: "100")
                        }
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
                .onAppear {
                    LogService.shared.logImpression(itemId: "purchaseButton", itemType: "purchase")
                }
                .disabled(purchaseService.isPurchasing)
                .padding(.horizontal)
                
                Button("Maybe Later") {
                    LogService.shared.logClick(itemId: "maybeLaterButton", itemType: "purchase")
                    dismiss()
                }
                .foregroundColor(.secondary)
                .onAppear {
                    LogService.shared.logImpression(itemId: "maybeLaterButton", itemType: "purchase")
                }
            }
            .padding()
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
} 