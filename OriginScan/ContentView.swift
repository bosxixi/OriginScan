//
//  ContentView.swift
//  OriginScan
//
//  Created by YONG CHEN on 29/05/2025.
//

import SwiftUI
import AVFoundation

struct ScannedCountryInfo: Identifiable {
    let id = UUID()
    let countryCode: String
    let englishName: String
    let localizedName: String
    let flag: String
}

struct ContentView: View {
    @State private var barcode: String = ""
    @State private var isScanning: Bool = false
    @State private var countryInfo: ScannedCountryInfo?
    @State private var isScannerPresented: Bool = false
    @State private var isLoading: Bool = false
    @State private var isMenuPresented: Bool = false
    @State private var showPurchaseView: Bool = false
    @State private var showHistoryView: Bool = false
    @StateObject private var purchaseService = PurchaseService.shared
    @AppStorage("autoSearchAfterScan") private var autoSearchAfterScan: Bool = true
    @AppStorage("quickScan") private var quickScan: Bool = false
    @FocusState private var isBarcodeFieldFocused: Bool
    @State private var isViewReady: Bool = false

    private func isSimulator() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text(NSLocalizedString("scansRemaining", comment: "") + ": \(purchaseService.remainingScans)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Button(action: {
                    isMenuPresented = true
                }) {
                    Image(systemName: "gear")
                        .font(.title)
                        .foregroundColor(.accentColor)
                }
                .padding(.trailing)
            }
            .onAppear {
                LogService.shared.logIPADisplayName(displayName: NSLocalizedString("originScan", comment: ""))
                
                // Mark view as ready after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isViewReady = true
                }
            }
            .onChange(of: isViewReady) { newValue in
                if newValue && quickScan {
                    if purchaseService.canScan() {
                        isScannerPresented = true
                    } else {
                        showPurchaseView = true
                    }
                }
            }
            Button(action: {
                LogService.shared.logClick(itemId: "scanButton", itemType: "scan")
                if isSimulator() {
                    barcode = "9415077150748"
                    if purchaseService.canScan() {
                        isLoading = true
                        purchaseService.useScan(barcode: barcode)
                        fetchIssuingCountry(for: barcode)
                    } else {
                        showPurchaseView = true
                    }
                } else if purchaseService.canScan() {
                    isScannerPresented = true
                } else {
                    showPurchaseView = true
                }
            }) {
                Image(systemName: "barcode.viewfinder")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.accentColor)
                    .padding(.top, 40)
            }
            .onAppear {
                LogService.shared.logImpression(itemId: "scanButton", itemType: "scan")
            }
            
            Text(NSLocalizedString("originScan", comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField(NSLocalizedString("enterBarcodeManually", comment: ""), text: $barcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .focused($isBarcodeFieldFocused)

            HStack(spacing: 20) {
                Button(action: {
                    if isSimulator() {
                        barcode = "9415077150748"
                        if purchaseService.canScan() {
                            isLoading = true
                            purchaseService.useScan(barcode: barcode)
                            fetchIssuingCountry(for: barcode)
                        } else {
                            showPurchaseView = true
                        }
                    } else if purchaseService.canScan() {
                        isScannerPresented = true
                    } else {
                        showPurchaseView = true
                    }
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text(NSLocalizedString("scan", comment: ""))
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .sheet(isPresented: $isScannerPresented) {
                if !isSimulator() {
                    BarcodeScannerView(scannedCode: $barcode, isPresented: $isScannerPresented) { scannedCode in
                        if !scannedCode.isEmpty {
                            if autoSearchAfterScan {
                                isLoading = true
                                purchaseService.useScan(barcode: scannedCode)
                                fetchIssuingCountry(for: scannedCode)
                            } else {
                                barcode = scannedCode
                            }
                        }
                    }
                }
            }

            Button(action: {
                LogService.shared.logClick(itemId: "searchButton", itemType: "search")
                if barcode.isEmpty {
                    isBarcodeFieldFocused = true
                } else if purchaseService.canScan() {
                    isLoading = true
                    purchaseService.useScan(barcode: barcode)
                    fetchIssuingCountry(for: barcode)
                } else {
                    showPurchaseView = true
                }
            }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                    }
                    Text(NSLocalizedString("search", comment: ""))
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isLoading ? Color.secondary.opacity(0.7) : Color.secondary)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(isLoading)
            .onAppear {
                LogService.shared.logImpression(itemId: "searchButton", itemType: "search")
            }
        }
        .padding(.horizontal)

        if let country = countryInfo {
            VStack(spacing: 15) {
                Text(country.flag)
                    .font(.system(size: 100))
                HStack(spacing: 8) {
                    Text(country.englishName)
                        .font(.title2)
                        .fontWeight(.semibold)
                    if Settings.shared.isCountrySupported(country.countryCode) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else if Settings.shared.isCountryBoycotted(country.countryCode) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                            .font(.title2)
                    }
                }
                if country.localizedName != country.englishName {
                    Text(country.localizedName)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(radius: 5)
            .padding()
        }

        Spacer()
        .navigationBarHidden(true)
        .sheet(isPresented: $isMenuPresented) {
            NavigationView {
                MenuView()
            }
        }
        .sheet(isPresented: $showPurchaseView) {
            PurchaseView()
        }
    }

    private func fetchIssuingCountry(for barcode: String) {
        isLoading = true
        NetworkService.shared.fetchIssuingCountry(for: barcode) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let issuingCountry):
                    let code = String(issuingCountry.prefix(2)).uppercased()
                    let displayNames = CountryUtils.displayNames(for: code)
                    countryInfo = ScannedCountryInfo(countryCode: code, englishName: displayNames.english, localizedName: displayNames.localized, flag: flagEmoji(for: code))
                    // Log successful country search
                    LogService.shared.logCountrySearch(barcode: barcode, country: displayNames.english)
                    // Save to history
                    let historyItem = ScanHistoryItem(countryCode: code, countryName: displayNames.english, localizedCountryName: displayNames.localized, flag: flagEmoji(for: code), barcode: barcode)
                    ScanHistoryService.shared.add(item: historyItem)
                case .failure(let error):
                    countryInfo = nil
                    // Log error
                    LogService.shared.logError(error: error, context: "fetchIssuingCountry")
                }
            }
        }
    }

    private func flagEmoji(for country: String) -> String {
        let base: UInt32 = 127397 // Unicode scalar for regional indicator symbol letter A
        var flagString = ""
        
        // Convert country name to country code (you might need to add more mappings)
        let countryCode = country.prefix(2).uppercased()
        
        for scalar in countryCode.unicodeScalars {
            if let scalarValue = UnicodeScalar(base + scalar.value) {
                flagString.append(String(scalarValue))
            }
        }
        
        return flagString
    }
}

#Preview {
    ContentView()
}
