//
//  UIColor+Additions.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 10/08/21.
//

import Foundation

import UIKit

extension UIColor {
  static var primary: UIColor {
    // swiftlint:disable:next force_unwrapping
    return #colorLiteral(red: 0.9843137255, green: 0.5843137255, blue: 0.5450980392, alpha: 1)
  }

  static var incomingMessage: UIColor {
    // swiftlint:disable:next force_unwrapping
    return #colorLiteral(red: 0.9591899514, green: 0.9687059522, blue: 0.9858923554, alpha: 1)//UIColor(named: "incoming-message")!
  }
}

