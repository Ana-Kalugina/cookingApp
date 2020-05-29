//
//  Recipe.swift
//  CookingApp
//
//  Created by  MAC on 5/28/20.
//

import Foundation
import UIKit
import Firebase

class Recipe {
    var recipeName: String
    var recipeDescription: String
    var recipePhoto: UIImage
    var userName: String?
    var userPhoto: UIImage?
    
    init(recipeName: String, recipeDescription: String, recipePhoto: UIImage) {
        self.recipeName = recipeName
        self.recipeDescription = recipeDescription
        self.recipePhoto = recipePhoto
    }
}
