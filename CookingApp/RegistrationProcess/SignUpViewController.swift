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

    @IBOutlet weak var checkbox: UIButton!
    var checkBoxState = "unchecked"
    var termsOfUseAreAccepted = false
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

    @IBAction func emailSignInPressed(_ sender: Any) {
        if termsOfUseAreAccepted == false {
            createAlert(title: "Terms of Use", message: "You have to read and accept terms of use before continuing!", preferredStyle: .alert, alertActionTitle: "Ok")
        }
    }

    @IBAction func logInButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }

    @IBAction func profileUnwindSegueFromTermsOfUse(segue: UIStoryboardSegue) {
        termsOfUseAreAccepted = true
        checkbox.setBackgroundImage(UIImage(named: "checkboxChecked"), for: .normal)
        checkBoxState = "checked"
    }
    
    @IBAction func profileUnwindSegueFromSignUp(segue: UIStoryboardSegue) {

    }

    @IBAction func profileUnwindSegueFromLogIn(segue: UIStoryboardSegue) {

    }

    @IBAction func logOutUnwindSegue(segue: UIStoryboardSegue) {

    }

    @IBAction func ckeckboxChecked(_ sender: Any) {
        if checkBoxState == "unchecked" {
            checkBoxState = "checked"
            checkbox.setBackgroundImage(UIImage(named: "checkboxChecked"), for: .normal)
            termsOfUseAreAccepted = true
        } else if checkBoxState == "checked" {
            checkBoxState = "unchecked"
            checkbox.setBackgroundImage(UIImage(named: "checkboxUnchecked"), for: .normal)
            termsOfUseAreAccepted = false
        }
    }

    func presentTabBar() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabbar = (storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController) {
            tabbar.modalPresentationStyle = .fullScreen
            self.present(tabbar, animated: true, completion: nil)
        }
    }

    func createAlert(title: String, message: String, preferredStyle: UIAlertController.Style, alertActionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

