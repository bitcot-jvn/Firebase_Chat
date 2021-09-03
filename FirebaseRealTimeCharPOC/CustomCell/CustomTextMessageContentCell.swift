//
//  CustomTextMessageContentCell.swift
//  ChatExample
//
//  Created by Vignesh J on 01/05/21.
//  Copyright © 2021 MessageKit. All rights reserved.
//

import UIKit
import MessageKit
import MBCircularProgressBar
import SDWebImage
import AVFoundation

class CustomTextMessageContentCell: CustomMessageContentCell {
    
    /// The label used to display the message's text.
    var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont(name: "Raleway-Medium", size: 14.0)
        
        return label
    }()
    
    var imgView: UIImageView{
        let img = UIImageView()
        img.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        return img
    }
    
    open lazy var playButtonView: PlayButtonView = {
        let playButtonView = PlayButtonView()
        return playButtonView
    }()

    open func setupConstraints() {
        imgView.fillSuperview()
        playButtonView.centerInSuperview()
        playButtonView.constraint(equalTo: CGSize(width: 35, height: 35))
    }
    
    /// The image view display the media content.
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.messageLabel.attributedText = nil
        self.messageLabel.text = nil
        self.imgView.image = nil
        (self.messageContainerView.subviews[1] as! UIImageView).image = nil
    }

    override func setupSubviews() {
       
        self.messageContainerView.addSubview(self.messageLabel)
        self.messageContainerView.addSubview(self.imgView)
        self.messageContainerView.addSubview(self.playButtonView)
        super.setupSubviews()
        setupConstraints()
    }
    
    override func configure(with message: MessageType,
                            at indexPath: IndexPath,
                            in messagesCollectionView: MessagesCollectionView,
                            dataSource: MessagesDataSource,
                            and sizeCalculator: CustomLayoutSizeCalculator) {
        super.configure(with: message,
                        at: indexPath,
                        in: messagesCollectionView,
                        dataSource: dataSource,
                        and: sizeCalculator)
        
        guard let displayDelegate = messagesCollectionView.messagesDisplayDelegate else {
            return
        }
        
        
        guard let CellDelegate  = messagesCollectionView.messageCellDelegate else {
            return
        }
        
        self.delegate = CellDelegate
    

        let calculator = sizeCalculator as? CustomTextLayoutSizeCalculator
       
        let textMessageKind = message.kind
        switch textMessageKind {
        case .text(let text), .emoji(let text):
            playButtonView.isHidden = true
            self.messageLabel.frame = calculator?.messageLabelFrame(for: message,at: indexPath) ?? .zero
            let textColor = displayDelegate.textColor(for: message, at: indexPath, in: messagesCollectionView)
            messageLabel.text = text
            messageLabel.textColor = textColor
            (self.messageContainerView.subviews[1] as! UIImageView).isHidden = true
        case .attributedText(let text):
            self.messageLabel.frame = calculator?.messageLabelFrame(for: message,at: indexPath) ?? .zero
            messageLabel.attributedText = text
        case .photo(_):
            playButtonView.isHidden = true
            (self.messageContainerView.subviews[1] as! UIImageView).isHidden = false
            self.imgView.frame = calculator?.messageLabelFrame(for: message,at: indexPath) ?? .zero
            let _ = displayDelegate.configureMediaMessageImageView((self.messageContainerView.subviews[1] as! UIImageView), for: message, at: indexPath, in: messagesCollectionView)
            break
        case .video(_):
            playButtonView.isHidden = false
            (self.messageContainerView.subviews[1] as! UIImageView).isHidden = false
            let _ = displayDelegate.configureMediaMessageImageView((self.messageContainerView.subviews[1] as! UIImageView), for: message, at: indexPath, in: messagesCollectionView)
        break
        default:
            break
        }
    }
}
