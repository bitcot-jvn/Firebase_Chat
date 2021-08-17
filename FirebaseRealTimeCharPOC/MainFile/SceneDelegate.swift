//
//  SceneDelegate.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 09/08/21.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if Auth.auth().currentUser != nil {
            let controller = mainStoryBoard.instantiateViewController(withIdentifier: "UserListVC") as! UserListVC
            let nav = UINavigationController(rootViewController: controller)
            self.window?.rootViewController = nav
        } else {
            let controller = mainStoryBoard.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
            let nav = UINavigationController(rootViewController: controller)
            self.window?.rootViewController = nav
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

