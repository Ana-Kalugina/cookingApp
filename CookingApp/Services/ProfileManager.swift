//
//  ProfileManager.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import Foundation
import Firebase

class ProfileManager {
    static let shared = ProfileManager()
    var nameSaved: String?
    var passwordSaved: String?
    var signed = false
    var mode: String?
    var defMode: String?

    func signed (value: Bool) {
        UserDefaults.standard.set(value, forKey: "signed")
        signed = value
    }

    func nameSaver (value: String?) {
        UserDefaults.standard.set(value, forKey: "username")
        nameSaved = value
    }

    func passwordSaver (value: String?) {
        UserDefaults.standard.set(value, forKey: "password")
    }

    func profileImageSaver (value: String?) {
        UserDefaults.standard.set(value, forKey: "profilePhoto")
    }

    func usersSaver (value: String?) {
        UserDefaults.standard.set([value], forKey: "users")
    }

    func modeSaved (value: String) {
        UserDefaults.standard.set(value, forKey: "mode")
        mode = value
    }


    private init() {}

    enum AuthState {
        case signedIn
        case signedOut
    }
    static var authState: AuthState = .signedOut
}

