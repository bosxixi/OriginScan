import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isPresented: Bool
    var onScanComplete: (String) -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = ScannerViewController(scannedCode: $scannedCode, isPresented: $isPresented, onScanComplete: onScanComplete)
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
    var onScanComplete: (String) -> Void
    
    private var initialZoom: CGFloat = 1.0
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var isFrameRestricted: Bool = true  // Add state for frame restriction
    
    // Constants for the scanning frame
    private let scanningFrameWidth: CGFloat = 300  // Width for 3:2 ratio
    private let scanningFrameHeight: CGFloat = 200  // Height for 3:2 ratio
    private let cornerMarkerLength: CGFloat = 20
    private let cornerMarkerThickness: CGFloat = 3
    private let overlayColor = UIColor.black.withAlphaComponent(0.5)
    private let frameTopOffset: CGFloat = 120

    init(scannedCode: Binding<String>, isPresented: Binding<Bool>, onScanComplete: @escaping (String) -> Void) {
        _scannedCode = scannedCode
        _isPresented = isPresented
        self.onScanComplete = onScanComplete
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Check camera permission
        let status = CameraPermissionService.shared.checkCameraPermission()
        switch status {
        case .notDetermined:
            CameraPermissionService.shared.requestCameraPermission { [weak self] granted in
                if granted {
                    self?.setupCamera()
                } else {
                    self?.dismissScanner()
                }
            }
        case .restricted, .denied:
            dismissScanner()
        case .authorized:
            setupCamera()
        @unknown default:
            dismissScanner()
        }
    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = getCameraDevice() else {
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
    
    private func getCameraDevice() -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [.builtInWideAngleCamera]
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: currentCameraPosition
        )
        return discoverySession.devices.first
    }
    
    private func switchCamera() {
        guard let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput else { return }
        
        // Stop the session
        captureSession.stopRunning()
        
        // Remove current input
        captureSession.removeInput(currentInput)
        
        // Switch camera position
        currentCameraPosition = currentCameraPosition == .back ? .front : .back
        
        // Get new camera device
        guard let newCamera = getCameraDevice() else { return }
        
        // Create new input
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if captureSession.canAddInput(newInput) {
                captureSession.addInput(newInput)
            }
        } catch {
            print("Error switching camera: \(error.localizedDescription)")
            return
        }
        
        // Start the session again
        captureSession.startRunning()
    }
    
    private func setupOverlay() {
        // Create semi-transparent overlay
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = overlayColor
        view.addSubview(overlayView)
        
        // Create clear scanning area
        let scanningFrame = UIView()
        let frameX = (view.bounds.width - scanningFrameWidth) / 2
        let frameY = frameTopOffset
        scanningFrame.frame = CGRect(x: frameX, y: frameY, width: scanningFrameWidth, height: scanningFrameHeight)
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
        instructionLabel.text = NSLocalizedString("positionBarcodeWithinFrame", comment: "")
        instructionLabel.textColor = .white
        instructionLabel.textAlignment = .center
        instructionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        instructionLabel.frame = CGRect(x: 0, y: frameY - 40, width: view.bounds.width, height: 20)
        view.addSubview(instructionLabel)
        
        // Add close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.frame = CGRect(x: view.bounds.width - 70, y: 30, width: 50, height: 50)
        var config = UIButton.Configuration.plain()
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        closeButton.configuration = config
        closeButton.addTarget(self, action: #selector(dismissScanner), for: .touchUpInside)
        view.addSubview(closeButton)
        
        // Add flashlight button
        let flashlightButton = UIButton(type: .system)
        flashlightButton.setImage(UIImage(systemName: "flashlight.off.fill"), for: .normal)
        flashlightButton.tintColor = .white
        flashlightButton.frame = CGRect(x: 20, y: 30, width: 50, height: 50)
        var flashlightConfig = UIButton.Configuration.plain()
        flashlightConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        flashlightButton.configuration = flashlightConfig
        flashlightButton.addTarget(self, action: #selector(toggleFlashlight), for: .touchUpInside)
        view.addSubview(flashlightButton)
        
        // Add camera toggle button
        let cameraToggleButton = UIButton(type: .system)
        cameraToggleButton.setImage(UIImage(systemName: "camera.rotate.fill"), for: .normal)
        cameraToggleButton.tintColor = .white
        cameraToggleButton.frame = CGRect(x: view.bounds.width - 70, y: 90, width: 50, height: 50)
        var cameraToggleConfig = UIButton.Configuration.plain()
        cameraToggleConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        cameraToggleButton.configuration = cameraToggleConfig
        cameraToggleButton.addTarget(self, action: #selector(toggleCamera), for: .touchUpInside)
        view.addSubview(cameraToggleButton)
        
        // Add frame restriction toggle button
        let frameToggleButton = UIButton(type: .system)
        frameToggleButton.setImage(UIImage(systemName: "rectangle.dashed"), for: .normal)
        frameToggleButton.tintColor = .white
        frameToggleButton.frame = CGRect(x: 20, y: 90, width: 50, height: 50)
        var frameToggleConfig = UIButton.Configuration.plain()
        frameToggleConfig.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        frameToggleButton.configuration = frameToggleConfig
        frameToggleButton.addTarget(self, action: #selector(toggleFrameRestriction), for: .touchUpInside)
        view.addSubview(frameToggleButton)
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
        // Remove old scanning line if it exists
        scanningLine?.removeFromSuperview()
        scanningLine = UIView()
        scanningLine.backgroundColor = .red
        // Match scanning frame's width and horizontal position
        let frameX = (view.bounds.width - scanningFrameWidth) / 2
        let frameY = frameTopOffset
        scanningLine.frame = CGRect(x: frameX, y: frameY, width: scanningFrameWidth, height: 2)
        view.addSubview(scanningLine)
        
        // Create animation within scanning frame
        scanningLineAnimation = CABasicAnimation(keyPath: "position.y")
        scanningLineAnimation.fromValue = frameY + 1
        scanningLineAnimation.toValue = frameY + scanningFrameHeight - 1
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

    @objc private func dismissScanner() {
        isPresented = false
    }

    @objc private func toggleFlashlight() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                if device.torchMode == .on {
                    device.torchMode = .off
                } else {
                    try device.setTorchModeOn(level: 1.0)
                }
                device.unlockForConfiguration()
            } catch {
                print("Error toggling flashlight: \(error.localizedDescription)")
            }
        }
    }

    @objc private func toggleCamera() {
        switchCamera()
    }

    @objc private func toggleFrameRestriction() {
        isFrameRestricted.toggle()
        
        // Update button appearance
        if let button = view.subviews.first(where: { $0 is UIButton && $0.frame.origin.x == 20 && $0.frame.origin.y == 90 }) as? UIButton {
            let imageName = isFrameRestricted ? "rectangle.dashed" : "rectangle.dashed.badge.ellipsis"
            button.setImage(UIImage(systemName: imageName), for: .normal)
        }
        
        // Update corner markers visibility
        cornerMarkers.forEach { $0.isHidden = !isFrameRestricted }
        
        // Update scanning line visibility
        scanningLine.isHidden = !isFrameRestricted
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            
            if isFrameRestricted {
                // Convert the barcode's bounds to the preview layer's coordinate space
                let barcodeBounds = previewLayer.layerRectConverted(fromMetadataOutputRect: readableObject.bounds)
                
                // Get the scanning frame bounds
                let frameX = (view.bounds.width - scanningFrameWidth) / 2
                let frameY = frameTopOffset
                let scanningFrame = CGRect(x: frameX, y: frameY, width: scanningFrameWidth, height: scanningFrameHeight)
                
                // Only process if the barcode is within the scanning frame
                if scanningFrame.contains(barcodeBounds) {
                    processScannedCode(stringValue)
                } else {
                    // If barcode is outside the frame, restart scanning
                    captureSession.startRunning()
                }
            } else {
                // Process all barcodes when frame restriction is disabled
                processScannedCode(stringValue)
            }
        }
    }
    
    private func processScannedCode(_ stringValue: String) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        scannedCode = stringValue
        isPresented = false
        
        // Automatically trigger search after scanning
        if !stringValue.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.onScanComplete(stringValue)
            }
        }
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