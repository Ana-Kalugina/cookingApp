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
class CreateRecipeScreenViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {

    //@IBOutlet weak var recipeImage: UIButton!
   // var imagePicker: ImagePicker?
    var activeField: UITextField?
    var activeView: UITextView?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeNameField: UITextField!
    var database = Firestore.firestore()
    @IBOutlet weak var recipeDescription: UITextView!
    @IBOutlet weak var recipeImageView: UIImageView!
    var selectedImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
       // self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        navigationItem.prompt = " "
        recipeNameField.delegate = self
        recipeDescription.delegate = self
        registerForKeyboardNotifications()
        recipeDescription.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        recipeDescription.layer.borderWidth = 1
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(CreateRecipeScreenViewController.changeRecipeImage))
        recipeImageView.isUserInteractionEnabled  = true
        recipeImageView.addGestureRecognizer(tapGesture)
        recipeImageView.image = UIImage(named: "addImage")
    }

    @objc func changeRecipeImage() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }

//    @IBAction func addPhotoPressed(_ sender: Any) {
//        self.imagePicker!.present(from: sender as! UIView)
//    }

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


   


    @IBAction func saveButtonPressed(_ sender: Any) {
        let isValid = Validator().recipeValidate(recipeName: recipeNameField.text ?? "", recipeDescription: recipeDescription.text ?? "", recipePhoto: recipeImageView)
        if isValid {
             add()
        }
        else {
            createAlert(title: "Error", message: "Please do not leave fields blank ", preferredStyle: .alert, alertActionTitle: "Ok")
        }
    }

    func add() {
        guard let profileImg = self.selectedImage,
            let imageData = profileImg.jpegData(compressionQuality: 1.0) else {
                return
        }
        guard let currentUser = Auth.auth().currentUser?.uid else {return}
        let storageReference = Storage.storage().reference(forURL: "gs://cookingapp-ana23.appspot.com").child("recipes").child(currentUser)
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
                self.sendDataToDatabase(uid:currentUser, photoUrl: recipeUrl, recipeName: recipeName, recipeDescription: recipeDescription )
            }
        }
        
    }

    func sendDataToDatabase(uid: String, photoUrl: String, recipeName: String, recipeDescription: String) {
        let reference = self.database.collection("users").document("\(uid)")
        reference.collection("recipes").document().setData(["recipePhotoUrl": photoUrl, "recipeName": recipeName, "recipeDescription": recipeDescription])
        self.recipeImageView.image = #imageLiteral(resourceName: "addImage")
        self.recipeNameField.text = ""
        self.recipeDescription.text = ""
        self.tabBarController?.selectedIndex = 0
        }





    // func add() {
    //        guard let recipeImage = recipeImage.imageView?.image,
    //            let recipeImageData = recipeImage.jpegData(compressionQuality: 1.0) else {
    //                return
    //        }
    //        let recipeImageName = UUID().uuidString
    //
    //        let recipes = ["recipeName": recipeNameField.text, "recipeDescription": recipeDescription.text, "recipeImage": recipeImageName] as [String : Any]
    //        guard let curentUser = Auth.auth().currentUser?.uid else {return}
    //        let reference = database.collection("users").document("\(curentUser)").collection("recipes")
    //        //var reference = database.document("users/\(curentUser)").collection("recipes")
    //        reference.addDocument(data: recipes)
    //
    //    }

    func getCollection() {
        guard let curentUser = Auth.auth().currentUser?.uid else {return}
        //        database.collection("users").document("\(curentUser)").collection("recipes").getDocuments()
        database.collection("users").document("\(curentUser)").collection("recipes").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                print(querySnapshot?.count)
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }
    }
    @IBAction func getPressed(_ sender: Any) {
        getCollection()
    }

    func createAlert(title: String, message: String, preferredStyle: UIAlertController.Style, alertActionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }


}



//extension CreateRecipeScreenViewController: ImagePickerDelegate {
//
//    func didSelect(image: UIImage?) {
//        //self.recipeImage.imageView?.image = image
//      //  self.recipeImage.setImage(image, for: .normal)
//    }
//
//}

extension CreateRecipeScreenViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            selectedImage = image
            recipeImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}


