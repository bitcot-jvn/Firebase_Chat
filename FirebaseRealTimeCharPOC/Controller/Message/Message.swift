//
//  Message.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 09/08/21.
//

import UIKit
import Firebase
import MessageKit
//import FirebaseFirestore

struct Message: MessageType {
    let id: String?
    var messageId: String {
        return id ?? UUID().uuidString
    }
    let content: String
    let sentDate: Date
    let sender: SenderType
    
    var kind: MessageKind {
        if let image = downloadURL {
            let mediaItem = ImageMediaItem(url: image)
            return .photo(mediaItem)
        } else {
            return .text(content)
        }
    }
    var is_typing: Bool?
    var mediaType: String?
    var image: UIImage?
    var downloadURL: URL?
    var typingUserIs: String?
    
    init(user: User, content: String, is_typing: Bool, typingUserIs: String) {
        sender = Sender(senderId: user.uid, displayName: user.email!)
        self.content = content
        self.is_typing = is_typing
        self.typingUserIs = typingUserIs
        sentDate = Date()
        id = nil
    }
    
    init(user: User, downloadURL: URL, mediaType: String) {
        sender = Sender(senderId: user.uid, displayName: user.email!)
        self.downloadURL = downloadURL
        self.mediaType = mediaType
        self.content = ""
        self.sentDate = Date()
        id = nil
    }
    
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard
            let sentDate = data["created"] as? Timestamp,
            let senderId = data["senderId"] as? String,
            let senderName = data["senderName"] as? String
        else {
            return nil
        }
        
        id = document.documentID
        self.sentDate = sentDate.dateValue()
        sender = Sender(senderId: senderId, displayName: senderName)
        self.mediaType = data["mediaType"] as? String
        self.is_typing = data["is_typing"] as? Bool
        self.typingUserIs = data["typingUserIs"] as? String
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
    }
}

// MARK: - DatabaseRepresentation
extension Message: DatabaseRepresentation {
    var representation: [String: Any] {
        var rep: [String: Any] = [
            "created": sentDate,
            "senderId": sender.senderId,
            "senderName": sender.displayName,
            
            
        ]
        rep["is_typing"] = self.is_typing
        rep["typingUserIs"] = self.typingUserIs
        rep["mediaType"] = self.mediaType
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
}

// MARK: - Comparable
extension Message: Comparable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}


//MARK: ImageMediaItem
struct ImageMediaItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}
