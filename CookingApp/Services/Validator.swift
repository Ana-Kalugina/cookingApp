//
//  Validator.swift
//  CookingApp
//
//  Created by  MAC on 5/24/20.
//

import Foundation
import UIKit
//swiftlint:disable line_length
class Validator {
    
    func validate(userName: String, userPassword: String, email: String, repeatPassword: String) -> Bool {
        if userName.isEmpty || userPassword.count < 6 || email.isEmpty || repeatPassword.count < 6 {
            return false
        } else {
            for item in userName.enumerated() {
                if item.element.isLetter {
                    return true
                } else if item.element.isNumber {
                    return true
                } else {
                    return false
                }
            }
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            if !emailPred.evaluate(with: email) {
                return false
            }
        }
        return true
    }
    
    func recipeValidate(recipeName: String, recipeDescription: String, recipePhoto: UIImageView, recipeCategory: String) -> Bool {
        if recipeName.isEmpty || recipeDescription.isEmpty || recipePhoto.image == UIImage(named: "addImage") || recipeCategory.isEmpty {
            return false
        }
        return true
    }
    
    func loginTextCheck(loginText: String, loginErrorMessage: String?) -> String {
        guard var usernameError = loginErrorMessage else {fatalError()}
        if loginText.isEmpty {
            usernameError = "The login field can't be empty"
        } else {
            for item in loginText.enumerated() {
                if !(item.element.isLetter || item.element.isNumber) {
                    usernameError = "You can use only numbers and letters"
                } else {
                    usernameError = " "
                }
            }
        }
        return usernameError
    }
    
    func passwordTextCheck(passwordText: String, passwordErrorMessage: String?) -> String {
        guard var passwordErrorText = passwordErrorMessage
            else { fatalError()}
        if passwordText.count < 6 {
            passwordErrorText = "Your password can't consist of less then 6 elements"
        } else {
            passwordErrorText = " "
        }
        return passwordErrorText
    }
    
    func repeatPasswordCheck (passwordText: String, repeatPassword: String, repeatPasswordErrorMessage: String?) -> String {
        guard var passwordErrorText = repeatPasswordErrorMessage else {fatalError()}
        if passwordText != repeatPassword {
            passwordErrorText = "You entered wrong password"
        } else {
            passwordErrorText = " "
        }
        return passwordErrorText
    }
    
    func emailTextCheck(emailText: String, emailErrorMessage: String?) -> String {
        guard var emailErrorMessage = emailErrorMessage else {fatalError("emailErrorMessage error")}
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        if emailPred.evaluate(with: emailText) {
            emailErrorMessage = ""
            return emailErrorMessage
        } else {
            emailErrorMessage = "Your email is not valid"
            return emailErrorMessage
        }
    }
}
