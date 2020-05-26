//
//  ProfileManager.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import Foundation

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
    
    private init() {}
}

