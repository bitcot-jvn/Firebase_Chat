//
//  ViewController.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 09/08/21.
//

import UIKit
import GoogleSignIn
import Firebase

class LoginVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    //MARK: Default Function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //MARK: Ations
    @IBAction func googleSignInPressed(_ sender: Any) {
        self.setSocialLogin()
    }
    
    func logInFireBase(credential: AuthCredential){
        Auth.auth().signIn(with: credential) { authResult, error in
            if let err = error{
                print(err.localizedDescription)
                return
            }
            guard let _ = authResult else{
                return
            }
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "UserListVC") as! UserListVC
            self.navigationController?.pushViewController(vc, animated: false)
            
        }
    }
    
    func setSocialLogin(){
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let authentication = user?.authentication, let idToken = authentication.idToken else {
                print("fail")
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            print(credential)
            self.logInFireBase(credential: credential)
        }
    }
}

