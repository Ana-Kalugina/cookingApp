//
//  AuthService.swift
//  CookingApp
//
//  Created by  MAC on 5/26/20.
//

import Foundation
import Firebase

class AuthService {
    static func signUp(email: String, password: String, completion: @escaping () -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error == nil {
            } else {

            }
            completion()
        }
    }
}
//    static func createUser(username: String, email: String, password: String, selectedImage: UIImage, completion: @escaping () -> Void) {
//        let profileManager = ProfileManager.shared
//        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
//            if error == nil {
//                AuthService.signUp(email: email, password: password) {
//                }
//                profileManager.signed(value: true)
//                guard let currentUser = Auth.auth().currentUser?.uid else {return}
//                let storageReference = Storage.storage().reference(forURL: "gs://cookingapp-ana23.appspot.com").child("profileImage").child(currentUser)
//                let profileImg = selectedImage
//                guard let imageData = profileImg.jpegData(compressionQuality: 1.0) else {
//                    return
//                }
//                storageReference.putData(imageData, metadata: nil) { (metaData, error) in
//                    if error != nil {
//                        return
//                    }
//                    storageReference.downloadURL { (url, error) in
//                        if error != nil {
//                            return
//                        }
//                        guard let profileImageUrl = url?.absoluteString else {return}
//                    }
//                }
//            }
//        }
//    }
//}
