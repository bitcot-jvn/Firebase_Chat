//
//  CustomMessageContentCell.swift
//  ChatExample
//
//  Created by Vignesh J on 01/05/21.
//  Copyright © 2021 MessageKit. All rights reserved.
//

import UIKit
import MessageKit

class CustomMessageContentCell: MessageCollectionViewCell {
    
    /// The `MessageCellDelegate` for the cell.
    weak var delegate: MessageCellDelegate?
    
    /// The container used for styling and holding the message's content view.
    var messageContainerView: MessageContainerView = {
        let containerView = MessageContainerView()
        containerView.clipsToBounds = true
        containerView.layer.masksToBounds = true
        return containerView
    }()

    /// The top label of the cell.
    var cellTopLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var cellDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    var cellRead: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .right
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.setupSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.setupSubviews()
    }
    

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellTopLabel.text = nil
        self.cellTopLabel.attributedText = nil
        self.cellDateLabel.text = nil
        self.cellDateLabel.attributedText = nil
        self.cellRead .attributedText = nil
        self.cellRead.text = nil
    }
    
    /// Handle tap gesture on contentView and its subviews.
    override func handleTapGesture(_ gesture: UIGestureRecognizer) {
        let touchLocation = gesture.location(in: self)

        switch true {
        case self.messageContainerView.frame.contains(touchLocation) && !self.cellContentView(canHandle: convert(touchLocation, to: messageContainerView)):
            self.delegate?.didTapMessage(in: self)
        case self.cellTopLabel.frame.contains(touchLocation):
            self.delegate?.didTapCellTopLabel(in: self)
        case self.cellDateLabel.frame.contains(touchLocation):
            self.delegate?.didTapMessageBottomLabel(in: self)
        case self.cellRead.frame.contains(touchLocation):
            self.delegate?.didTapMessageBottomLabel(in: self)
        case self.cellRead.frame.contains(touchLocation):
            self.delegate?.didTapMessageBottomLabel(in: self)
        default:
            self.delegate?.didTapBackground(in: self)
        }
    }

    /// Handle long press gesture, return true when gestureRecognizer's touch point in `messageContainerView`'s frame
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let touchPoint = gestureRecognizer.location(in: self)
        guard gestureRecognizer.isKind(of: UILongPressGestureRecognizer.self) else { return false }
        return self.messageContainerView.frame.contains(touchPoint)
    }
    
    func setupSubviews() {
        self.messageContainerView.layer.cornerRadius = 5
        self.contentView.addSubview(self.cellTopLabel)
        self.contentView.addSubview(self.messageContainerView)
        self.messageContainerView.addSubview(self.cellDateLabel)
        self.messageContainerView.addSubview(self.cellRead)
    }
    
    func configure(with message: MessageType,
                   at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView,
                   dataSource: MessagesDataSource,
                   and sizeCalculator: CustomLayoutSizeCalculator) {
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            return
        }
        
        
        self.cellTopLabel.frame = sizeCalculator.cellTopLabelFrame(for: message,
                                                                   at: indexPath)
        self.cellDateLabel.frame = sizeCalculator.cellMessageBottomLabelFrame(for: message,
                                                                     at: indexPath)
        self.cellRead.frame = sizeCalculator.cellReadMessageBottomLabelFrame(for: message,
                                                                     at: indexPath)
        let MessageFrame = sizeCalculator.messageContainerFrame(for: message,
                                                               at: indexPath,
                                                               fromCurrentSender: dataSource.isFromCurrentSender(message: message))
    
        self.messageContainerView.frame = MessageFrame
        self.cellTopLabel.attributedText = dataSource.cellTopLabelAttributedText(for: message,
                                                                                 at: indexPath)
        self.cellDateLabel.attributedText = dataSource.messageBottomLabelAttributedText(for: message,
                                                                                        at: indexPath)
        self.cellRead.attributedText = dataSource.cellBottomLabelAttributedText(for: message, at: indexPath)
        
        self.messageContainerView.backgroundColor = displayDelegate.backgroundColor(for: message,
                                                                                    at: indexPath,
                                                                                    in: messagesCollectionView)
        self.messageContainerView.style = displayDelegate.messageStyle(for: message, at: indexPath, in: messagesCollectionView)
        
    }

    /// Handle `ContentView`'s tap gesture, return false when `ContentView` doesn't needs to handle gesture
    func cellContentView(canHandle touchPoint: CGPoint) -> Bool {
        false
    }
    
}



extension UIView{
    func fillSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false

        let constraints: [NSLayoutConstraint] = [
            leftAnchor.constraint(equalTo: superview.leftAnchor),
            rightAnchor.constraint(equalTo: superview.rightAnchor),
            topAnchor.constraint(equalTo: superview.topAnchor),
            bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            ]
        NSLayoutConstraint.activate(constraints)
    }

    func centerInSuperview() {
        guard let superview = self.superview else {
            return
        }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            centerXAnchor.constraint(equalTo: superview.centerXAnchor),
            centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    func constraint(equalTo size: CGSize) {
        guard superview != nil else { return }
        translatesAutoresizingMaskIntoConstraints = false
        let constraints: [NSLayoutConstraint] = [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ]
        NSLayoutConstraint.activate(constraints)
        
    }
}
