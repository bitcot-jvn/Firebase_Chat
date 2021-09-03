//
//  ChatVC+ExtensionMedia.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 10/08/21.
//


import Firebase
import Photos
import Firebase
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth
import SDWebImage
import MBCircularProgressBar

//MARK: UIImagePickerControllerDelegate,UINavigationControllerDelegate
extension ChatVC: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    func addCameraBarButton() {
        let cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .white
        cameraItem.image = UIImage(systemName: "camera")
        cameraItem.addTarget(
            self,
            action: #selector(cameraButtonPressed),
            for: .primaryActionTriggered)
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    @objc private func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .savedPhotosAlbum
        }
        picker.mediaTypes = ["public.image", "public.movie"]
        present(picker, animated: true)
    }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)
        //        if let asset = info[.phAsset] as? PHAsset {
        //            let size = CGSize(width: 500, height: 500)
        //            PHImageManager.default().requestImage(
        //                for: asset,
        //                targetSize: size,
        //                contentMode: .aspectFit,
        //                options: nil
        //            ) { result, _ in
        //                guard let image = result else {
        //                    return
        //                }
        //                self.sendPhoto(image)
        //            }
        //        } else
        if let image = info[.originalImage] as? UIImage {
            sendPhoto(image)
        }else if let video = info[.mediaURL] as? URL{
            sendVideo(video)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    private func sendPhoto(_ image: UIImage) {
        isSendingPhoto = true
        uploadImage(image, to: self.channelId) { [weak self] url in
            guard let self = self else { return }
            self.isSendingPhoto = false
            guard let url = url else {
                return
            }
            let message = Message(user: self.user!, downloadURL: url, mediaType: "image", read: false)
            self.save(message){
              //  PushNotificationSender.instance.sendPushNotification(to: "", title: "Sender message", body: "image", data: message)
            }
        }
    }
    
    private func sendVideo(_ video: URL) {
        isSendingPhoto = true
        let metadata = StorageMetadata()
        metadata.contentType = "video/MOV"
        let name = video.absoluteURL.lastPathComponent
        let data = try? Data(contentsOf: video)
        let imageReference = storage.child("\(channelId)/\(name)")
        self.uploadeImageVideoProgress.isHidden = false
        let uploadTask = imageReference.putData(data!, metadata: metadata) { _, _ in
            imageReference.downloadURL { url, error in
                self.uploadeImageVideoProgress.isHidden = true
                guard let url = url else{
                    self.showAnnousment(error?.localizedDescription ?? "Quota has been exceeded for this project")
                    return
                }
                self.isSendingPhoto = false
                print(url)
                let message = Message(user: self.user!, downloadURL: url, mediaType: "video", read: false)
                self.save(message){
                   // PushNotificationSender.instance.sendPushNotification(to: "", title: "Sender message", body: message.content, data: message)
                }
            }
        }
        //here we can cancel , pause, resume use upload task
        uploadTask.observe(.progress) { snapshot in
            print("uploade video Progress:==",snapshot.progress?.fractionCompleted as Any)
            self.uploadeImageVideoProgress.progress = Float(snapshot.progress!.fractionCompleted)
        }
        
    }
    
    private func uploadImage(
        _ image: UIImage,
        to channel: String,
        completion: @escaping (URL?) -> Void
    ) {
        guard
            let data = image.jpegData(compressionQuality: 0.4)
        else {
            return completion(nil)
        }
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        let imageReference = storage.child("\(channelId)/\(imageName)")
        self.uploadeImageVideoProgress.isHidden = false
        let uploadTask = imageReference.putData(data, metadata: metadata) { _, _ in
            imageReference.downloadURL { url, error in
                self.uploadeImageVideoProgress.isHidden = true
                guard let url = url else{
                    self.showAnnousment(error?.localizedDescription ?? "Quota has been exceeded for this project")
                    return
                }
                print(error?.localizedDescription as Any)
                completion(url)
            }
        }
        uploadTask.observe(.progress) { snapshot in
            print("uploade image Progress:==",snapshot.progress?.fractionCompleted as Any)
            self.uploadeImageVideoProgress.progress = Float(snapshot.progress!.fractionCompleted)
        }
    }
    
    
    func setImage(imgUrl: URL, imageType: String = "", progressBar: MBCircularProgressBarView = MBCircularProgressBarView(), closer: ((UIImage)-> Void)? = nil) {
        var Newimage = UIImage()
        if  SDImageCache.shared.diskImageDataExists(withKey: "\(imgUrl)"){
            progressBar.isHidden = true
            closer?(SDImageCache.shared.imageFromDiskCache(forKey: "\(imgUrl)") ?? #imageLiteral(resourceName: "icons8-full-image-64"))
        }else{
            SDWebImageDownloader.shared.downloadImage(with: imgUrl, options: .lowPriority) { receivedSize, expectedSize, url in
                DispatchQueue.main.async {
                    progressBar.isHidden = false
                    progressBar.value = CGFloat(receivedSize)
                    progressBar.maxValue = CGFloat(expectedSize)
                }
            } completed: { image, downloaddata, error, finished in
                if finished{
                    if image != nil{
                        DispatchQueue.main.async {
                            SDImageCache.shared.store(image, forKey: "\(imgUrl)")
                            Newimage = image ?? #imageLiteral(resourceName: "icons8-full-image-64")
                            progressBar.isHidden = true
                            closer?(Newimage)
                        }
                    }
                }else{
                    progressBar.isHidden = false
                    Newimage = #imageLiteral(resourceName: "icons8-full-image-64")
                }
            }
            
        }
        
    }
   
}
