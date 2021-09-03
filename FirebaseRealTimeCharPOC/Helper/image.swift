//
//  image.swift
//  
//
//  Created by BitCot Technologies on 13/08/21.
//

import Foundation
import UIKit


extension UIImage {
  func resizeImage(targetSize: CGSize) -> UIImage {
    let size = self.size
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    self.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage!
  }
}


extension UINavigationItem {
    func setTitle(title:String, subtitle:String, isOnline: Bool? = nil) {
        
        let one = UILabel()
        one.textColor = .white
        if isOnline ?? Bool(){
            let text = "● \(title)"
            let range = (text as NSString).range(of: "●")
            let attributedString = NSMutableAttributedString(string:text)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green , range: range)
            one.attributedText = attributedString
        }else{
            one.text = title
        }
        one.font = UIFont(name: "Raleway-SemiBold", size: 17)
        one.sizeToFit()
       
        let two = UILabel()
        two.text = subtitle
        two.font = UIFont(name: "Raleway-Regular", size: 12)
        two.textAlignment = .center
        two.sizeToFit()
        two.textColor = .white
        let stackView = UIStackView(arrangedSubviews: [one, two])
        stackView.distribution = .equalCentering
        stackView.axis = .vertical
        stackView.alignment = .center
        
        let width = max(one.frame.size.width, two.frame.size.width)
        stackView.frame = CGRect(x: 0, y: 0, width: width, height: 35)
        
        one.sizeToFit()
        two.sizeToFit()
        
        self.titleView = stackView
    }
}
