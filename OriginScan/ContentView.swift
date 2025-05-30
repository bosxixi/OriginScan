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

    var body: some View {
        VStack(spacing: 20) {
            Text("OriginScan")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            TextField("Enter barcode manually", text: $barcode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            HStack(spacing: 20) {
                Button(action: {
                    isScannerPresented = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                        Text("Scan")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .sheet(isPresented: $isScannerPresented) {
                    BarcodeScannerView(scannedCode: $barcode, isPresented: $isScannerPresented)
                }

                Button(action: {
                    if barcode.isEmpty {
                        countryInfo = nil
                    } else {
                        fetchIssuingCountry(for: barcode)
                    }
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.title2)
                        Text("Search")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.secondary)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
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
        guard let url = URL(string: "https://scorpioplayer.com/api/ean/issuing-country?ean=\(barcode)") else {
            countryInfo = nil
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    countryInfo = nil
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    countryInfo = nil
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let issuingCountry = json["issuingCountry"] as? String {
                    DispatchQueue.main.async {
                        countryInfo = CountryInfo(name: issuingCountry, flag: flagEmoji(for: issuingCountry))
                    }
                } else {
                    DispatchQueue.main.async {
                        countryInfo = nil
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    countryInfo = nil
                }
            }
        }

        task.resume()
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

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isPresented: Bool

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ScannerViewController(scannedCode: $scannedCode, isPresented: $isPresented)
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @Binding var scannedCode: String
    @Binding var isPresented: Bool
    var alertMessage: String = ""
    var showAlert: Bool = false

    init(scannedCode: Binding<String>, isPresented: Binding<Bool>) {
        _scannedCode = scannedCode
        _isPresented = isPresented
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .ean8, .upce]
        } else {
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            scannedCode = stringValue
            isPresented = false

            // Automatically perform search after scanning
            DispatchQueue.main.async { [self] in
                self.fetchIssuingCountry(for: self.scannedCode)
            }
        }
    }

    private func fetchIssuingCountry(for barcode: String) {
        guard let url = URL(string: "https://scorpioplayer.com/api/ean/issuing-country?ean=\(barcode)") else {
            alertMessage = "Invalid URL"
            showAlert = true
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { [self] in
                    self.alertMessage = "Error: \(error.localizedDescription)"
                    self.showAlert = true
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { [self] in
                    self.alertMessage = "No data received"
                    self.showAlert = true
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let issuingCountry = json["issuingCountry"] as? String {
                    DispatchQueue.main.async { [self] in
                        self.alertMessage = "The issuing country is: \(issuingCountry)"
                        self.showAlert = true
                    }
                } else {
                    DispatchQueue.main.async { [self] in
                        self.alertMessage = "Invalid response format"
                        self.showAlert = true
                    }
                }
            } catch {
                DispatchQueue.main.async { [self] in
                    self.alertMessage = "Error parsing response"
                    self.showAlert = true
                }
            }
        }

        task.resume()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession.isRunning) {
            captureSession.stopRunning()
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

#Preview {
    ContentView()
}
