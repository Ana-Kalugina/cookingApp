//
//  RegistrationViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import UIKit
import Firebase
import JGProgressHUD
class RegistrationViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var loginErrorMessage: UILabel!
    @IBOutlet weak var emailErrorMessage: UILabel!
    @IBOutlet weak var passwordErrorMessage: UILabel!
    @IBOutlet weak var repeatPasswordField: UITextField!
    @IBOutlet weak var repeatPasswordMessage: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var showPasswordButton: UIButton!
    @IBOutlet weak var showRepeatPasswordButton: UIButton!
    var selectedImage: UIImage?
    var activeField: UITextField?
    var imagePicker: ImagePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.delegate = self
        passwordField.delegate = self
        emailField.delegate = self
        repeatPasswordField.delegate = self
        loginErrorMessage.isHidden = true
        emailErrorMessage.isHidden = true
        passwordErrorMessage.isHidden = true
        repeatPasswordMessage.isHidden = true
        registerForKeyboardNotifications()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.changeProfileImage))
        profileImage.isUserInteractionEnabled  = true
        profileImage.addGestureRecognizer(tapGesture)
    }

    @objc func changeProfileImage(_ sender: Any) {
        self.imagePicker!.present(from: self.view!)
    }

    @IBAction func showPasswordPressed(_ sender: UIButton) {
        if sender == showPasswordButton as UIButton {
            if passwordField.isSecureTextEntry == true {
                passwordField.isSecureTextEntry = false
            } else {
                passwordField.isSecureTextEntry = true
            }
        } else if sender == showRepeatPasswordButton as UIButton {
            if repeatPasswordField.isSecureTextEntry == true {
                repeatPasswordField.isSecureTextEntry = false
            } else {
                repeatPasswordField.isSecureTextEntry = true
            }
        }
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        view.endEditing(true)
        let isValid = Validator().validate(userName: usernameField.text ?? "", userPassword: passwordField.text ?? "", email: emailField.text ?? "", repeatPassword: repeatPasswordField.text ?? "")
        if isValid {
            presentProgressHud()
            createUser()
        } else {
            validateFields()
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

    func validateFields() {
        let validator = Validator()
        loginErrorMessage.isHidden = false
        passwordErrorMessage.isHidden = false
        emailErrorMessage.isHidden = false
        repeatPasswordMessage.isHidden = false
        loginErrorMessage.text = validator.loginTextCheck(loginText: usernameField.text ?? "", loginErrorMessage: loginErrorMessage.text ?? "")
        emailErrorMessage.text = validator.emailTextCheck(emailText: emailField.text ?? "", emailErrorMessage: emailErrorMessage.text ?? "")
        passwordErrorMessage.text = validator.passwordTextCheck(passwordText: passwordField.text ?? "", passwordErrorMessage: passwordErrorMessage.text ?? "")
        repeatPasswordMessage.text = validator.repeatPasswordCheck(passwordText: passwordField.text ?? "", repeatPassword: repeatPasswordField.text ?? "", repeatPasswordErrorMessage: repeatPasswordMessage.text ?? "")
    }

   ///User Creation

    func createUser() {
        let profileManager = ProfileManager.shared
        guard let loginText = usernameField.text else {fatalError()}
        guard let passwordText = passwordField.text else {fatalError()}
        guard let emailText = emailField.text else {fatalError()}
        
        Auth.auth().createUser(withEmail: emailText, password: passwordText) { (authResult, error) in
            if error == nil {
                AuthService.signUp(email: emailText, password: passwordText) {
                }
                profileManager.signed(value: true)
                guard let currentUser = Auth.auth().currentUser?.uid else {return}
                let storageReference = Storage.storage().reference(forURL: "gs://cookingapp-ana23.appspot.com").child("profileImage").child(currentUser)
                guard let profileImg = self.profileImage.image ?? UIImage(named: "user"),
                    let imageData = profileImg.jpegData(compressionQuality: 1.0) else {
                        return
                }
                storageReference.putData(imageData, metadata: nil) { (metaData, error) in
                    if error != nil {
                        return
                    }
                    storageReference.downloadURL { (url, error) in
                        if error != nil {
                            return
                        }
                        guard let profileImageUrl = url?.absoluteString else {return}
                        Database.pushUserInformationToDatabase(username: loginText, email: emailText, profileUrl: profileImageUrl, uid: currentUser)
                    }
                }
                self.presentTabBar()
            } else if error?._code == AuthErrorCode.emailAlreadyInUse.rawValue {
                print(error?.localizedDescription as Any)
                self.createAlert(title: "Error", message: "This email is already in use", preferredStyle: .alert, alertActionTitle: "Ok")
            }
        }
    }

    func createAlert(title: String, message: String, preferredStyle: UIAlertController.Style, alertActionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
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
}

extension RegistrationViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.profileImage.image = image ?? UIImage(named: "user")
    }
}

extension RegistrationViewController: UITextFieldDelegate {
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

