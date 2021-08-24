//
//  NavigationController.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 11/08/21.
//

import Foundation
import UIKit

extension UINavigationController{
    open override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white,NSAttributedString.Key.font: UIFont(name: "Raleway-SemiBold", size: 17)!]
        
    }
}
