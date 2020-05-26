//
//  ProfileViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        let profileManager = ProfileManager.shared
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        profileManager.signed(value: false)
        presentWelcomeVC()
    }

    func presentWelcomeVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let welcomeVC = (storyboard.instantiateViewController(withIdentifier: "welcomeVC") as? UIViewController) {
            welcomeVC.modalPresentationStyle = .fullScreen
            self.present(welcomeVC, animated: true, completion: nil)
        }
    }

}
