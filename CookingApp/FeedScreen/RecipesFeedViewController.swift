//
//  RecipesFeedViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
import JGProgressHUD
//swiftlint:disable line_length
class RecipesFeedViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var sizeForCell: CGSize! = CGSize(width: 300, height: 400)
    var recipes = [Recipe]()
    var usersPhotos = [String: UIImage]()
    var usersNames = [String: String]()
    var usersID = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        collectionView.dataSource = self
        collectionView.delegate = self
        getRecipes()
    }
    
    func createAlert(title: String, message: String, preferredStyle: UIAlertController.Style, alertActionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func presentProgressHud() {
        let progressHud = JGProgressHUD(style: .dark)
        progressHud.textLabel.text = "Please Wait"
        progressHud.show(in: self.view)
        progressHud.dismiss(afterDelay: 2.0)
    }
    
    func getRecipes() {
        presentProgressHud()
        let userRef = Database.database.collection("\(Database.DataBaseKeys.users)")
        let dataBaseKeys = Database.DataBaseKeys.self
        userRef.addSnapshotListener(includeMetadataChanges: false) { (snapshot, error) in
            guard let snapshot = snapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { (diff) in
                self.usersID.append(diff.document.documentID)
                guard let userName = diff.document.data()["\(dataBaseKeys.username)"] as? String else {return}
                guard let userPhoto = diff.document.data()["\(dataBaseKeys.profileImageUrl)"] as? String,
                    let userPhotoUrl = URL(string: userPhoto),
                    let userData = try? Data(contentsOf: userPhotoUrl),
                    let userImage = UIImage(data: userData) else {return}
                let docID = diff.document.documentID
                self.usersNames[docID] = userName
                self.usersPhotos[docID] = userImage
            }
            for doc in self.usersID {
                userRef.document(doc).collection("\(dataBaseKeys.recipes)").addSnapshotListener(includeMetadataChanges: false) { (querySnap, error) in
                    guard let querySnap = querySnap else {
                        print("Error fetching snapshots: \(error!)")
                        return
                    }
                    querySnap.documentChanges.forEach { (diff) in
                        guard let recipeName = diff.document.data()["\(dataBaseKeys.recipeName)"] as? String else {return}
                        guard let recipeDescription = diff.document.data()["\(dataBaseKeys.recipeDescription)"] as? String else {return}
                        guard let recipePhoto = diff.document.data()["\(dataBaseKeys.recipePhotoUrl)"] as? String,
                            let recipePhotoUrl = URL(string: recipePhoto),
                            let recipeData = try? Data(contentsOf: recipePhotoUrl),
                            let recipeImage = UIImage(data: recipeData) else {return}
                        let recipe = Recipe(recipeName: recipeName, recipeDescription: recipeDescription, recipePhoto: recipeImage)
                        recipe.userPhoto = self.usersPhotos[doc]
                        recipe.userName = self.usersNames[doc]
                        self.recipes.insert(recipe, at: 0)
                    }
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

extension RecipesFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipe", for: indexPath) as? RecipesFeedCollectionViewCell else {fatalError("There is no such cellID or Class")}
        cell.recipeName.text = recipes[indexPath.row].recipeName
        cell.userPhoto.image = recipes[indexPath.row].userPhoto
        cell.recipePhoto.image = recipes[indexPath.row].recipePhoto
        cell.recipePhoto.layer.cornerRadius = 25
        cell.userPhoto.layer.cornerRadius = cell.userPhoto.bounds.width/2
        cell.userName.text = recipes[indexPath.row].userName
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForCells()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let recipeDescriptionVC = RecipeDescriptionViewController(recipeName: recipes[indexPath.row].recipeName, recipePhoto: recipes[indexPath.row].recipePhoto, recipeDescription: recipes[indexPath.row].recipeDescription)
        navigationController?.pushViewController(recipeDescriptionVC, animated: true)
    }
    
    func sizeForCells() -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            sizeForCell = CGSize(width: 260, height: 270)
        } else {
            sizeForCell = CGSize(width: 300, height: 400)
        }
        return sizeForCell
    }
}
