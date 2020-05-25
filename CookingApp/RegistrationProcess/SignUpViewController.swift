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

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var profileMainLabel: UILabel!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    @IBOutlet weak var emailSignIn: UIButton!
    @IBOutlet weak var termsOfUseLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    var termsOfUseAreAccepted = false

    var profileManager = ProfileManager.shared
    var userDefaults = UserDefaults.standard

    var signUpLabel = UILabel()
    @IBOutlet weak var checkbox: UIButton!
    var checkBoxState = "unchecked"


    override func viewDidLoad() {
        super.viewDidLoad()
        //loginButton.isEnabled = false
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
                    print(authResult?.user.email)
                    print(authResult?.user.displayName)
                    self.profileManager.signed(value: true)
                    self.profileManager.nameSaver(value: authResult?.user.displayName)
                    print(self.profileManager.signed)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabbar = (storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController) {
                        tabbar.modalPresentationStyle = .fullScreen
                        self.present(tabbar, animated: true, completion: nil)
                    }
                    } else {
                        print(error?.localizedDescription)
                    }
                }
            }
        }

    @IBAction func emailSignInPressed(_ sender: Any) {
        if termsOfUseAreAccepted == false {
            let alert = UIAlertController(title: "Terms of use", message: "You have to read and accept terms of use before continuing!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }

    @IBAction func termsOfUsePressed(_ sender: Any) {

    }

    @IBAction func logInButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "loginSegue", sender: nil)
    }

    @IBAction func profileUnwindSegueFromTermsOfUse(segue: UIStoryboardSegue) {
        termsOfUseAreAccepted = true
        checkbox.setBackgroundImage(UIImage(named: "checkboxChecked"), for: .normal)
        checkBoxState = "checked"
        //loginButton.isEnabled = true
    }
    @IBAction func profileUnwindSegueFromSignUp(segue: UIStoryboardSegue) {

    }
    @IBAction func profileUnwindSegueFromLogIn(segue: UIStoryboardSegue) {

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
}

