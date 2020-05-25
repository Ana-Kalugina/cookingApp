//
//  RecipesFeedViewController.swift
//  CookingApp
//
//  Created by  MAC on 5/25/20.
//

import UIKit
import Firebase
//swiftlint:disable line_length
class RecipesFeedViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    var sizeForCell: CGSize! = CGSize(width: 300, height: 400)
    var database = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
       // getCollection()
    }

}

extension RecipesFeedViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipe", for: indexPath) as? RecipesFeedCollectionViewCell else {fatalError("There is no such cellID or Class")}

        cell.recipeName.text = "Pizza"
        cell.userPhoto.image = #imageLiteral(resourceName: "profileImage")
        cell.recipePhoto.image = #imageLiteral(resourceName: "food1")
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
