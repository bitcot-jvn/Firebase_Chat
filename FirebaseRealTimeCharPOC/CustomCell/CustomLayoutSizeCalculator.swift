//
//  CustomLayoutSizeCalculator.swift
//  ChatExample
//
//  Created by Vignesh J on 01/05/21.
//  Copyright © 2021 MessageKit. All rights reserved.
//

import UIKit
import MessageKit
import Foundation

class CustomLayoutSizeCalculator: CellSizeCalculator {

    var cellTopLabelVerticalPadding: CGFloat = 15
    var cellTopLabelHorizontalPadding: CGFloat = 15
    var cellDateLabelHorizontalPadding: CGFloat = 80
    var cellDateLabelBottomPadding: CGFloat = 8
    
    var cellReadLabelHorizontalPadding: CGFloat = 16
    var cellReadLabelBottomPadding: CGFloat = 8
    
    
    var cellMessageContainerHorizontalPadding: CGFloat = 10
    var cellMessageContainerExtraSpacing: CGFloat = 0
    var cellMessageContentVerticalPadding: CGFloat = 16
    var cellMessageContentHorizontalPadding: CGFloat = 20
    
    var messagesLayout: MessagesCollectionViewFlowLayout {
        return self.layout as! MessagesCollectionViewFlowLayout
    }
    
    var messageContainerMaxWidth: CGFloat {
        self.messagesLayout.itemWidth -
            self.cellMessageContainerHorizontalPadding -
            self.cellMessageContainerExtraSpacing
    }
    
    var messagesDataSource: MessagesDataSource {
        self.messagesLayout.messagesDataSource
    }
    
    
    init(layout: MessagesCollectionViewFlowLayout? = nil) {
        super.init()
        self.layout = layout
    }
    

    
    override func sizeForItem(at indexPath: IndexPath) -> CGSize {
        let dataSource = self.messagesDataSource
        let message = dataSource.messageForItem(at: indexPath,
                                                in: self.messagesLayout.messagesCollectionView)
        let itemHeight = self.cellContentHeight(for: message,
                                                at: indexPath)
        return CGSize(width: self.messagesLayout.itemWidth,
                      height: itemHeight)
    }
    
    
    

    func cellContentHeight(for message: MessageType,
                           at indexPath: IndexPath) -> CGFloat {
        switch message.kind {
        case .photo( _):
            return CGFloat()
        case .text( _):
        return self.cellTopLabelSize(for: message,
                                     at: indexPath).height +
                   self.cellMessageBottomLabelSize(for: message,
                                          at: indexPath).height +
                   self.messageContainerSize(for: message,
                                             at: indexPath).height
        default:
            return CGFloat()
        }
        
    }
    
    // MARK: - Top cell Label

    func cellTopLabelSize(for message: MessageType,
                          at indexPath: IndexPath) -> CGSize {
        guard let attributedText = self.messagesDataSource.cellTopLabelAttributedText(for: message,
                                                                                      at: indexPath) else {
            return .zero
        }
        
        let maxWidth = self.messagesLayout.itemWidth - self.cellTopLabelHorizontalPadding
        let size = attributedText.size(consideringWidth: maxWidth)
        let height = size.height + self.cellTopLabelVerticalPadding
        
        return CGSize(width: maxWidth,
                      height: height)
    }
    
    func cellTopLabelFrame(for message: MessageType,
                           at indexPath: IndexPath) -> CGRect {
        let size = self.cellTopLabelSize(for: message,
                                         at: indexPath)
        guard size != .zero else {
            return .zero
        }
        
        let origin = CGPoint(x: self.cellTopLabelHorizontalPadding / 2,
                             y: 0)
        
        
        return CGRect(origin: origin,
                      size: size)
    }
    
    func cellMessageBottomLabelSize(for message: MessageType,
                                    at indexPath: IndexPath) -> CGSize {
        guard let attributedText = self.messagesDataSource.messageBottomLabelAttributedText(for: message,
                                                                                            at: indexPath) else {
            return .zero
        }
        var maxWidth = CGFloat()
                if  messagesDataSource.isFromCurrentSender(message: message){
                    self.cellDateLabelHorizontalPadding = 70
                    maxWidth =  self.messageContainerMaxWidth - self.cellDateLabelHorizontalPadding
                }else{
                    self.cellDateLabelHorizontalPadding = 22
                     maxWidth = self.messageContainerMaxWidth - self.cellDateLabelHorizontalPadding
                }
        return attributedText.size(consideringWidth: maxWidth)
    }
    
    func cellMessageBottomLabelFrame(for message: MessageType,
                                     at indexPath: IndexPath) -> CGRect {
        let messageContainerSize = self.messageContainerSize(for: message,
                                                             at: indexPath)
        let labelSize = self.cellMessageBottomLabelSize(for: message,
                                                        at: indexPath)
        let x = messageContainerSize.width - labelSize.width - (self.cellDateLabelHorizontalPadding / 2)
        let y = messageContainerSize.height - labelSize.height - self.cellDateLabelBottomPadding
        let origin = CGPoint(x: x,
                             y: y)
        
        return CGRect(origin: origin,
                      size: labelSize)
    }
    
    func cellRadMessageBottomLabelSize(for message: MessageType,
                                    at indexPath: IndexPath) -> CGSize {
        guard let attributedText = self.messagesDataSource.cellBottomLabelAttributedText(for: message,
                                                                                            at: indexPath) else {
            return .zero
        }
        var maxWidth = CGFloat()
            maxWidth = self.messageContainerMaxWidth - self.cellReadLabelHorizontalPadding
        return attributedText.size(consideringWidth: maxWidth)
    }
    
    func cellReadMessageBottomLabelFrame(for message: MessageType,
                                     at indexPath: IndexPath) -> CGRect {
        let messageContainerSize = self.messageContainerSize(for: message,
                                                             at: indexPath)
        let labelSize = self.cellMessageBottomLabelSize(for: message,
                                                        at: indexPath)
        let x = messageContainerSize.width - labelSize.width - (self.cellReadLabelHorizontalPadding / 2)
        let y = messageContainerSize.height - labelSize.height - self.cellReadLabelBottomPadding
        let origin = CGPoint(x: x,
                             y: y)
        
        return CGRect(origin: origin,
                      size: labelSize)
    }
    
    
    
    // MARK: - MessageContainer

    func messageContainerSize(for message: MessageType,
                              at indexPath: IndexPath) -> CGSize {
        let labelSize = self.cellMessageBottomLabelSize(for: message,
                                               at: indexPath)
        let width = labelSize.width +
            self.cellMessageContentHorizontalPadding +
            self.cellDateLabelHorizontalPadding
        let height = labelSize.height +
            self.cellMessageContentVerticalPadding +
            self.cellDateLabelBottomPadding
        
        switch message.kind {
        case .text(_):
            return CGSize(width: width,
                          height: height)
        case .photo(_):
        return CGSize(width: 240, height: 240)
        default:
            return CGSize()
        }
       
        
      
    }
    
    func messageContainerFrame(for message: MessageType,
                               at indexPath: IndexPath,
                               fromCurrentSender: Bool) -> CGRect {
        
        let y = self.cellTopLabelSize(for: message,
                                      at: indexPath).height
        let size = self.messageContainerSize(for: message,
                                             at: indexPath)
        let origin: CGPoint
        if fromCurrentSender {
            let x = self.messagesLayout.itemWidth -
                size.width -
                (self.cellMessageContainerHorizontalPadding / 2)
            origin = CGPoint(x: x, y: y)
        } else {
            origin = CGPoint(x: self.cellMessageContainerHorizontalPadding / 2,
                             y: y)
        }
        
        return CGRect(origin: origin,
                      size: size)
    }
}
