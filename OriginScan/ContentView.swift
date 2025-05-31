//
//  ContentView.swift
//  OriginScan
//
//  Created by YONG CHEN on 29/05/2025.
//

import SwiftUI
import AVFoundation

struct CountryInfo: Identifiable {
    let id = UUID()
    let englishName: String
    let localizedName: String
    let flag: String
}

struct ContentView: View {
    @State private var barcode: String = ""
    @State private var isScanning: Bool = false
    @State private var countryInfo: CountryInfo?
    @State private var isScannerPresented: Bool = false
    @State private var isLoading: Bool = false
    @State private var isMenuPresented: Bool = false
    @State private var showPurchaseView: Bool = false
    @State private var showHistoryView: Bool = false
    @StateObject private var purchaseService = PurchaseService.shared
    @AppStorage("autoSearchAfterScan") private var autoSearchAfterScan: Bool = true
    @FocusState private var isBarcodeFieldFocused: Bool

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(purchaseService.remainingScans) scans remaining")
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
            Button(action: {
                if purchaseService.canScan() {
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
            
            Text(NSLocalizedString("originScan", comment: ""))
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField(NSLocalizedString("enterBarcodeManually", comment: ""), text: $barcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .focused($isBarcodeFieldFocused)

            HStack(spacing: 20) {
                Button(action: {
                    if purchaseService.canScan() {
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
                BarcodeScannerView(scannedCode: $barcode, isPresented: $isScannerPresented) { scannedCode in
                    if !scannedCode.isEmpty {
                        if autoSearchAfterScan {
                            isLoading = true
                            purchaseService.useScan()
                            fetchIssuingCountry(for: scannedCode)
                        } else {
                            barcode = scannedCode
                        }
                    }
                }
            }

            Button(action: {
                if barcode.isEmpty {
                    isBarcodeFieldFocused = true
                } else if purchaseService.canScan() {
                    isLoading = true
                    purchaseService.useScan()
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
        }
        .padding(.horizontal)

        if let country = countryInfo {
            VStack(spacing: 15) {
                Text(country.flag)
                    .font(.system(size: 100))
                Text(country.englishName)
                    .font(.title2)
                    .fontWeight(.semibold)
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
                    countryInfo = CountryInfo(englishName: displayNames.english, localizedName: displayNames.localized, flag: flagEmoji(for: code))
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

struct MenuView: View {
    @State private var showSettings: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            NavigationLink(destination: HistoryView()) {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            Button("Settings") {
                showSettings = true
            }
        }
        .navigationTitle("Settings")
        .navigationBarItems(trailing: Button("Close") {
            dismiss()
        })
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
}

struct SettingsView: View {
    @AppStorage("autoSearchAfterScan") private var autoSearchAfterScan: Bool = true
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Toggle("Auto search after barcode detection", isOn: $autoSearchAfterScan)
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button("Close") {
                dismiss()
            })
        }
    }
}

#Preview {
    ContentView()
}
