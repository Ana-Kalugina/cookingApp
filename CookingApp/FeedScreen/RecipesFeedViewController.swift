//
//  RecipesFeedViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
import Kingfisher
//swiftlint:disable line_length
class RecipesFeedViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var sizeForCell: CGSize! = CGSize(width: 300, height: 400)
    var database = Firestore.firestore()
    var recipes = [Recipe]()
    var curentUser = User(userName: "")
    var imageView = UIImageView()
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()
        collectionView.dataSource = self
        collectionView.delegate = self
        //getUser()
        getUserInfo()
        getRecipe()
        getnames()

    }

    func createAlert(title: String, message: String, preferredStyle: UIAlertController.Style, alertActionTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: alertActionTitle, style: .default, handler: nil))
        self.present(alert, animated: true)
    }

    func getnames() {
        database.collection("users").addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshot = snapshot else {return}
            for document in snapshot.documents {
                guard let username = document.data()["username"] as? String,
                let userPhoto = document.data()["profilePhotoUrl"] as? String,
                let userPhotoUrl = URL(string: userPhoto),
                let userData = try? Data(contentsOf: userPhotoUrl),
                let userImage = UIImage(data: userData) else {return}
                var user = User(userName: username)
                user.userPhoto = userImage
                self.users.append(user)
            }
        }
       
    }


    func getRecipe() {

        Database.recipesReference.addSnapshotListener(includeMetadataChanges: true) { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }

            snapshot.documentChanges.forEach { diff in
                if diff.type == .added {
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
                if diff.type == .modified {
                    print("Modified recipe: \(diff.document.data())")
                }
                if diff.type == .removed {
                    print("Removed recipe: \(diff.document.data())")
                }
            }
        }
    }

    func getUserInfo() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {return}
        database.collection("users").document(currentUserID).addSnapshotListener(includeMetadataChanges: true) { (snapshot, error) in
            guard let snapshotData = snapshot?.data() else {return}
            guard let username = snapshotData["username"] as? String,
                let userPhoto = snapshotData["profileImageUrl"] as? String,
            let userPhotoUrl = URL(string: userPhoto),
            let userData = try? Data(contentsOf: userPhotoUrl),
            let userImage = UIImage(data: userData) else {return}
            self.curentUser.userName = username
            self.curentUser.userPhoto = userImage
            self.collectionView.reloadData()
        }

    }

    func getUser() {
        Database.userReference.addSnapshotListener(includeMetadataChanges: true) { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            guard let userData = snapshot.data() else {return}
            guard let userName = userData["username"] as? String else {return}
            guard let userPhoto = userData["profileImageURL"] as? String,
                let userImageUrl = URL(string: userPhoto),
                let userImageData = try? Data(contentsOf: userImageUrl),
                let userImage = UIImage(data: userImageData) else {return}
            self.curentUser.userName = userName
            self.curentUser.userPhoto = userImage
            self.collectionView.reloadData()
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
        cell.userPhoto.image = curentUser.userPhoto
        cell.recipePhoto.image = recipes[indexPath.row].recipePhoto
        cell.userName.text = curentUser.userName
        cell.layer.borderWidth = 3.0
        cell.layer.borderColor = UIColor.black.cgColor
        print(self.recipes)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForCells()
    }

    func sizeForCells() -> CGSize {
        if UIDevice.current.orientation.isLandscape {
            sizeForCell = CGSize(width: 260, height: 270)
        } else {
            sizeForCell = CGSize(width: 300, height: 400)
        }
        return sizeForCell
    }

    func getCollection() {
        database.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print(document.data().count)
                    print("\(document.documentID) => \(document.data())")
                    for item in document.data().enumerated() {
                        print(item.element.value)
                    }
                }
            }
        }
    }
}
