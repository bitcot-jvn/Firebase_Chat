//
//  UserListVC.swift
//  FirebaseRealTimeCharPOC
//
//  Created by BitCot Technologies on 11/08/21.
//

import UIKit
import Firebase
import ViewAnimator

class UserListVC: BaseViewController {
    
    @IBOutlet weak var tblList: UITableView!
    
    var arrUsres :[users] = []{
        didSet{
            DispatchQueue.main.async {
                self.tblList.reloadData()
                self.animateTableview()
            }
        }
    }
    let fromAnimation = AnimationType.from(direction: .right, offset: 30.0)
    let zoomAnimation = AnimationType.zoom(scale: 0.2)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Users"
        self.arrUsres = [users(name: "User1", channelName: "Demo1"),users(name: "User2", channelName: "Demo2")]
        self.tblList.tableFooterView = UIView()
        self.addLogout()
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    func animateTableview(){
        UIView.animate(views: tblList.visibleCells,
                       animations: [fromAnimation, zoomAnimation],
                       delay: 0.5)
    }
}


extension UserListVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrUsres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = self.arrUsres[indexPath.row].name
        cell.imageView?.image = UIImage(systemName: "person.circle.fill")
        cell.imageView?.tintColor = .black
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        vc.receverUser = self.arrUsres[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
}


struct users {
    var name : String?
    var channelName: String?
    //var
    init() {
    }
    
    init(name: String, channelName: String) {
        self.name = name
        self.channelName = channelName
    }
}
