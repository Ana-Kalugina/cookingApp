//
//  LoginViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import UIKit
import Firebase
import JGProgressHUD
class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorMessage: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    var activeField: UITextField?
    let database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        emailErrorMessage.isHidden = true
        passwordErrorMessage.isHidden = true
        emailTextField.delegate = self
        passwordTextField.delegate = self
        registerForKeyboardNotifications()
    }

    @IBAction func showPasswordPressed(_ sender: Any) {
        if passwordTextField.isSecureTextEntry == true {
            passwordTextField.isSecureTextEntry = false
        } else {
            passwordTextField.isSecureTextEntry = true
        }
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        view.endEditing(true)
        presentProgressHud()
        logInUser()
    }

    @IBAction func emailFieldChanged(_ sender: Any) {
        let emailValidator = Validator()
        emailErrorMessage.isHidden = false
        emailErrorMessage.text = emailValidator.emailTextCheck(emailText: emailTextField.text ?? "", emailErrorMessage: emailErrorMessage.text ?? "")
    }

    @IBAction func passwordFieldChanged(_ sender: Any) {
        let passwordValidator = Validator()
        passwordErrorMessage.isHidden = false
        passwordErrorMessage.text = passwordValidator.passwordTextCheck(passwordText: passwordTextField.text ?? "", passwordErrorMessage: passwordErrorMessage.text ?? "")
    }

    func logInUser() {
        let profileManager = ProfileManager.shared
        guard let emailText = emailTextField.text else {return}
        guard let passwordText = passwordTextField.text else {return}
        Auth.auth().signIn(withEmail: emailText, password: passwordText) { (authResult, error) in
            if error == nil {
                print(error?.localizedDescription as Any)
                profileManager.signed(value: true)
                self.presentTabBar()
            } else if error?._code == AuthErrorCode.wrongPassword.rawValue {
                self.createAlert(title: "Wrong password", message: "Please try again", preferredStyle: .alert, alertActionTitle: "Ok")
            } else if error?._code == AuthErrorCode.userNotFound.rawValue {
                self.createAlert(title: "Error", message: "User not found", preferredStyle: .alert, alertActionTitle: "Ok")
            }
        }
    }

    func presentProgressHud() {
        let progressHud = JGProgressHUD(style: .dark)
        progressHud.textLabel.text = "Loading"
        progressHud.show(in: self.view)
        progressHud.dismiss(afterDelay: 2.0)
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

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func registerForKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector (keyboardWasShown), name: UIResponder.keyboardDidShowNotification, object: nil)
    }

    @objc func keyboardWasShown(notification: NSNotification) {
        guard let activeField = activeField else {return}
        self.scrollView.isScrollEnabled = true
        let info: NSDictionary = notification.userInfo! as NSDictionary
        guard let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size else {return}
        let contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height, right: 0.0)

        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets

        var viewFrame: CGRect = self.view.frame
        viewFrame.size.height -= keyboardSize.height
        if !viewFrame.contains(activeField.frame.origin) {
            scrollView.scrollRectToVisible(activeField.frame, animated: true)
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
}
