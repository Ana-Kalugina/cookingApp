//
//  CreateRecipeScreenViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
import JGProgressHUD
//swiftlint:disable all
class CreateRecipeScreenViewController: UIViewController {

    var imagePicker: ImagePicker?
    var activeField: UITextField?
    var activeView: UITextView?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeNameField: UITextField!
    var database = Firestore.firestore()
    @IBOutlet weak var recipeDescription: UITextView!
    @IBOutlet weak var recipeImageView: UIImageView!
    @IBOutlet weak var removeBtn: UIBarButtonItem!
    var color = UIColor(named: "textFieldColor")


    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        navigationItem.prompt = " "
        recipeNameField.delegate = self
        recipeDescription.delegate = self
        registerForKeyboardNotifications()
        recipeNameField.backgroundColor = color
        recipeDescription.backgroundColor = color
        recipeDescription.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        recipeDescription.layer.borderWidth = 1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateRecipeScreenViewController.changeRecipeImage))
        recipeImageView.isUserInteractionEnabled  = true
        recipeImageView.addGestureRecognizer(tapGesture)
        recipeImageView.image = UIImage(named: "addImage")
        recipeDescription.translatesAutoresizingMaskIntoConstraints = false
        recipeDescription.sizeToFit()
    }

    @objc func changeRecipeImage() {
        self.imagePicker!.present(from: self.view!)
    }

    @IBAction func saveButtonPressed(_ sender: Any) {
        let isValid = Validator().recipeValidate(recipeName: recipeNameField.text ?? "", recipeDescription: recipeDescription.text ?? "", recipePhoto: recipeImageView)
        if isValid {
            presentProgressHud()
            addRecipeToStorage()
        }
        else {
            createAlert(title: "Error", message: "Please do not leave fields blank ", preferredStyle: .alert, alertActionTitle: "Ok")
        }
    }

    @IBAction func removeButtonPressed(_ sender: Any) {
        clean()
    }

    func addRecipeToStorage() {
        guard let profileImg = self.recipeImageView.image,
            let imageData = profileImg.jpegData(compressionQuality: 1.0) else {
                return
        }
        let recipePhotoID = UUID().uuidString
        let storageReference = Storage.storage().reference(forURL: "gs://cookingapp-ana23.appspot.com").child("recipeImage").child(recipePhotoID)
        storageReference.putData(imageData, metadata: nil) { (metaData, error) in
            if error != nil {
                return
            }
            storageReference.downloadURL { (url, error) in
                if error != nil {
                    return
                }
                guard let recipeUrl = url?.absoluteString else {return}
                guard let recipeName = self.recipeNameField.text else {return}
                guard let recipeDescription = self.recipeDescription.text else {return}
                
                Database.sendDataToDatabase(uid:recipePhotoID, photoUrl: recipeUrl, recipeName: recipeName, recipeDescription: recipeDescription)
                self.clean()
                self.tabBarController?.selectedIndex = 0
            }
        }
        
    }
    func clean() {
        self.recipeImageView.image = #imageLiteral(resourceName: "addImage")
        self.recipeNameField.text = ""
        self.recipeDescription.text = ""
    }

    func presentProgressHud() {
        let progressHud = JGProgressHUD(style: .dark)
        progressHud.textLabel.text = "Loading"
        progressHud.show(in: self.view)
        progressHud.dismiss(afterDelay: 2.0)
    }

    func createAlert(title: String, message: String, preferredStyle: UIAlertController.Style, alertActionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

extension CreateRecipeScreenViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.recipeImageView.image = image ?? UIImage(named: "addImage")
    }
}

extension CreateRecipeScreenViewController: UITextFieldDelegate, UITextViewDelegate {

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
