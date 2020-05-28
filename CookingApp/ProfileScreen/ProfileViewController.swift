//
//  ProfileViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    var sizeForCell: CGSize! = CGSize(width: 150, height: 250)
    var recipes = [Recipe]()
    var user = User(userName: "")

    override func viewDidLoad() {
        super.viewDidLoad()
        getRecipe()
        getUser()
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
        if let welcomeVC = (storyboard.instantiateViewController(withIdentifier: "welcomeVC") as? UIViewController) {
            welcomeVC.modalPresentationStyle = .fullScreen
            self.present(welcomeVC, animated: true, completion: nil)
        }
    }

    func getRecipe() {
        Database.recipesReference.addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { (diff) in
                guard let recipeName = diff.document.data()["recipeName"] as? String else {return}
                guard let recipeDescription = diff.document.data()["recipeDescription"] as? String else {return}
                guard let recipePhoto = diff.document.data()["recipePhotoUrl"] as? String,
                    let recipePhotoUrl = URL(string: recipePhoto),
                    let recipeData = try? Data(contentsOf: recipePhotoUrl),
                    let recipeImage = UIImage(data: recipeData) else {return}
                let recipe = Recipe(recipeName: recipeName, recipeDescription: recipeDescription, recipePhoto: recipeImage)
                self.recipes.append(recipe)
                self.collectionView.reloadData()
            }
        }
    }

    func getUser() {
        Database.userReference.getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            guard let username = snapshot.data()?["username"] as? String else {return}
            guard let userPhoto = snapshot.data()?["profileImageUrl"] as? String,
            let userPhotoUrl = URL(string: userPhoto),
            let userPhotoData = try? Data(contentsOf: userPhotoUrl),
                let userImage = UIImage(data: userPhotoData) else {return}
            self.userNameLabel.text = username
            self.profileImageView.image = userImage
        }
    }

}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "profileCell", for: indexPath) as? ProfileCollectionViewCell else {fatalError("There is no such cellID or Class")}
        cell.recipeName.text = recipes[indexPath.row].recipeName
        cell.recipeImage.image = recipes[indexPath.row].recipePhoto
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForCells()
    }

    func sizeForCells() -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            sizeForCell = CGSize(width: 260, height: 270)
        } else {
            sizeForCell = CGSize(width: 150, height: 250)
        }
        return sizeForCell
    }
}
