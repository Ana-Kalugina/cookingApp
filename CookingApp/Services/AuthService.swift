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
