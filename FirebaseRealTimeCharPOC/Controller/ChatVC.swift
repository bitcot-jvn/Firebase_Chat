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
    var typoingTimer: Timer? = nil
    lazy var textMessageSizeCalculator: CustomTextLayoutSizeCalculator = CustomTextLayoutSizeCalculator()
    var uploadeImageVideoProgress = UIProgressView()
    var reference: CollectionReference?
    var onlinesRef = Database.database().reference(withPath: "online")//DatabaseReference()
    let storage = Storage.storage().reference()
    var messages: [Message] = []{
        didSet{
                DispatchQueue.main.async {
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem()
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
    var arrUnReadDocuments = [QueryDocumentSnapshot]()
    var arrQueryDocumentSnapshot = [QueryDocumentSnapshot]()
    var layout = MessagesCollectionViewFlowLayout()
    var userOnline = false
    deinit {
        messageListener?.remove()
        //NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: Default Funtions
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "back"), style: .plain, target: self, action: #selector(btnBack))
        NotificationCenter.default.addObserver(self, selector: #selector(setOnlineStatus), name: .onlineStatus, object: nil)
        self.messagesCollectionView.register(UINib(nibName: "MessageDateHeaderView", bundle: .main), forSupplementaryViewOfKind: MessagesCollectionView.elementKindSectionHeader, withReuseIdentifier: "MessageDateHeaderView")
        self.setOnlineStatus()
        self.setUpMessageView()
        self.addCameraBarButton()
        self.listenToMessages()
    }
    
    
    @objc  func setOnlineStatus(){
        let currentUser = onlinesRef.child(self.user!.uid)
        currentUser.setValue(self.user?.uid)
        currentUser.onDisconnectRemoveValue()
        onlinesRef.observe(.value) { snap in
            print("description",snap.childrenCount.description)
            //static id set user online show other user id
            if self.user?.uid != "wyVTpc2bXFcVm6Jkyta3OnplTLG2"{
                if snap.hasChild("wyVTpc2bXFcVm6Jkyta3OnplTLG2"){
                    self.userOnline = true
                    self.navigationItem.setTitle(title: self.user?.displayName ?? "", subtitle: "", isOnline: true)
                }else{
                    self.userOnline = false
                    self.navigationItem.setTitle(title: self.user?.displayName ?? "", subtitle: "", isOnline: false)
                }
            }else if self.user?.uid != "E6GgtSVM5PZCdzzFkPA9yNZ4vQj1"{
                if snap.hasChild("E6GgtSVM5PZCdzzFkPA9yNZ4vQj1"){
                    self.userOnline = true
                    self.navigationItem.setTitle(title: self.user?.displayName ?? "", subtitle: "", isOnline: true)
                }else{
                    self.userOnline = false
                    self.navigationItem.setTitle(title: self.user?.displayName ?? "", subtitle: "", isOnline: false)
                }
            }
        }
    }
    
    @objc func btnBack(){
        guard let user =  Auth.auth().currentUser else{
            return
        }
        let userRef = Database.database().reference(withPath: "online")
        userRef.child(user.uid).removeValue()
        self.typing(isTyping: false,typingUserIs: "")
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: function
    private func setUpMessageView() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.messageInputBar.inputTextView.delegate = self
        self.messageInputBar.delegate = self
        self.messagesCollectionView.register(CustomTextMessageContentCell.self)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        layout = messagesCollectionView.collectionViewLayout as! MessagesCollectionViewFlowLayout
        layout.sectionHeadersPinToVisibleBounds = true
        layout.photoMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.videoMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.photoMessageSizeCalculator.incomingAvatarSize = .zero
        layout.videoMessageSizeCalculator.incomingAvatarSize = .zero
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        layout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)))
        layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)))
        layout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 180, bottom: 0, right: 0)))
        layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)))
        layout.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        layout.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
        messagesCollectionView.showsVerticalScrollIndicator = false
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.inputTextView.tintColor = .black
        messageInputBar.inputTextView.backgroundColor = .white
        messageInputBar.inputTextView.textColor = .black
        messageInputBar.inputTextView.layer.cornerRadius = 8.0
        messageInputBar.inputTextView.font = UIFont(name: "Raleway-SemiBold", size: 14.0)
        messageInputBar.backgroundView.backgroundColor = .primary
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleShadowColor(.white, for: .normal)
        self.textMessageSizeCalculator = CustomTextLayoutSizeCalculator(layout: layout)
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
        //read message change status
        if message.sender.senderId != currentSender().senderId{
            if message.read == false{
                self.arrUnReadDocuments.append(change.document)
            }
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
            if self.userOnline{
                if message.typingUserIs != currentSender().senderId && message.is_typing == true{
                    //check typing user here
                    print("sender ki id, ",message.sender.senderId,"my idis: ,",currentSender().senderId)
                    self.navigationItem.setTitle(title: self.user?.displayName ?? "", subtitle: "typing...", isOnline: userOnline)
                }else{
                    self.navigationItem.setTitle(title: self.user?.displayName ?? "", subtitle: "", isOnline: userOnline)
                    self.isSend = false
                    //modify read messages here
                    if message.sender.senderId == currentSender().senderId{
                        let _ =  self.messages.contains { existmessage in
                            if existmessage.id == message.id{
                                let index = self.messages.firstIndex(of: existmessage)
                                self.messages.remove(at: index!)
                                self.messages.insert(message, at: index!)
                                DispatchQueue.main.async {
                                    self.messagesCollectionView.reloadData()
                                }
                                return true
                            }else{
                                return false
                            }
                        }
                        print(message)
                    }
                }
            }else{
                print(" is offline user")
            }
        case .removed:
            print(" is remove")
            print(message)
            let index = self.messages.firstIndex(of: message)
            self.messages.remove(at: index!)
            
        default:
            break
        }
    }
    
    private func insertNewMessage(_ message: Message) {
        if message.sender.senderId != currentSender().senderId{
            if !message.read!{
                self.arrUnReadDocuments.forEach { document in
                    document.reference.updateData(["read": true])
                }
            }
        }
        if messages.contains(message) {
            return
        }
        messages.append(message)
    }
    
    func save(_ message: Message, closer: (()-> Void)? = nil) {
        reference?.addDocument(data: message.representation) { error in
            if let error = error {
                print("Error sending message: \(error.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                closer?()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
            configureContextMenu(index: indexPath.section)
        }
    
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration{
        let identifier = "\(index)" as NSString
        let context = UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { (action) -> UIMenu? in
            var actions = [UIAction]()
            
            let Copy = UIAction(title: "Copy", image: UIImage(systemName: "doc.on.doc"),state: .off) { (_) in
                print("edit button clicked")
            }
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"),attributes: .destructive, state: .off) { (_) in
                Firestore.firestore().collection(self.receverUser!.channelName!).getDocuments { snap, error in
                   let _ = snap?.documents.filter({ document in
                        if document.documentID == self.messages[index].messageId{
                            document.reference.delete { error in
                                if error != nil{
                                    print(error?.localizedDescription ?? "error on delete msg")
                                }
                            }
                            return true
                        }else{
                            return false
                        }
                    })
                }
            }
            if self.messages[index].sender.senderId == self.user?.uid && self.messages[index].mediaType == mediaTypeIs.text.rawValue {
                actions = [Copy,delete]
            }else if self.messages[index].sender.senderId == self.user?.uid && (self.messages[index].mediaType == mediaTypeIs.image.rawValue || self.messages[index].mediaType == mediaTypeIs.video.rawValue)  {
                actions = [delete]
            }else if self.messages[index].sender.senderId == self.user?.uid{
                actions = [Copy,delete]
            }else if self.messages[index].mediaType == mediaTypeIs.text.rawValue{
                actions = [Copy]
            }
            return UIMenu(title: "Options", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: actions)
        }
        return context
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        let identifier = configuration.identifier as? String
        let index = Int(identifier!)
        let cell = messagesCollectionView.cellForItem(at: IndexPath(item: 0, section: index!)) as! CustomTextMessageContentCell
        return UITargetedPreview(view: cell.messageContainerView)
    }
    
    
}


// MARK: - InputBarAccessoryViewDelegate
extension ChatVC: InputBarAccessoryViewDelegate, UITextViewDelegate{
    // MARK: UITextViewDelegate methods
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        isSend = true
        let message = Message(user: user!, content: text,is_typing:false, typingUserIs: "", read: false, mediaType: "text" )
        processInputBar(messageInputBar,message)
    }
    
    func processInputBar(_ inputBar: InputBarAccessoryView,_ message: Message) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }

        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            DispatchQueue.main.async { [weak self] in
                self?.typing(isTyping: false, typingUserIs: "") {
                    self!.save(message){
                        DispatchQueue.main.async {
                            inputBar.sendButton.stopAnimating()
                            inputBar.inputTextView.placeholder = "Aa"
                           // PushNotificationSender.instance.sendPushNotification(to: "", title: "Sender message", body: message.content, data: message)
                        }
                    }
                }
                inputBar.inputTextView.text = ""
                inputBar.inputTextView.resignFirstResponder()
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        if text != ""{
            if !isSend {
                typoingTimer = Timer.scheduledTimer(timeInterval: 0.10,target: self,selector: #selector(getHints),userInfo: ["text": text], repeats: false)
            }
        }else{
            self.typing(isTyping: false,typingUserIs: "")
        }
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didSwipeTextViewWith gesture: UISwipeGestureRecognizer) {
        self.typoingTimer?.invalidate()
        self.typing(isTyping: false,typingUserIs: "")
    }
    
    
    func typing(isTyping: Bool,typingUserIs: String, complition: (() -> Void)? = nil){
            let document = self.lastDocumentId
            document?.reference.updateData(["is_typing": isTyping, "typingUserIs": currentSender().senderId])
            complition?()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        _ = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
//       print(keyboardHeight)
        self.typoingTimer?.invalidate()
        self.typing(isTyping: false,typingUserIs: "")
    }
    
    
    @objc func getHints(timer: Timer) {
        self.typing(isTyping: true, typingUserIs: currentSender().senderId)
    }
}

