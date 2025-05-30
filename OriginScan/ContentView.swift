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
    let name: String
    let flag: String
}

struct ContentView: View {
    @State private var barcode: String = ""
    @State private var isScanning: Bool = false
    @State private var countryInfo: CountryInfo?
    @State private var isScannerPresented: Bool = false
    @State private var isLoading: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Button(action: {
                isScannerPresented = true
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

            HStack(spacing: 20) {
                Button(action: {
                    isScannerPresented = true
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
                .sheet(isPresented: $isScannerPresented) {
                    BarcodeScannerView(scannedCode: $barcode, isPresented: $isScannerPresented) { scannedCode in
                        if !scannedCode.isEmpty {
                            isLoading = true
                            fetchIssuingCountry(for: scannedCode)
                        }
                    }
                }

                Button(action: {
                    if barcode.isEmpty {
                        countryInfo = nil
                    } else {
                        isLoading = true
                        fetchIssuingCountry(for: barcode)
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
                    
                    Text(country.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding()
            }

            Spacer()
        }
    }

    private func fetchIssuingCountry(for barcode: String) {
        isLoading = true
        NetworkService.shared.fetchIssuingCountry(for: barcode) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let issuingCountry):
                    countryInfo = CountryInfo(name: issuingCountry, flag: flagEmoji(for: issuingCountry))
                case .failure:
                    countryInfo = nil
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
