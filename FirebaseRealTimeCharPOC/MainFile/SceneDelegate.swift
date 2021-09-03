//
//  SceneDelegate.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 09/08/21.
//

import UIKit
import Firebase
import FirebaseFirestore


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
//        if Auth.auth().currentUser != nil {
//            OnlineOfflineService.online(for: (Auth.auth().currentUser?.uid)!, status: true){ (success) in
//                
//                print("User ==>", success)
//                
//            }
//        }
    }

    func sceneWillResignActive(_ scene: UIScene) {
//        let ref = Database.database().reference.child("isOnline").child(user)
//               ref.setValue(false) // NO
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        guard let user =  Auth.auth().currentUser else{
            return
        }
        let currentUser = Database.database().reference(withPath: "online").child(user.uid)
        currentUser.setValue(user.uid)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        guard let user =  Auth.auth().currentUser else{
            return
        }
        let userRef = Database.database().reference(withPath: "online")
        userRef.child(user.uid).removeValue()
    }
    
    

}

