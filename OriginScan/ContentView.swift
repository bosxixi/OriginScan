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
            Image(systemName: "barcode.viewfinder")
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .foregroundColor(.accentColor)
                .padding(.top, 40)
            
            Text("OriginScan")
                .font(.largeTitle)
                .fontWeight(.bold)

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
                        Text("Search")
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
        guard let url = URL(string: "https://scorpioplayer.com/api/ean/issuing-country?ean=\(barcode)") else {
            DispatchQueue.main.async {
                countryInfo = nil
                isLoading = false
            }
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if error != nil {
                    countryInfo = nil
                    return
                }

                guard let data = data else {
                    countryInfo = nil
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let issuingCountry = json["issuingCountry"] as? String {
                        countryInfo = CountryInfo(name: issuingCountry, flag: flagEmoji(for: issuingCountry))
                    } else {
                        countryInfo = nil
                    }
                } catch {
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
    var scanningLine: UIView!
    var scanningLineAnimation: CABasicAnimation!
    var overlayView: UIView!
    var cornerMarkers: [UIView] = []
    
    @Binding var scannedCode: String
    @Binding var isPresented: Bool
    var alertMessage: String = ""
    var showAlert: Bool = false
    
    private var initialZoom: CGFloat = 1.0
    
    // Constants for the scanning frame
    private let scanningFrameSize: CGFloat = 250
    private let cornerMarkerLength: CGFloat = 20
    private let cornerMarkerThickness: CGFloat = 3
    private let overlayColor = UIColor.black.withAlphaComponent(0.5)

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
        
        // Setup overlay and scanning frame
        setupOverlay()
        setupScanningLine()
        
        // Add pinch gesture recognizer
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)

        captureSession.startRunning()
    }
    
    private func setupOverlay() {
        // Create semi-transparent overlay
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = overlayColor
        view.addSubview(overlayView)
        
        // Create clear scanning area
        let scanningFrame = UIView()
        let frameX = (view.bounds.width - scanningFrameSize) / 2
        let frameY = (view.bounds.height - scanningFrameSize) / 2
        scanningFrame.frame = CGRect(x: frameX, y: frameY, width: scanningFrameSize, height: scanningFrameSize)
        scanningFrame.backgroundColor = .clear
        
        // Create mask for the clear area
        let maskLayer = CAShapeLayer()
        let path = UIBezierPath(rect: overlayView.bounds)
        path.append(UIBezierPath(rect: scanningFrame.frame).reversing())
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        overlayView.layer.mask = maskLayer
        
        // Add corner markers
        setupCornerMarkers(for: scanningFrame.frame)
        
        // Add instruction label
        let instructionLabel = UILabel()
        instructionLabel.text = "Position barcode within frame"
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        instructionLabel.frame = CGRect(x: 0, y: frameY - 40, width: view.bounds.width, height: 20)
        view.addSubview(instructionLabel)
    }
    
    private func setupCornerMarkers(for frame: CGRect) {
        // Clear existing markers
        cornerMarkers.forEach { $0.removeFromSuperview() }
        cornerMarkers.removeAll()
        
        // Create corner markers
        let corners: [(CGPoint, CGPoint, CGPoint)] = [
            // Top left
            (CGPoint(x: frame.minX, y: frame.minY),
             CGPoint(x: frame.minX + cornerMarkerLength, y: frame.minY),
             CGPoint(x: frame.minX, y: frame.minY + cornerMarkerLength)),
            // Top right
            (CGPoint(x: frame.maxX, y: frame.minY),
             CGPoint(x: frame.maxX - cornerMarkerLength, y: frame.minY),
             CGPoint(x: frame.maxX, y: frame.minY + cornerMarkerLength)),
            // Bottom left
            (CGPoint(x: frame.minX, y: frame.maxY),
             CGPoint(x: frame.minX + cornerMarkerLength, y: frame.maxY),
             CGPoint(x: frame.minX, y: frame.maxY - cornerMarkerLength)),
            // Bottom right
            (CGPoint(x: frame.maxX, y: frame.maxY),
             CGPoint(x: frame.maxX - cornerMarkerLength, y: frame.maxY),
             CGPoint(x: frame.maxX, y: frame.maxY - cornerMarkerLength))
        ]
        
        for (_, horizontal, vertical) in corners {
            // Horizontal line
            let horizontalLine = createCornerMarker()
            horizontalLine.frame = CGRect(x: horizontal.x, y: horizontal.y,
                                        width: cornerMarkerLength, height: cornerMarkerThickness)
            view.addSubview(horizontalLine)
            cornerMarkers.append(horizontalLine)
            
            // Vertical line
            let verticalLine = createCornerMarker()
            verticalLine.frame = CGRect(x: vertical.x, y: vertical.y,
                                      width: cornerMarkerThickness, height: cornerMarkerLength)
            view.addSubview(verticalLine)
            cornerMarkers.append(verticalLine)
        }
    }
    
    private func createCornerMarker() -> UIView {
        let marker = UIView()
        marker.backgroundColor = .white
        return marker
    }
    
    private func setupScanningLine() {
        // Create scanning line
        scanningLine = UIView()
        scanningLine.backgroundColor = .red
        scanningLine.frame = CGRect(x: 0, y: view.bounds.midY - 1, width: view.bounds.width, height: 2)
        view.addSubview(scanningLine)
        
        // Create animation
        scanningLineAnimation = CABasicAnimation(keyPath: "position.y")
        scanningLineAnimation.fromValue = view.bounds.height * 0.2
        scanningLineAnimation.toValue = view.bounds.height * 0.8
        scanningLineAnimation.duration = 2.0
        scanningLineAnimation.repeatCount = .infinity
        scanningLineAnimation.autoreverses = true
        scanningLineAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        // Start animation
        scanningLine.layer.add(scanningLineAnimation, forKey: "scanningLineAnimation")
    }

    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let device = (captureSession.inputs.first as? AVCaptureDeviceInput)?.device else { return }
        
        switch gesture.state {
        case .began:
            initialZoom = device.videoZoomFactor
        case .changed:
            let minZoom: CGFloat = 1.0
            let maxZoom: CGFloat = device.activeFormat.videoMaxZoomFactor
            let newZoom = min(max(initialZoom * gesture.scale, minZoom), maxZoom)
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = newZoom
                device.unlockForConfiguration()
            } catch {
                print("Error setting zoom: \(error.localizedDescription)")
            }
        default:
            break
        }
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
