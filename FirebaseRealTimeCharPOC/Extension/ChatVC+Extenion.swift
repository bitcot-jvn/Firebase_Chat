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
        return isFromCurrentSender(message: message) ? .white : #colorLiteral(red: 0.1561771631, green: 0.1867688, blue: 0.3026349545, alpha: 1)
    }

    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        let size = CGSize(width: messagesCollectionView.frame.width, height: 30)
            if section == 0 {
              return size
            }
            let currentIndexPath = IndexPath(row: 0, section: section)
            let lastIndexPath = IndexPath(row: 0, section: section - 1)
            let lastMessage = messageForItem(at: lastIndexPath, in: messagesCollectionView)
            let currentMessage = messageForItem(at: currentIndexPath, in: messagesCollectionView)
            if currentMessage.sentDate.isInSameDayOf(date: lastMessage.sentDate) {
              return .zero
            }

            return size
    }
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        let header = messagesCollectionView.dequeueReusableHeaderView(MessageDateHeaderView.self, for: indexPath)
        header.lblDate?.text = MessageKitDateFormatter.shared.string(from: messages[indexPath.section].sentDate)
        return header
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
        formatter.dateFormat = "hh:mm a"
        let dateString = formatter.string(from: message.sentDate)
        if isFromCurrentSender(message: message){
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2),NSAttributedString.Key.foregroundColor: UIColor.white])
        }else{
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2),NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func textCellSizeCalculator(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CellSizeCalculator? {
       return self.textMessageSizeCalculator
   }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    
        if isFromCurrentSender(message: message){
            if messages[indexPath.section].read == false{
                return NSAttributedString(string: "✓", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.white])
            }else{
                return NSAttributedString(string: "✓✓", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.white])
            }
           
        }else{
            return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
       
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

    func textCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(CustomTextMessageContentCell.self,
                                                              for: indexPath)
        
        cell.configure(with: message,
                       at: indexPath,
                       in: messagesCollectionView,
                       dataSource: self,
                       and: self.textMessageSizeCalculator)
        
        return cell
    }
    
    func photoCell(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UICollectionViewCell? {
        let cell = messagesCollectionView.dequeueReusableCell(CustomTextMessageContentCell.self,
                                                              for: indexPath)
        cell.configure(with: message,
                       at: indexPath,
                       in: messagesCollectionView,
                       dataSource: self,
                       and: self.textMessageSizeCalculator)

        return cell
    }

    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let msg = message as? Message, let url = msg.downloadURL else { return}
        imageView.image = #imageLiteral(resourceName: "icons8-full-image-64")
        imageView.contentMode = .scaleAspectFill
        let progressBar = MBCircularProgressBarView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        progressBar.backgroundColor = .clear
        progressBar.progressAngle = 95
        progressBar.progressColor = .white
        progressBar.progressStrokeColor = .gray
        progressBar.showValueString = false
        progressBar.progressLineWidth = 3.0
        imageView.addSubview(progressBar)
        DispatchQueue.main.async {
            progressBar.center = CGPoint(x: imageView.bounds.height/2, y: imageView.bounds.width / 2)
        }

        switch message.kind {
        case .photo(_):
            self.setImage(imgUrl: url, imageType: msg.mediaType!, progressBar: progressBar) { image in
                imageView.image = image
                progressBar.removeFromSuperview()
            }
            break
        case .video(_):
            self.setImage(imgUrl: url, progressBar: progressBar)
            self.getThumbnailFromUrl(url) { image in
                DispatchQueue.main.async {
                    imageView.image = image
                    progressBar.center = CGPoint(x: imageView.bounds.height/2, y: imageView.bounds.width / 2)
                    progressBar.removeFromSuperview()
                }
            }
            break
        default:
            break
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

}

extension ChatVC: MessageCellDelegate{

    func didTapMessage(in cell: MessageCollectionViewCell) {
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

