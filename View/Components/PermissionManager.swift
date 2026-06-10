//
//  PermissionManager.swift
//  ChemVista
//
//  Created by Shailesh on 24/04/26.
//

import AVFoundation
internal import Photos
import UIKit
import Observation

@Observable
class PermissionManager {
    static let shared = PermissionManager()
    
    enum PermissionType {
        case camera
        case photoLibrary
    }
    
    var cameraStatus: AVAuthorizationStatus = .notDetermined
    var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    
    init() {
        refreshStatuses()
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { _ in
            self.refreshStatuses()
        }
    }
    
    func refreshStatuses() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryStatus = PHPhotoLibrary.authorizationStatus(for: .addOnly)
    }
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                self.refreshStatuses()
                completion(granted)
            }
        }
    }
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            DispatchQueue.main.async {
                self.refreshStatuses()
                completion(status == .authorized || status == .limited)
            }
        }
    }
    
    func openSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl)
            }
        }
    }
}
