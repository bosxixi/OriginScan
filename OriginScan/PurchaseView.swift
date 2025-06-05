import SwiftUI

struct PurchaseView: View {
    var showCloseButton: Bool = true
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
                
                Text(NSLocalizedString("upgradeToPremium", comment: ""))
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(NSLocalizedString("getAdditionalScans", comment: ""))
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
                            dismiss()
                        }
                    }
                }) {
                    HStack {
                        if purchaseService.isPurchasing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(NSLocalizedString("purchaseScans", comment: ""))
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
                
                Button(NSLocalizedString("maybeLater", comment: "")) {
                    LogService.shared.logClick(itemId: "maybeLaterButton", itemType: "purchase")
                    dismiss()
                }
                .foregroundColor(.secondary)
                .onAppear {
                    LogService.shared.logImpression(itemId: "maybeLaterButton", itemType: "purchase")
                }
            }
            .padding()
            .navigationBarItems(trailing: showCloseButton ? AnyView(Button(NSLocalizedString("close", comment: "")) { dismiss() }) : AnyView(EmptyView()))
        }
    }
} 