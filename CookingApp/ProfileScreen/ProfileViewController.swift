//
//  ProfileViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController {
    
    var imagePicker: ImagePicker?
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var recipesImages = [UIImage]()
    var user = User(userName: "")
    var databaseKeys = Database.DataBaseKeys.self
    var recipes = [Recipe]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imagePicker = ImagePicker(presentationController: self, delegate: self)
        collectionView.reloadData()
        collectionView.dataSource = self
        collectionView.delegate = self
        userNameLabel.font = UIFont(name: "Palatino", size: 17)
        profileImageView.layer.cornerRadius = self.profileImageView.bounds.width/2
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ProfileViewController.changeProfileImage))
        profileImageView.isUserInteractionEnabled  = true
        profileImageView.addGestureRecognizer(tapGesture)
        getRecipe()
        getUser()
    }
    
    @IBAction func segmentedControlSwitched(_ sender: Any) {
        if segmentedControl.isEnabledForSegment(at: 1) {
            tabBarController?.selectedIndex = 2
            segmentedControl.selectedSegmentIndex = 0
        }
    }
    
    @objc func changeProfileImage() {
        self.imagePicker!.present(from: self.view!)
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
        if let welcomeVC = (storyboard.instantiateViewController(withIdentifier: "welcomeVC") as? WelcomeViewController) {
            welcomeVC.modalPresentationStyle = .fullScreen
            self.present(welcomeVC, animated: true, completion: nil)
        }
    }
    
    func getRecipe() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        Database.usersReference.document(currentUserID).collection("\(self.databaseKeys.recipes)").addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { (diff) in
                guard let recipeDescription = diff.document.data()["\(self.databaseKeys.recipeDescription)"] as? String else {return}
                guard let recipeName = diff.document.data()["\(self.databaseKeys.recipeName)"] as? String else {return}
                guard let recipePhoto = diff.document.data()["\(self.databaseKeys.recipePhotoUrl)"] as? String,
                    let recipePhotoUrl = URL(string: recipePhoto),
                    let recipeData = try? Data(contentsOf: recipePhotoUrl),
                    let recipeImage = UIImage(data: recipeData) else {return}
                let recipe = Recipe(recipeName: recipeName, recipeDescription: recipeDescription, recipePhoto: recipeImage)
                self.recipes.append(recipe)
                self.recipesImages.append(recipeImage)
                self.collectionView.reloadData()
            }
        }
    }
    
    func getUser() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        Database.usersReference.document(currentUserID).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            guard let username = snapshot.data()?["\(self.databaseKeys.username)"] as? String else {return}
            guard let userPhoto = snapshot.data()?["\(self.databaseKeys.profileImageUrl)"] as? String,
                let userPhotoUrl = URL(string: userPhoto),
                let userPhotoData = try? Data(contentsOf: userPhotoUrl),
                let userImage = UIImage(data: userPhotoData) else {return}
            self.userNameLabel.text = username
            self.profileImageView.image = userImage
            self.collectionView.reloadData()
        }
    }
    
    func updateUser(profileImg: UIImage?) {
        guard let profileImg = profileImg else {return}
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        profileImg.jpegData(compressionQuality: 1.0)
        let storageReference = Storage.storage().reference(forURL: "gs://cookingapp-ana23.appspot.com").child("profileImage").child(currentUserID)
        guard let imageData = profileImg.jpegData(compressionQuality: 1.0) else {
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
                Database.database.collection("\(self.databaseKeys.users)").document(currentUserID).updateData(["\(self.databaseKeys.profileImageUrl)": profileImageUrl])
            }
        }
        
    }
}

extension ProfileViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        self.profileImageView.image = image ?? UIImage(named: "addImage")
        updateUser(profileImg: image)
    }
}


extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipesImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as? ProfileCollectionViewCell else {fatalError("There is no such cellID or Class")}
        cell.recipeImage.image = recipesImages[indexPath.row]
        cell.recipeImage.layer.cornerRadius = 20
        cell.recipeImage.layer.borderWidth = 1.0
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let recipeDescriptionVC = RecipeDescriptionViewController(recipeName: recipes[indexPath.row].recipeName, recipePhoto: recipes[indexPath.row].recipePhoto, recipeDescription: recipes[indexPath.row].recipeDescription)
        navigationController?.pushViewController(recipeDescriptionVC, animated: true)
    }
    
}
