//
//  User.swift
//  CookingApp
//
//  Created by  MAC on 5/28/20.
//

import Foundation
import UIKit

class User {
    var userName: String
    var userPhoto: UIImage?
    var userId: String?
    init(userName: String) {
        self.userName = userName
    }
}
