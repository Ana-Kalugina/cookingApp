//
//  SignUpViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import UIKit
import Firebase
import GoogleSignIn
//swiftlint:disable line_length
class SignUpViewController: UIViewController, GIDSignInDelegate {

    var profileManager = ProfileManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
        GIDSignIn.sharedInstance()?.delegate = self
    }

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        } else {
            guard let authentication = user.authentication else { return }
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if error == nil {
                    self.profileManager.signed(value: true)
                    self.presentTabBar()
                } else {
                    print(error?.localizedDescription as Any)
                }
            }
        }
    }

    @IBAction func logInButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }

    @IBAction func signUpUnwind(segue: UIStoryboardSegue) {
        
    }

    func presentTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabbar = (storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController) {
            tabbar.modalPresentationStyle = .fullScreen
            self.present(tabbar, animated: true, completion: nil)
        }
    }
}

