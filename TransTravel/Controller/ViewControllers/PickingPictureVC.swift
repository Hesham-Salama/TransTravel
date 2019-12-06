//
//  PickingPictureVC.swift
//  TransTravel
//
//  Created by Hesham Salama on 8/2/19.
//  Copyright © 2019 Hesham Salama. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices
import SVProgressHUD


class PickingPictureVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let cameraIconName = "camera"
    let galleryIconName = "gallery"
    let cellID = "picturemethod"
    let segueID = "toprocessing"
    let pictureMethodData = ["Take a picture", "Use an image from Photos"]
    private let rowHeight : CGFloat = 60.0
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "TransTravel"
        tableView.tableFooterView = UIView()
        imagePicker.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chosenImage = sender as? UIImage, let processingVC = segue.destination as? ProcessingPictureVC {
            processingVC.pickedImage = chosenImage
        }
    }
}

extension PickingPictureVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictureMethodData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var imageName = ""
        if indexPath.row == 0 {
            imageName = cameraIconName
        } else if indexPath.row == 1 {
            imageName = galleryIconName
        }
        return makeCell(indexPath: indexPath, imageName:imageName, labelText: pictureMethodData[indexPath.row])
    }
    
    private func makeCell(indexPath: IndexPath, imageName: String, labelText: String) -> SelectPictureMethodViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! SelectPictureMethodViewCell
        cell.icon.image = UIImage(named: imageName)
        cell.label.text = labelText
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showCameraIfAuth()
        } else if indexPath.row == 1 {
            showPhotoPickerIfAuth()
        }
    }
}

extension PickingPictureVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showPhotoPickerIfAuth() {
        let authStatus = getPhotosAuthStatus()
        switch authStatus {
        case .authorized:
            presentImagePicker(sourceType: .photoLibrary)
        case .notDetermined:
            requestPhotosPermission { (isGranted) in
                if isGranted {
                    DispatchQueue.main.async {
                        self.presentImagePicker(sourceType: .photoLibrary)
                    }
                } else {
                    print("Photos Library Permission hasn't been granted")
                }
            }
        default:
            print("Photos Library Permission hasn't been granted")
        }
    }
    
    private func showCameraIfAuth() {
        let authStatus = getCameraAuthStatus()
        switch authStatus {
        case .authorized:
            presentImagePicker(sourceType: .camera)
        case .notDetermined:
            requestCameraPermission { (isGranted) in
                if isGranted {
                    DispatchQueue.main.async {
                        self.presentImagePicker(sourceType: .camera)
                    }
                } else {
                    print("Camera Permission hasn't been granted")
                }
            }
        default:
            print("Camera Permission hasn't been granted")
        }
    }
    
    fileprivate func requestPhotosPermission(completionHandler: @escaping (Bool) -> ()) {
        PHPhotoLibrary.requestAuthorization({
            (newStatus) in
            completionHandler(newStatus ==  PHAuthorizationStatus.authorized ? true : false)
        })
    }
    
    private func requestCameraPermission(completionHandler: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            completionHandler(response)
        }
    }
    
    private func getPhotosAuthStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    private func getCameraAuthStatus() -> AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    fileprivate func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(sourceType)
        {
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = false
            imagePicker.mediaTypes = [kUTTypeImage as String]
            self.present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            if let chosenImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.performSegue(withIdentifier: self.segueID, sender: chosenImage)
            }
        }
    }
}
