//
//  RegistrationViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import UIKit
import Firebase
//swiftlint:disable all
class RegistrationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var loginErrorMessage: UILabel!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var passwordErrorMessage: UILabel!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var repeatPasswordMessage: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    var imagePicker: ImagePicker?
    var database = Firestore.firestore()
    var activeField: UITextField?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        usernameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        repeatPasswordField.delegate = self
        loginErrorMessage.isHidden = true
        emailErrorMessage.isHidden = true
        passwordErrorMessage.isHidden = true
        repeatPasswordMessage.isHidden = true
        registerForKeyboardNotifications()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.changeProfileImage))
        profileImage.isUserInteractionEnabled  = true
        profileImage.addGestureRecognizer(tapGesture)
    }

    @objc func changeProfileImage(_ sender: Any) {
       // self.imagePicker!.present(from: sender as! UIImageView)
    }

    @IBAction func showPasswordPressed(_ sender: Any) {
        if passwordField.isSecureTextEntry == true {
            passwordField.isSecureTextEntry = false
        } else {
            passwordField.isSecureTextEntry = true
        }
    }
    @IBAction func showRepeatPasswordPressed(_ sender: Any) {
        if repeatPasswordField.isSecureTextEntry == true {
            repeatPasswordField.isSecureTextEntry = false
        } else {
            repeatPasswordField.isSecureTextEntry = true
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        let isValid = Validator().validate(userName: usernameField.text ?? "", userPassword: passwordField.text ?? "", email: emailField.text ?? "", repeatPassword: repeatPasswordField.text ?? "")
        if isValid {
            let profileManager = ProfileManager.shared
            print(profileManager.signed )
            createUser()
            //performSegue(withIdentifier: "saveUnwind", sender: nil)
        } else {
            let validator = Validator()
            loginErrorMessage.isHidden = false
            passwordErrorMessage.isHidden = false
            emailErrorMessage.isHidden = false
            repeatPasswordMessage.isHidden = false
            loginErrorMessage.text = validator.loginTextCheck(loginText: usernameField.text ?? "", loginErrorMessage: loginErrorMessage.text ?? "")
            emailErrorMessage.text = validator.emailTextCheck(emailText: emailField.text ?? "", emailErrorMessage: emailErrorMessage.text ?? "")
            passwordErrorMessage.text = validator.passwordTextCheck(passwordText: passwordField.text ?? "", passwordErrorMessage: passwordErrorMessage.text ?? "")
            repeatPasswordMessage.text = validator.repeatPasswordCheck(passwordText: passwordField.text ?? "", repeatPassword: repeatPasswordField.text ?? "", repeatPasswordErrorMessage: repeatPasswordMessage.text ?? "")
            print("Error")
        }
    }

    @IBAction func usernameFieldChanged(_ sender: Any) {
        let loginValidator = Validator()
        loginErrorMessage.isHidden = false
        loginErrorMessage.text = loginValidator.loginTextCheck(loginText: usernameField.text ?? "", loginErrorMessage: loginErrorMessage.text ?? "")
    }

    @IBAction func emailFieldChanged(_ sender: Any) {
        let emailValidator = Validator()
        emailErrorMessage.isHidden = false
        emailErrorMessage.text = emailValidator.emailTextCheck(emailText: emailField.text ?? "", emailErrorMessage: emailErrorMessage.text ?? "")
    }

    @IBAction func passwordFieldChanged(_ sender: Any) {
        let passwordValidator = Validator()
        passwordErrorMessage.isHidden = false
        passwordErrorMessage.text = passwordValidator.passwordTextCheck(passwordText: passwordField.text ?? "", passwordErrorMessage: passwordErrorMessage.text ?? "")
    }

    @IBAction func repeatPasswordFieldChanged(_ sender: Any) {
        let passwordValidator = Validator()
        repeatPasswordMessage.isHidden = false
        repeatPasswordMessage.text = passwordValidator.repeatPasswordCheck(passwordText: passwordField.text ?? "", repeatPassword: repeatPasswordField.text ?? "", repeatPasswordErrorMessage: repeatPasswordMessage.text ?? "")
    }
    
    func createUser() {
        let profileManager = ProfileManager.shared
        guard let loginText = usernameField.text else {fatalError()}
        guard let passwordText = passwordField.text else {fatalError()}
        guard let emailText = emailField.text else {fatalError()}
        Auth.auth().createUser(withEmail: emailText, password: passwordText) { (authResult, error) in
            if error == nil {
                self.signInUser()
                profileManager.nameSaver(value: loginText)
                profileManager.passwordSaver(value: passwordText)
                profileManager.signed(value: true)
                print(authResult?.user.displayName as Any)
                guard let currentUser = Auth.auth().currentUser?.uid else {return}
                let reference = self.database.collection("users").document("\(currentUser)")
                reference.setData(["username": loginText, "userID": currentUser])

                //reference.collection("recipes").document("newRec").setData(["name": "pizza", "des": "do smth"])
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let tabbar = (storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController) {
                    tabbar.modalPresentationStyle = .fullScreen
                    self.present(tabbar, animated: true, completion: nil)
                }
            } else if error?._code == AuthErrorCode.emailAlreadyInUse.rawValue {
                print(error?.localizedDescription as Any)
                let alert = UIAlertController(title: "Error", message: "This email is already in use", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }

    }

    func signInUser() {
        guard let passwordText = passwordField.text else {fatalError()}
        guard let emailText = emailField.text else {fatalError()}
        Auth.auth().signIn(withEmail: emailText, password: passwordText) { (authResult, error) in
            if error == nil {
                print(authResult?.user.displayName as Any)
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }

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

extension RegistrationViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.profileImage.image = image
    }
}

