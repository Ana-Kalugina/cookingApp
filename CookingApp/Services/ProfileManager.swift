//
//  ProfileManager.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import Foundation

class ProfileManager {
    static let shared = ProfileManager()
    var signed = false
    func signed (value: Bool) {
        UserDefaults.standard.set(value, forKey: "signed")
        signed = value
    }
    private init() {}
}

