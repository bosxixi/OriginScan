import StoreKit
import SwiftUI

@MainActor
class PurchaseService: ObservableObject {
    static let shared = PurchaseService()
    
    @Published var remainingScans: Int = 5 // Default free scans
    @Published var isPurchasing: Bool = false
    @Published var purchaseError: String?
    
    private let productId = "com.scorpioxinc.OriginScan.100scans"
    private let scansPerPurchase = 100
    private let userDefaults = UserDefaults.standard
    
    private init() {
        loadRemainingScans()
        // Start listening for transactions
        Task {
            await listenForTransactions()
        }
    }
    
    private func loadRemainingScans() {
        remainingScans = userDefaults.integer(forKey: "remainingScans")
        if remainingScans == 0 {
            remainingScans = 5 // Set default if not set
            userDefaults.set(remainingScans, forKey: "remainingScans")
        }
    }
    
    func canScan() -> Bool {
        return remainingScans > 0
    }
    
    func useScan(barcode: String) {
        ScanHistoryService.shared.reduceScanCountIfNeeded(barcode: barcode)
    }
    
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            await handleTransactionResult(result)
        }
    }
    
    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) async {
        switch result {
        case .verified(let transaction):
            // Add scans to user's account
            remainingScans += scansPerPurchase
            userDefaults.set(remainingScans, forKey: "remainingScans")
            // Finish the transaction
            await transaction.finish()
        case .unverified:
            purchaseError = "Purchase verification failed"
        }
    }
    
    func purchaseScans() async {
        isPurchasing = true
        purchaseError = nil
        
        do {
            let products = try await Product.products(for: [productId])
            guard let product = products.first else {
                throw PurchaseError.productNotFound
            }
            
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                await handleTransactionResult(verification)
            case .userCancelled:
                break
            case .pending:
                throw PurchaseError.purchasePending
            @unknown default:
                throw PurchaseError.unknown
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        
        isPurchasing = false
    }
}

enum PurchaseError: LocalizedError {
    case productNotFound
    case purchaseFailed
    case verificationFailed
    case purchasePending
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .productNotFound:
            return "Product not found in the App Store"
        case .purchaseFailed:
            return "Purchase failed. Please try again"
        case .verificationFailed:
            return "Purchase verification failed"
        case .purchasePending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        }
    }
} 