//
//  ChatVC+Extenion.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 10/08/21.
//

import Foundation
import MessageKit
import AVKit
import MBCircularProgressBar
import SDWebImage


// MARK: - MessagesDisplayDelegate
extension ChatVC: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .lightGray
    }
    
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatVC: MessagesLayoutDelegate {
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }

    func messageBottomLabelAttributedText(for message: MessageKit.MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM, YYYY"
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
}

// MARK: - MessagesDataSource
extension ChatVC: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> SenderType {
        return Sender(senderId: user?.uid ?? "", displayName: user?.displayName ?? "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let msg = message as? Message, let url = msg.downloadURL else { return}
        imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        imageView.image = #imageLiteral(resourceName: "icons8-full-image-64")
        imageView.contentMode = .scaleAspectFill
        let progressBar = MBCircularProgressBarView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        progressBar.backgroundColor = .clear
        progressBar.progressAngle = 95
        progressBar.progressColor = .white
        progressBar.progressStrokeColor = .darkGray
        progressBar.showValueString = false
        progressBar.progressLineWidth = 3.0
        imageView.addSubview(progressBar)
        DispatchQueue.main.async {
            progressBar.center = CGPoint(x: imageView.bounds.height/2, y: imageView.bounds.width / 2)
        }
        
        if msg.mediaType == mediaTypeIs.video.rawValue{
            self.setImage(imgUrl: url, progressBar: progressBar)
            self.getThumbnailFromUrl(url) { image in
                DispatchQueue.main.async { [self] in
                    imageView.image = image
                    
                    progressBar.center = CGPoint(x: imageView.bounds.height/2, y: imageView.bounds.width / 2)
                    imageView.addSubview(setPlayBtn(imageView))
                    progressBar.removeFromSuperview()
                }
            }
        }else{
            self.setImage(imgUrl: url, imageType: msg.mediaType!, progressBar: progressBar) { image in
                imageView.image = image
                print(imageView)
                progressBar.removeFromSuperview()
                self.setPlayBtn(imageView).removeFromSuperview()
            }
        }
    }
    
    func getThumbnailFromUrl(_ url: URL,progressBar: MBCircularProgressBarView = MBCircularProgressBarView(), _ completion: @escaping ((_ image: UIImage?)->Void)) {
        if SDImageCache.shared.diskImageDataExists(withKey: "\(url)"){
            completion(SDImageCache.shared.imageFromDiskCache(forKey: "\(url)") ?? #imageLiteral(resourceName: "icons8-full-image-64"))
        }else{
            
            DispatchQueue.global().async {
                let asset = AVAsset(url: url)
                let assetImgGenerate = AVAssetImageGenerator(asset: asset)
                let time = CMTime(seconds: 0.0, preferredTimescale: 600)
                let times = [NSValue(time: time)]
                assetImgGenerate.generateCGImagesAsynchronously(forTimes: times, completionHandler: { _, image, _, _, _ in
                    if let image = image {
                        SDImageCache.shared.store(UIImage(cgImage: image), forKey: "\(url)")
                        completion(UIImage(cgImage: image))
                    } else {
                        completion(nil)
                    }
                })
            }
        }
    }
    
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ])
    }
    
    func setPlayBtn(_ imageView: UIImageView) -> UIButton{
        let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        btn.center = CGPoint(x: imageView.bounds.height/2, y: imageView.bounds.width / 2)
        btn.backgroundColor = .clear
        btn.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        btn.tintColor = .black
        btn.layer.cornerRadius = btn.bounds.height / 2
        return btn
    }
    
}

extension ChatVC: MessageCellDelegate{
    func didTapImage(in cell: MessageCollectionViewCell) {
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let message = messages[indexPath.section]
            if message.mediaType == mediaTypeIs.video.rawValue{
                guard let videoUrl = message.downloadURL else{
                    return
                }
                let player = AVPlayer(url: videoUrl)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }else if message.mediaType == mediaTypeIs.image.rawValue{
                self.setImage(imgUrl: message.downloadURL!) { image in
                    self.imageTapped(image: image)
                }
                   
                    
            }
        }
    }
    
    func imageTapped(image: UIImage){
        
        let newImageView = UIImageView(image: image)
        newImageView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height + messageInputBar.bounds.height)
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        self.messageInputBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
        self.messageInputBar.isHidden = false
    }
    
}