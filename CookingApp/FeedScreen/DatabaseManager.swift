//
//  DatabaseManager.swift
//  CookingApp
//
//  Created by  MAC on 5/27/20.
//

import Foundation
import UIKit
import Firebase

class Database {
    static var database = Firestore.firestore()
    static var currentUID = Auth.auth().currentUser?.uid
    static func pushUserInformationToDatabase(username: String, email: String, profileUrl: String, uid: String) {
        userReference.setData(["username": username, "userID": uid, "email": email, "profileImageUrl": profileUrl])
    }

    static func sendDataToDatabase(uid: String, photoUrl: String, recipeName: String, recipeDescription: String) {
        recipesReference.document().setData(["recipePhotoUrl": photoUrl, "recipeName": recipeName, "recipeDescription": recipeDescription])
    }

    static func getData() {
        Database.database.collection("users").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")

                }
            }
        }
    }
    static var usersReference = Database.database.collection("users")
    static var userReference = Database.database.collection("users").document(Database.currentUID ?? "")
    static var recipesReference = Database.userReference.collection("recipes")

}
