//
//  BaseViewController.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 11/08/21.
//

import UIKit
import Firebase
import MessageKit

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    func addLogout(){
        let add = UIBarButtonItem(image: #imageLiteral(resourceName: "logout"), style: .plain, target: self, action: #selector(btnLogOutAction(_:)))
        navigationItem.rightBarButtonItems = [add]
    }
    
    @IBAction func btnLogOutAction(_ sender: UIButton){
        self.showAnnousment("Are you sure! you want to logout") {
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                let controller = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
                let nav = UINavigationController(rootViewController: controller)
                (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window?.rootViewController = nav
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            
        }
       
        
    }
    
    func showAnnousment(_ msg: String, closer: (() -> Void)? = nil){
        let alert = UIAlertController(title: "Chat App", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { alert in
            closer!()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}


extension Date {
    func isInSameDayOf(date: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs:date)
    }
}


extension MessagesViewController{
    func showAnnousment(_ msg: String){
        let alert = UIAlertController(title: "Chat App", message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
