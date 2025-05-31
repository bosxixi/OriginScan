import Foundation
import AVFoundation

class CameraPermissionService {
    static let shared = CameraPermissionService()
    private let userDefaults = UserDefaults.standard
    private let hasGrantedCameraPermissionKey = "hasGrantedCameraPermission"
    
    private init() {}
    
    var hasGrantedCameraPermission: Bool {
        get {
            userDefaults.bool(forKey: hasGrantedCameraPermissionKey)
        }
        set {
            userDefaults.set(newValue, forKey: hasGrantedCameraPermissionKey)
        }
    }
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.hasGrantedCameraPermission = true
                }
                completion(granted)
            }
        }
    }
    
    func checkCameraPermission() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: .video)
    }
} 