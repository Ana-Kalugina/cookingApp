//
//  CreateRecipeScreenViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
//swiftlint:disable all
class CreateRecipeScreenViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate {


    @IBOutlet weak var recipeImage: UIButton!
    var imagePicker: ImagePicker?
    var activeField: UITextField?
    var activeView: UITextView?
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var recipeNameField: UITextField!
    var database = Firestore.firestore()
    @IBOutlet weak var recipeDescription: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        navigationItem.prompt = " "
        recipeNameField.delegate = self
        recipeDescription.delegate = self
        registerForKeyboardNotifications()
        recipeDescription.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        recipeDescription.layer.borderWidth = 1
    }


    @IBAction func addPhotoPressed(_ sender: Any) {
        self.imagePicker!.present(from: sender as! UIView)
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


    @IBAction func saveButtonPressed(_ sender: Any) {
        add()

    }

    func add() {
        guard let recipeImage = recipeImage.imageView?.image,
            let recipeImageData = recipeImage.jpegData(compressionQuality: 1.0) else {
                return
        }
        let recipeImageName = UUID().uuidString

        let recipes = ["recipeName": recipeNameField.text, "recipeDescription": recipeDescription.text, "recipeImage": recipeImageName] as [String : Any]
        guard let curentUser = Auth.auth().currentUser?.uid else {return}
        let reference = database.collection("users").document("\(curentUser)").collection("recipes")
        //var reference = database.document("users/\(curentUser)").collection("recipes")
        reference.addDocument(data: recipes)

    }

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

}



extension CreateRecipeScreenViewController: ImagePickerDelegate {

    func didSelect(image: UIImage?) {
        //self.recipeImage.imageView?.image = image
        self.recipeImage.setImage(image, for: .normal)
    }

}


