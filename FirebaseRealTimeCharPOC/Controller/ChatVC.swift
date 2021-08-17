//
//  ChatVC.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 09/08/21.
//

import UIKit
import Firebase
import Photos
import Firebase
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore
import FirebaseAuth
import SDWebImage
import MBCircularProgressBar


class ChatVC: MessagesViewController{
    
    //MARK: Variables
    var uploadeImageVideoProgress = UIProgressView()
    var reference: CollectionReference?
    let storage = Storage.storage().reference()
    var messages: [Message] = []{
        didSet{
            if messages != oldValue{
                DispatchQueue.main.async {
                    self.messagesCollectionView.scrollToLastItem()
                }
            }
        }willSet(newValue){
            self.messages = newValue
        }
    }
    var ref: DatabaseReference!
    var messageListener: ListenerRegistration?
    let database = Firestore.firestore()
    var channelReference: CollectionReference {
        return database.collection("channels")
    }
    var channel : Channel?
    var isSendingPhoto = false {
        didSet {
            messageInputBar.leftStackViewItems.forEach { item in
                guard let item = item as? InputBarButtonItem else {
                    return
                }
                item.isEnabled = !self.isSendingPhoto
            }
        }
    }
    var channelId = String()
    var channelListener: ListenerRegistration?
    var user = Auth.auth().currentUser
    var document: QueryDocumentSnapshot?
    var documentId = String()
    var receverUser: users?
    private var localTyping = false // 2
    var isSend = false
    var lastDocumentId:QueryDocumentSnapshot?
    var arrQueryDocumentSnapshot = [QueryDocumentSnapshot]()
    
    deinit {
        messageListener?.remove()
    }
    
    //MARK: Default Funtions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = user?.displayName
        self.listenToMessages()
        self.setUpMessageView()
        self.addCameraBarButton()
    }
    
    //MARK: function
    
    private func setUpMessageView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.messageInputBar.inputTextView.delegate = self
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.videoMessageSizeCalculator.incomingAvatarSize = .zero
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
            layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)))
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)))
            layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)))
            layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            layout.sectionInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        }
        messagesCollectionView.showsVerticalScrollIndicator = false
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.black, for: .normal)
        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        self.setUploadeProgress()
    }
    
    func setUploadeProgress(){
        if #available(iOS 11.0, *) {
            let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window
            let bottomPadding = window?.safeAreaInsets.top
            uploadeImageVideoProgress.frame = CGRect(x: 0, y: (self.navigationController?.navigationBar.bounds.height)! + bottomPadding!, width: view.bounds.width , height: 10)
        }
        uploadeImageVideoProgress.isHidden = true
        uploadeImageVideoProgress.progress = 1.0
        uploadeImageVideoProgress.backgroundColor = .gray
        self.view?.addSubview(uploadeImageVideoProgress)
    }
    
    private func listenToMessages() {
        let db = Firestore.firestore().collection(receverUser!.channelName!)
        
        db.getDocuments { [self] QuerySnapshot, error in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            self.channelId = receverUser!.channelName!
            reference = database.collection(receverUser!.channelName!)//.order(by: "timeStamp")
            messageListener = reference?.order(by: "created").addSnapshotListener { [weak self] querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    self?.handleDocumentChange(change)
                }
            }
        }
    }
    
    
    private func createChannel() {
        let channel = Channel(name: (receverUser?.channelName)!)
        
        channelReference.addDocument(data: (channel.representation)) { error in
            if let error = error {
                print("Error saving channel: \(error.localizedDescription)")
            }else{
                self.listenToMessages()
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard var message = Message(document: change.document) else {
            return
        }
        self.lastDocumentId = change.document
        switch change.type {
        case .added:
            if let url = message.downloadURL {
                message.downloadURL = url
                self.insertNewMessage(message)
            } else {
                self.insertNewMessage(message)
            }
        case .modified:
            if message.typingUserIs != currentSender().senderId && message.is_typing == true{
                print("sender ki id, ",message.sender.senderId,"my idis: ,",currentSender().senderId)
                self.navigationItem.setTitle(title: self.receverUser!.name!, subtitle: "typing...")
            }else{
                self.navigationItem.setTitle(title: self.receverUser!.name!, subtitle: "")
                print("sender ki id, ",message.sender.senderId,"my idis: ,", currentSender().senderId)
                self.isSend = false
            }
        default:
            break
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        if messages.contains(message) {
            return
        }
        messages.append(message)
        messages.sort()
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        messagesCollectionView.reloadData()
        if shouldScrollToBottom {
            messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    func save(_ message: Message) {
        reference?.addDocument(data: message.representation) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }
        }
    }
}


// MARK: - InputBarAccessoryViewDelegate
extension ChatVC: InputBarAccessoryViewDelegate, UITextViewDelegate{
    // MARK: UITextViewDelegate methods
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        isSend = true
        let message = Message(user: user!, content: text,is_typing:false, typingUserIs: "" )
        self.typing(isTyping: false, typingUserIs: "") {
            self.save(message)
        }
        inputBar.inputTextView.text = ""
        inputBar.inputTextView.resignFirstResponder()
    }
    
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != ""{
            if !isSend {
                self.typing(isTyping: true, typingUserIs: currentSender().senderId)
            }
        }else{
            self.typing(isTyping: false,typingUserIs: "")
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        self.typing(isTyping: false,typingUserIs: "")
    }
    
    func typing(isTyping: Bool,typingUserIs: String, complition: (() -> Void)? = nil){
        database.collection(self.receverUser?.channelName ?? "").getDocuments(completion: { [self] snap, error in
            let document = self.lastDocumentId
            document?.reference.updateData(["is_typing": isTyping, "typingUserIs": currentSender().senderId])
            complition?()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
       let keyboardHeight = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
       print(keyboardHeight)
        self.typing(isTyping: false,typingUserIs: "")
    }
    
}
